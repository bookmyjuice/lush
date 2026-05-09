import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lush/config/api_config.dart';
import 'package:lush/services/secure_storage_service.dart';

class SubscriptionService {
  static String get baseUrl => ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<String?> _getToken() async {
    return await _secureStorage.getAuthToken();
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

  /// Pause a subscription. Returns {success, message}.
  /// Backend returns 202 Accepted — caller must refetch to confirm state.
  Future<Map<String, dynamic>> pauseSubscription(String subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId/pause'),
        headers: headers,
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 202) {
        return {'success': true, 'message': body['message'] ?? 'Subscription paused'};
      } else {
        throw Exception(body['message'] ?? 'Failed to pause subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error pausing subscription: $e');
      rethrow;
    }
  }

  /// Resume a paused subscription. Returns {success, message}.
  /// Backend returns 202 Accepted — caller must refetch to confirm state.
  Future<Map<String, dynamic>> resumeSubscription(String subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId/resume'),
        headers: headers,
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 202) {
        return {'success': true, 'message': body['message'] ?? 'Subscription resumed'};
      } else {
        throw Exception(body['message'] ?? 'Failed to resume subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error resuming subscription: $e');
      rethrow;
    }
  }

  /// Cancel a subscription. Returns {success, message}.
  /// Backend returns 202 Accepted — caller must refetch to confirm state.
  Future<Map<String, dynamic>> cancelSubscription(String subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId'),
        headers: headers,
      );

      final body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 202) {
        return {'success': true, 'message': body['message'] ?? 'Subscription canceled'};
      } else {
        throw Exception(body['message'] ?? 'Failed to cancel subscription: ${response.statusCode}');
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
