import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lush/config/api_config.dart';
import 'package:lush/services/secure_storage_service.dart';
import 'package:lush/utils/app_logger.dart';

class SubscriptionService {
  static String get baseUrl => ApiConfig.baseUrl;
  final SecureStorageService _secureStorage = SecureStorageService();
  final http.Client? _client;

  SubscriptionService({http.Client? client}) : _client = client;

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

  /// Get all subscription plans
  Future<List<Map<String, dynamic>>> getSubscriptionPlans() async {
    try {
      final headers = await _getHeaders();
      final client = _client ?? http.Client();
      final response = await client.get(
        Uri.parse('$baseUrl/api/subscriptions/pricing/plans'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from((data['data'] as List?) ?? []);
      } else {
        throw Exception(
            'Failed to load subscription plans: ${response.statusCode}',);
      }
    } catch (e) {
      appLogger.e('Error fetching subscription plans', error: e);
      rethrow;
    }
  }

  /// Get user's subscriptions
  Future<List<Map<String, dynamic>>> getMySubscriptions() async {
    try {
      final headers = await _getHeaders();
      final client = _client ?? http.Client();
      final response = await client.get(
        Uri.parse('$baseUrl/api/subscriptions/my'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from((data['subscriptions'] as List?) ?? []);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.e('Error fetching subscriptions', error: e);
      rethrow;
    }
  }

  /// Get specific subscription details
  Future<Map<String, dynamic>> getSubscriptionDetails(String subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final client = _client ?? http.Client();
      final response = await client.get(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to load subscription details: ${response.statusCode}',);
      }
    } catch (e) {
      appLogger.e('Error fetching subscription details', error: e);
      rethrow;
    }
  }

  /// Create a subscription - returns Chargebee hosted page URL.
  ///
  /// [daySchedule] is the day-wise delivery schedule the customer picked
  /// (`{'monday': 'mix-punch', ...}`). Sending it lets the backend persist the
  /// schedule before checkout and publish a real `nextDeliveryAt`; without it
  /// the API publishes nothing and the UI shows an em dash.
  Future<Map<String, dynamic>> createSubscription(
    String planId, {
    Map<String, String>? daySchedule,
  }) async {
    try {
      final headers = await _getHeaders();
      final client = _client ?? http.Client();
      final Map<String, dynamic> body = <String, dynamic>{'planId': planId};
      if (daySchedule != null && daySchedule.isNotEmpty) {
        body['schedule'] = daySchedule;
      }
      final response = await client.post(
        Uri.parse('$baseUrl/api/subscriptions/create'),
        headers: headers,
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to create subscription: ${response.statusCode}',);
      }
    } catch (e) {
      appLogger.e('Error creating subscription', error: e);
      rethrow;
    }
  }

  /// Pause a subscription. Returns {success, message}.
  Future<Map<String, dynamic>> pauseSubscription(
      String subscriptionId,
      {String duration = '1_week',}) async {
    try {
      final headers = await _getHeaders();
      final client = _client ?? http.Client();
      final response = await client.put(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId/pause'),
        headers: headers,
        body: json.encode({'duration': duration}),
      );
      final body = json.decode(response.body);
      if (response.statusCode == 200 || response.statusCode == 202) {
        return {'success': true, 'message': body['message'] ?? 'Subscription paused'};
      } else {
        throw Exception(body['message'] ?? 'Failed to pause subscription: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.e('Error pausing subscription', error: e);
      rethrow;
    }
  }

  /// Resume a paused subscription. Returns {success, message}.
  Future<Map<String, dynamic>> resumeSubscription(String subscriptionId) async {
    try {
      final headers = await _getHeaders();
      final client = _client ?? http.Client();
      final response = await client.put(
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
      appLogger.e('Error resuming subscription', error: e);
      rethrow;
    }
  }

  /// Cancel a subscription with reason. Returns {success, message}.
  Future<Map<String, dynamic>> cancelSubscription(
      String subscriptionId,
      {String reason = '',}) async {
    try {
      final headers = await _getHeaders();
      // Use PUT with reason body matching bmjServer /cancel endpoint
      final client = _client ?? http.Client();
      final response = await client.put(
        Uri.parse('$baseUrl/api/subscriptions/$subscriptionId/cancel'),
        headers: headers,
        body: json.encode({'reason': reason}),
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
}