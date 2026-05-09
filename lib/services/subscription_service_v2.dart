import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lush/config/api_config.dart';
import 'package:lush/views/models/subscription.dart';

/// Service for fetching and managing subscription data
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final String _baseUrl = ApiConfig.baseUrl;

  /// Get all subscriptions for the current user
  Future<List<Subscription>> getMySubscriptions(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/my'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['subscriptions'] != null && data['subscriptions'] is List) {
          return (data['subscriptions'] as List)
              .map((json) => Subscription.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        return [];
      } else {
        throw Exception('Failed to load subscriptions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subscriptions: $e');
      return [];
    }
  }

  /// Get specific subscription details
  Future<Subscription?> getSubscription(String token, String subscriptionId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null) {
          return Subscription.fromJson(data['data'] as Map<String, dynamic>);
        }
        return null;
      } else {
        throw Exception('Failed to load subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching subscription: $e');
      return null;
    }
  }

  /// Create a new subscription (returns hosted page URL)
  Future<String?> createSubscription(String token, String planId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/subscriptions/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'planId': planId}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'] as String?;
      } else {
        throw Exception('Failed to create subscription: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating subscription: $e');
      return null;
    }
  }

  /// Pause a subscription
  Future<bool> pauseSubscription(String token, String subscriptionId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/subscriptions/$subscriptionId/pause'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error pausing subscription: $e');
      return false;
    }
  }

  /// Resume a paused subscription
  Future<bool> resumeSubscription(String token, String subscriptionId) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/api/subscriptions/$subscriptionId/resume'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error resuming subscription: $e');
      return false;
    }
  }

  /// Cancel a subscription
  Future<bool> cancelSubscription(String token, String subscriptionId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/api/subscriptions/$subscriptionId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error canceling subscription: $e');
      return false;
    }
  }

  /// Get all available subscription plans
  Future<List<Map<String, dynamic>>> getAllPlans() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/pricing/plans'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['data'] != null && data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data'] as List);
        }
        return [];
      } else {
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching plans: $e');
      return [];
    }
  }

  /// Get pricing page URL for customer
  Future<String?> getPricingPageUrl(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/subscriptions/pricing-page'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['url'] as String?;
      } else {
        throw Exception('Failed to get pricing page: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting pricing page: $e');
      return null;
    }
  }
}
