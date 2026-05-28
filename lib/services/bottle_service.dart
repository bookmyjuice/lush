import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lush/config/api_config.dart';
import 'package:lush/services/secure_storage_service.dart';
import 'package:lush/utils/app_logger.dart';
import 'package:lush/views/models/bottle_ledger.dart';

class BottleService {
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

  /// Get the computed bottle ledger for the authenticated customer.
  Future<List<BottleLedgerEntry>> getLedger() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/bottles/ledger'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = (data['data'] as List?) ?? [];
        return list.map((e) => BottleLedgerEntry.fromJson(e as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load bottle ledger: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.e('Error fetching bottle ledger', error: e);
      rethrow;
    }
  }

  /// Get raw transaction history for the authenticated customer.
  Future<List<BottleTransaction>> getTransactions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/bottles/transactions'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final list = (data['data'] as List?) ?? [];
        return list.map((e) => BottleTransaction.fromJson(e as Map<String, dynamic>)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception(
            'Failed to load bottle transactions: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.e('Error fetching bottle transactions', error: e);
      rethrow;
    }
  }

  /// Record bottles returned by the customer.
  Future<BottleTransaction> recordReturn(
    String orderId,
    String bottleType,
    int quantity, {
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'orderId': orderId,
        'bottleType': bottleType,
        'quantity': quantity,
        if (notes != null) 'notes': notes,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/bottles/return'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return BottleTransaction.fromJson(data['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception(
            'Failed to record bottle return: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.e('Error recording bottle return', error: e);
      rethrow;
    }
  }

  /// Record bottles reported as broken or lost.
  Future<BottleTransaction> recordBroken(
    String orderId,
    String bottleType,
    int quantity, {
    String? notes,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = json.encode({
        'orderId': orderId,
        'bottleType': bottleType,
        'quantity': quantity,
        if (notes != null) 'notes': notes,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/api/bottles/broken'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return BottleTransaction.fromJson(data['data'] as Map<String, dynamic>);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception(
            'Failed to record bottle broken: ${response.statusCode}');
      }
    } catch (e) {
      appLogger.e('Error recording bottle broken', error: e);
      rethrow;
    }
  }
}
