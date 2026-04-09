import 'package:flutter/foundation.dart';

// Compile-time read of --dart-define=API_BASE_URL; empty if not provided
const String _envApiBaseUrl =
    String.fromEnvironment('API_BASE_URL', defaultValue: '');

class ApiConfig {
  /// Returns the API base URL.
  /// Priority: --dart-define API_BASE_URL > platform-specific sensible default.
  static String get baseUrl {
    if (_envApiBaseUrl.isNotEmpty) return _envApiBaseUrl;

    if (kIsWeb) {
      return 'http://127.0.0.1:8080';
    }

    // defaultTargetPlatform is only valid when not running in tests without bindings
    // Use Android emulator loopback by default as project previously targeted Android
    return 'http://10.159.18.139:8080';
  }
}
