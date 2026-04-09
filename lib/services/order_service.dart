import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lush/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Get user's orders from Chargebee
  Future<List<Map<String, dynamic>>> getMyOrders() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from((data['data'] as List?) ?? []);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      rethrow;
    }
  }

  /// Get specific order details
  Future<Map<String, dynamic>> getOrderDetails(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load order details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching order details: $e');
      rethrow;
    }
  }

  /// Get local order history from database
  Future<List<Map<String, dynamic>>> getLocalOrderHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/local/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from((data['data'] as List?) ?? []);
      } else {
        throw Exception('Failed to load local orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching local orders: $e');
      rethrow;
    }
  }

  /// Get local order details
  Future<Map<String, dynamic>> getLocalOrderDetails(String orderId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/orders/local/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load local order: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching local order: $e');
      rethrow;
    }
  }
}
