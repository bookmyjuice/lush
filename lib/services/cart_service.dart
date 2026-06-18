import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lush/config/api_config.dart';
import 'package:lush/services/secure_storage_service.dart';

import '../utils/app_logger.dart';

/// Service for calling the backend CartController endpoints.
/// Follows the pattern established by [OrderService].
/// Uses JWT auth for authenticated users.
/// All endpoints require authentication (hasRole('USER')).
class CartService {
  static String get baseUrl => ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();
  final http.Client? _client;

  CartService({http.Client? client}) : _client = client;

  Future<String?> _getToken() async {
    return _secureStorage.getAuthToken();
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/v1/cart - Get the current user's cart from backend.
  /// Returns the full cart response (cart_id, items, subtotal, etc.).
  /// Throws on failure (401, 500, etc.)
  Future<Map<String, dynamic>> getCart() async {
    try {
      final headers = await _getHeaders();
      final client = _client ?? http.Client();
      final response = await client.get(
        Uri.parse('$baseUrl/api/v1/cart'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        final body = json.decode(response.body);
        throw Exception(body['error'] ?? 'Failed to fetch cart: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.e('CartService.getCart failed', error: e);
      rethrow;
    }
  }

  /// POST /api/v1/cart/items?priceId=xxx&quantity=N - Add item to backend cart.
  /// [priceId] is the Chargebee price ID (e.g., "ice-regular-1-999").
  /// Returns the updated cart response.
  Future<Map<String, dynamic>> addItem(String priceId, {int quantity = 1}) async {
    try {
      final headers = await _getHeaders();
      final uri = Uri.parse('$baseUrl/api/v1/cart/items')
          .replace(queryParameters: {'priceId': priceId, 'quantity': quantity.toString()});
      final client = _client ?? http.Client();
      final response = await client.post(uri, headers: headers);

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 409) {
        // CART_TYPE_CONFLICT: Cannot mix one-time and subscription items
        final body = json.decode(response.body);
        throw CartTypeConflictException(body['message'] as String? ?? 'Cart type conflict');
      } else {
        final body = json.decode(response.body);
        throw Exception(body['error'] ?? 'Failed to add item: ${response.statusCode}');
      }
    } catch (e) {
      if (e is CartTypeConflictException) rethrow;
      appLogger.e('CartService.addItem failed', error: e);
      rethrow;
    }
  }

  /// DELETE /api/v1/cart/items/{priceId} - Remove item from backend cart.
  /// Returns the updated cart response.
  Future<Map<String, dynamic>> removeItem(String priceId) async {
    try {
      final headers = await _getHeaders();
      final client = _client ?? http.Client();
      final response = await client.delete(
        Uri.parse('$baseUrl/api/v1/cart/items/$priceId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 404) {
        throw Exception('Item not found in cart: $priceId');
      } else {
        final body = json.decode(response.body);
        throw Exception(body['error'] ?? 'Failed to remove item: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.e('CartService.removeItem failed', error: e);
      rethrow;
    }
  }

  /// DELETE /api/v1/cart/clear - Clear all items from backend cart.
  Future<Map<String, dynamic>> clearCart() async {
    try {
      final headers = await _getHeaders();
      final client = _client ?? http.Client();
      final response = await client.delete(
        Uri.parse('$baseUrl/api/v1/cart/clear'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        final body = json.decode(response.body);
        throw Exception(body['error'] ?? 'Failed to clear cart: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.e('CartService.clearCart failed', error: e);
      rethrow;
    }
  }

  /// POST /api/v1/cart/merge - Merge guest/local cart items into the authenticated user's backend cart.
  /// [guestCartId] is the backend cart ID from the guest session (optional — can be null if guest cart is local-only).
  /// [items] List of {priceId, quantity, type} maps to push local items that don't have a backend cart ID.
  /// Returns the merged cart response.
  Future<Map<String, dynamic>> mergeCart({
    String? guestCartId,
    String? keepPreference,
    List<Map<String, dynamic>>? items,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = <String, dynamic>{};
      if (guestCartId != null) body['guest_cart_id'] = guestCartId;
      if (keepPreference != null) body['keep'] = keepPreference;
      if (items != null && items.isNotEmpty) body['items'] = items;

      final client = _client ?? http.Client();
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/cart/merge'),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else if (response.statusCode == 409) {
        final result = json.decode(response.body);
        throw CartMergeConflictException(
          result['error'] as String? ?? 'Cart merge conflict',
        );
      } else {
        final result = json.decode(response.body);
        throw Exception(result['error'] ?? 'Failed to merge cart: ${response.statusCode}');
      }
    } catch (e) {
      if (e is CartMergeConflictException) rethrow;
      appLogger.e('CartService.mergeCart failed', error: e);
      rethrow;
    }
  }
}

/// Thrown when the backend returns 409 CART_TYPE_CONFLICT
/// (trying to mix one-time and subscription items).
class CartTypeConflictException implements Exception {
  final String message;
  CartTypeConflictException(this.message);

  @override
  String toString() => 'CartTypeConflictException: $message';
}

/// Thrown when the backend returns 409 on merge (cart type mismatch).
class CartMergeConflictException implements Exception {
  final String message;
  CartMergeConflictException(this.message);

  @override
  String toString() => 'CartMergeConflictException: $message';
}