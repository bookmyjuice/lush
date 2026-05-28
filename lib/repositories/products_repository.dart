import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import '../config/api_config.dart';
import '../services/secure_storage_service.dart';

/// Repository for product endpoints on bmjServer.
///
/// Calls:
///   GET /api/products              → all products
///   GET /api/products/{id}         → single product
///   GET /api/products/family/{family}  → by family
///   GET /api/products/search?q=    → search
///   GET /api/products/featured     → featured
class ProductsRepository {
  final String _baseUrl = ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();
  final HttpClient _httpClient = HttpClient();

  IOClient _createClient() {
    _httpClient.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    return IOClient(_httpClient);
  }

  Future<Map<String, String>> _authHeaders() async {
    final token = await _secureStorage.getAuthToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// GET /api/products — all products
  Future<List<Map<String, dynamic>>> getProducts() async {
    final http = _createClient();
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/products'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = const Utf8Decoder().convert(response.bodyBytes);
      final dynamic decoded = json.decode(body);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } else {
      throw Exception(
          'Failed to load products: ${response.statusCode} ${response.body}');
    }
  }

  /// GET /api/products/{id} — single product by ID
  Future<Map<String, dynamic>> getProductById(String id) async {
    final http = _createClient();
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/products/$id'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = const Utf8Decoder().convert(response.bodyBytes);
      final dynamic decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      throw Exception('Invalid response format for product $id');
    } else if (response.statusCode == 404) {
      throw Exception('Product not found: $id');
    } else {
      throw Exception(
          'Failed to load product $id: ${response.statusCode} ${response.body}');
    }
  }

  /// GET /api/products/family/{family} — products by family (juice|smoothie|detox)
  Future<List<Map<String, dynamic>>> getProductsByFamily(String family) async {
    final http = _createClient();
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/products/family/$family'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = const Utf8Decoder().convert(response.bodyBytes);
      final dynamic decoded = json.decode(body);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } else {
      throw Exception(
          'Failed to load products by family $family: ${response.statusCode}');
    }
  }

  /// GET /api/products/search?q={query} — search products
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final http = _createClient();
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/products/search?q=${Uri.encodeQueryComponent(query)}'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = const Utf8Decoder().convert(response.bodyBytes);
      final dynamic decoded = json.decode(body);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } else {
      throw Exception(
          'Failed to search products: ${response.statusCode}');
    }
  }

  /// GET /api/products/featured — featured products only
  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    final http = _createClient();
    final headers = await _authHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/api/products/featured'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final body = const Utf8Decoder().convert(response.bodyBytes);
      final dynamic decoded = json.decode(body);
      if (decoded is List) {
        return decoded.whereType<Map<String, dynamic>>().toList();
      }
      return [];
    } else {
      throw Exception(
          'Failed to load featured products: ${response.statusCode}');
    }
  }
}