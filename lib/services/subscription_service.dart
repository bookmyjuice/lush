import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lush/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
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

  /// Get all subscription plans
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/subscriptions/pricing/plans'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from((data['data'] as List?) ?? []);
      } else {
        throw Exception(
            'Failed to load subscription plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subscription plans: $e');
      rethrow;
    }
  }

  /// Get user's subscriptions
  Future<List<Map<String, dynamic>>> getMySubscriptions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/subscriptions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from((data['data'] as List?) ?? []);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subscriptions: $e');
      rethrow;
    }
  }

  /// Get specific subscription details
  Future<Map<String, dynamic>> getSubscriptionDetails(
      String subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to load subscription details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subscription details: $e');
      rethrow;
    }
  }

  /// Create a subscription - returns Chargebee hosted page URL
  Future<Map<String, dynamic>> createSubscription(String planId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/api/subscriptions/create'),
        headers: headers,
        body: json.encode({'planId': planId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to create subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating subscription: $e');
      rethrow;
    }
  }

  /// Pause a subscription
  Future<bool> pauseSubscription(String subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId/pause'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to pause subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error pausing subscription: $e');
      rethrow;
    }
  }

  /// Resume a paused subscription
  Future<bool> resumeSubscription(String subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId/resume'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to resume subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error resuming subscription: $e');
      rethrow;
    }
  }

  /// Cancel a subscription
  Future<bool> cancelSubscription(String subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception(
            'Failed to cancel subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error canceling subscription: $e');
      rethrow;
    }
  }

  /// Get pricing page URL for customer
  Future<String> getPricingPageUrl() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/subscriptions/pricing-page'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'] as String;
      } else {
        throw Exception('Failed to get pricing page: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting pricing page: $e');
      rethrow;
    }
  }
}
