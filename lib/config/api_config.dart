import 'package:flutter/foundation.dart';

const String _envApiBaseUrl =
    String.fromEnvironment('API_BASE_URL');

/// Environment-aware Chargebee configuration.
/// All values from build-time --dart-define flags.
/// Test values have safe defaults for local development.
/// See docs/DEPLOYMENT.md for production setup.
class ChargebeeConfig {
  static const String testSiteName = 'bookmyjuice-test';
  static const String prodSiteName = 'bookmyjuice';

  static const String _env =
      String.fromEnvironment('ENV', defaultValue: 'test');

  static bool get isProduction => _env == 'production';

  static String get siteName =>
      isProduction ? prodSiteName : testSiteName;

  static String get apiKey =>
      isProduction
          ? const String.fromEnvironment('CHARGEBEE_PROD_KEY')
          : const String.fromEnvironment(
              'CHARGEBEE_TEST_KEY',
              defaultValue:
                  'test_ai_-ZFEjZ3qiK2mW3k7C9M2Q60OK2QmLslRdSnNWt61z4E',
            );
}

/// API base URL configuration.
class ApiConfig {
  static String get baseUrl {
    if (_envApiBaseUrl.isNotEmpty) return _envApiBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8080';
    return 'http://localhost:8080';
  }
}