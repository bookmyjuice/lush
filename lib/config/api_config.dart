import 'package:flutter/foundation.dart';

const String _envApiBaseUrl = String.fromEnvironment('API_BASE_URL');

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

  static String get siteName => isProduction ? prodSiteName : testSiteName;

  /// Never ship a Chargebee API key inside the app: anything compiled into the
  /// binary is extractable. The storefront talks to the BMJ API, which holds the
  /// key server-side; these getters exist only for tooling builds that pass the
  /// value with `--dart-define`. The previous hardcoded test key was dead code
  /// (nothing reads [apiKey]) and has been removed from source.
  static String get apiKey => isProduction
      ? const String.fromEnvironment('CHARGEBEE_PROD_KEY')
      : const String.fromEnvironment('CHARGEBEE_TEST_KEY');
}

/// API base URL configuration.
class ApiConfig {
  static String get baseUrl {
    if (_envApiBaseUrl.isNotEmpty) return _envApiBaseUrl;
    if (kIsWeb) return 'http://127.0.0.1:8080';
    return 'http://localhost:8080';
  }
}
