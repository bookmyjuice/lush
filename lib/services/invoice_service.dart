import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:lush/config/api_config.dart';
import 'package:lush/services/secure_storage_service.dart';

class InvoiceService {
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

  /// Get user's invoices from Chargebee
  Future<List<Map<String, dynamic>>> getMyInvoices() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/invoices'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final invoiceList = (data['data'] as List?) ?? [];
        return List<Map<String, dynamic>>.from(invoiceList);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized: Please login again');
      } else {
        throw Exception('Failed to load invoices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching invoices: $e');
      rethrow;
    }
  }

  /// Get specific invoice details
  Future<Map<String, dynamic>> getInvoiceDetails(String invoiceId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/invoices/$invoiceId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception(
            'Failed to load invoice details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching invoice details: $e');
      rethrow;
    }
  }

  /// Get invoice PDF URL
  Future<String> getInvoicePdfUrl(String invoiceId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/invoices/$invoiceId/pdf-url'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['pdfUrl'] as String;
      } else {
        throw Exception('Failed to get PDF URL: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting PDF URL: $e');
      rethrow;
    }
  }

  /// Send invoice email to customer
  Future<bool> sendInvoiceEmail(String invoiceId, {String? email}) async {
    try {
      final headers = await _getHeaders();
      final body = email != null ? json.encode({'email': email}) : null;

      final response = await http.post(
        Uri.parse('$baseUrl/api/invoices/$invoiceId/send-email'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to send invoice email: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending invoice email: $e');
      rethrow;
    }
  }

  /// Get local invoice history from database
  Future<List<Map<String, dynamic>>> getLocalInvoiceHistory() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/invoices/local/history'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final invoiceList = (data['data'] as List?) ?? [];
        return List<Map<String, dynamic>>.from(invoiceList);
      } else {
        throw Exception(
            'Failed to load local invoices: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching local invoices: $e');
      rethrow;
    }
  }

  /// Get local invoice details
  Future<Map<String, dynamic>> getLocalInvoiceDetails(String invoiceId) async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/api/invoices/local/$invoiceId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load local invoice: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching local invoice: $e');
      rethrow;
    }
  }
}
