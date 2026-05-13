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

    // Android emulator loopback: 10.0.2.2 maps to host machine's localhost
    // For physical device testing on same WiFi:
    //   Run: flutter run --dart-define=API_BASE_URL=http://YOUR_MACHINE_IP:8080
    //   Or use: ..\ops\build_flutter_for_phone.ps1
    return 'http://10.0.2.2:8080';
  }
}
