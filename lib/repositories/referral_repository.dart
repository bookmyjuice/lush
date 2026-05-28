import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';

import '../config/api_config.dart';
import '../models/referral_info.dart';
import '../services/secure_storage_service.dart';

class ReferralRepository {
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

  Future<ReferralInfo> getReferralInfo() async {
    final http = _createClient();
    final headers = await _authHeaders();
    final response = await http.get(
      Uri.parse('$_baseUrl/api/referral/code'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final body = const Utf8Decoder().convert(response.bodyBytes);
      final decoded = json.decode(body) as Map<String, dynamic>;
      return ReferralInfo.fromJson(decoded);
    } else {
      throw Exception('Failed to load referral info');
    }
  }

  Future<bool> applyReferralCode(String code) async {
    final http = _createClient();
    final headers = await _authHeaders();
    final response = await http.post(
      Uri.parse('$_baseUrl/api/referral/apply'),
      headers: headers,
      body: json.encode({'referralCode': code}),
    );
    return response.statusCode == 200;
  }
}
