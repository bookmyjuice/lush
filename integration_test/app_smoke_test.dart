import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:lush/getIt.dart';
import 'package:lush/main.dart';

// Enable with: --dart-define=E2E=true
const bool runE2E = bool.fromEnvironment('E2E', defaultValue: false);
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App launches (smoke)', (WidgetTester tester) async {
    if (!runE2E) {
      return; // gated off unless E2E=true is provided
    }

    // Minimal DI to satisfy app constructors
    WidgetsFlutterBinding.ensureInitialized();
    registerRepositories();

    if (kDebugMode) {
      // Log the base URL used, helpful for CI
      // ignore: avoid_print
      print('E2E base URL: $baseUrl');
    }

    await tester.pumpWidget(const BookMyJuiceApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(MaterialApp), findsOneWidget);
  }, semanticsEnabled: false);
}
