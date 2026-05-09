import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage service for sensitive data (tokens, passwords, etc.)
/// Replaces SharedPreferences for security-critical data
class SecureStorageService {
  static SecureStorageService _instance = SecureStorageService._internal();
  
  factory SecureStorageService() => _instance;
  
  SecureStorageService._internal();
  
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Get auth token
  Future<String?> getAuthToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Save auth token
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  /// Delete auth token
  Future<void> deleteAuthToken() async {
    await _storage.delete(key: 'auth_token');
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: 'user_id');
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: 'user_id', value: userId);
  }

  /// Delete user ID
  Future<void> deleteUserId() async {
    await _storage.delete(key: 'user_id');
  }

  /// Clear all secure data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
