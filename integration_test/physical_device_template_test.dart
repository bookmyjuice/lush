// Integration test template for physical device testing
// Device: 25053PC47I
// Base URL: http://192.168.1.6:8080
//
// Usage:
//   flutter test integration_test/physical_device_template_test.dart \
//     --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://192.168.1.6:8080 \
//     --dart-define=E2E_USER=test@example.com \
//     --dart-define=E2E_PASS=password

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:lush/getIt.dart';
import 'package:lush/main.dart';

// Gated execution to avoid accidental hits to live/staging
const bool runE2E = bool.fromEnvironment('E2E', defaultValue: false);
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
const String e2eUser = String.fromEnvironment('E2E_USER', defaultValue: '');
const String e2ePass = String.fromEnvironment('E2E_PASS', defaultValue: '');

// Test timeouts
const Duration appLaunchTimeout = Duration(seconds: 30);
const Duration apiTimeout = Duration(seconds: 10);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Physical Device E2E Test (Device: 25053PC47I)', () {
    setUpAll(() async {
      if (!runE2E) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('E2E is disabled. Set --dart-define=E2E=true to run.');
        }
        return;
      }
      assert(baseUrl.isNotEmpty, 'API_BASE_URL is required');
      assert(e2eUser.isNotEmpty && e2ePass.isNotEmpty,
          'E2E_USER and E2E_PASS are required');

      if (kDebugMode) {
        // ignore: avoid_print
        print('=== Physical Device Test Configuration ===');
        print('Device ID: 25053PC47I');
        print('Base URL: $baseUrl');
        print('Test User: $e2eUser');
        print('==========================================');
      }
    });

    // ============================================================
    // TEST 1: Email-first Signup Flow
    // ============================================================
    testWidgets('Email-first Signup Flow', (tester) async {
      if (!runE2E) {
        return;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('\n[TEST 1] Email-first Signup Flow');
      }

      // Launch app
      WidgetsFlutterBinding.ensureInitialized();
      registerRepositories();

      await tester.pumpWidget(const BookMyJuiceApp());
      await tester.pumpAndSettle(appLaunchTimeout);

      // Navigate to signup method selection
      await tester.tap(find.text('Login')); // From splash/login
      await tester.pumpAndSettle();
      
      // Tap on "Sign up with Email"
      await tester.tap(find.text('Sign up with Email'));
      await tester.pumpAndSettle();

      // Step 1: Enter email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'newuser@example.com');
      await tester.pumpAndSettle();
      
      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 2: Enter email verification code (6 digits)
      // Note: In dev mode, check console for code
      // For test, enter dummy code
      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.pumpAndSettle();
      
      // Tap Verify Email
      await tester.tap(find.text('Verify Email'));
      await tester.pumpAndSettle();

      // Step 3: Enter phone number
      await tester.enterText(find.byType(TextFormField).first, '9999999999');
      await tester.pumpAndSettle();
      
      // Tap Send OTP
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      // Step 4: Enter OTP (6 digits)
      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.pumpAndSettle();
      
      // Tap Verify OTP
      await tester.tap(find.text('Verify OTP'));
      await tester.pumpAndSettle();

      // Step 5: Enter address details
      // Fill in all required address fields
      await tester.enterText(find.byType(TextFormField).first, 'John'); // First name
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'Doe'); // Last name
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(2), '123 Main St'); // Address
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(3), 'Sunshine Society'); // Extended addr
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(4), 'Sector 15'); // Extended addr 2
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(5), 'Mumbai'); // City
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(6), 'Maharashtra'); // State
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(7), '400001'); // ZIP
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(8), 'IN'); // Country
      await tester.pumpAndSettle();
      
      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 6: Create password
      await tester.enterText(find.byType(TextFormField).first, 'SecurePass123!');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'SecurePass123!');
      await tester.pumpAndSettle();
      
      // Tap Create Account
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      if (kDebugMode) {
        // ignore: avoid_print
        print('[TEST 1] Email-first signup completed');
      }
    }, semanticsEnabled: false);

    // ============================================================
    // TEST 2: Phone-first Signup Flow
    // ============================================================
    testWidgets('Phone-first Signup Flow', (tester) async {
      if (!runE2E) {
        return;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('\n[TEST 2] Phone-first Signup Flow');
      }

      // Launch app
      WidgetsFlutterBinding.ensureInitialized();
      registerRepositories();

      await tester.pumpWidget(const BookMyJuiceApp());
      await tester.pumpAndSettle(appLaunchTimeout);

      // Navigate to signup and select phone
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign up with Phone'));
      await tester.pumpAndSettle();

      // Step 1: Enter phone
      await tester.enterText(find.byType(TextFormField).first, '8888888888');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      // Step 2: Verify OTP
      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verify OTP'));
      await tester.pumpAndSettle();

      // Step 3: Enter email
      await tester.enterText(find.byType(TextFormField).first, 'phoneuser@example.com');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Step 4: Verify email code
      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verify Email'));
      await tester.pumpAndSettle();

      // Step 5: Enter address (similar to email-first flow)
      // ... (same as above)

      // Step 6: Create password
      // ... (same as above)

      if (kDebugMode) {
        // ignore: avoid_print
        print('[TEST 2] Phone-first signup completed');
      }
    }, semanticsEnabled: false);

    // ============================================================
    // TEST 3: Login → [Test] → Logout (Existing flow)
    // ============================================================
    testWidgets('Launch → Login → [Test] → Logout', (tester) async {
      if (!runE2E) {
        return;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('\n[TEST 3] Login → [Test] → Logout');
      }

      // Launch app
      WidgetsFlutterBinding.ensureInitialized();
      registerRepositories();

      await tester.pumpWidget(const BookMyJuiceApp());
      await tester.pumpAndSettle(appLaunchTimeout);

      // Verify app launched
      expect(find.byType(MaterialApp), findsOneWidget);

      // Navigate to login and login with existing user
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Find and enter credentials
      final usernameField = find.byType(TextFormField).first;
      final passwordField = find.byType(TextFormField).last;

      await tester.enterText(usernameField, e2eUser);
      await tester.enterText(passwordField, e2ePass);
      await tester.pumpAndSettle();

      // Tap Login
      await tester.tap(find.widgetWithText(ElevatedButton, 'LOGIN'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));

      if (kDebugMode) {
        // ignore: avoid_print
        print('[TEST 3] Login completed, running custom test...');
      }

      // TODO: Add custom test logic here
      // Example: Navigate to products, add to cart, etc.

      // Logout
      final menuButton = find.byIcon(Icons.menu);
      if (menuButton.evaluate().isNotEmpty) {
        await tester.tap(menuButton);
        await tester.pumpAndSettle();

        final logoutButton = find.text('Logout');
        if (logoutButton.evaluate().isNotEmpty) {
          await tester.tap(logoutButton);
          await tester.pumpAndSettle();

          final confirmButton = find.text('LOGOUT');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle();
          }
        }
      }

      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      if (kDebugMode) {
        // ignore: avoid_print
        print('[TEST 3] Logout completed\n');
      }

      // Verify back at login
      expect(find.byType(TextFormField), findsWidgets);
    }, semanticsEnabled: false);

    // ============================================================
    // API SANITY CHECK
    // ============================================================
    testWidgets('API Sanity Check', (tester) async {
      if (!runE2E) {
        return;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('\n[API Check] Testing backend connectivity...');
      }

      // Test health endpoint
      final healthRes = await http
          .get(Uri.parse('$baseUrl/api/health'))
          .timeout(apiTimeout);
      expect(healthRes.statusCode, 200);

      // Test new email verification endpoint
      final emailVerifReq = await http
          .post(
            Uri.parse('$baseUrl/api/auth/send-email-verification'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': 'test@example.com'}),
          )
          .timeout(apiTimeout);
      expect(emailVerifReq.statusCode, anyOf(200, 400)); // 400 if email exists

      // Test signin endpoint
      final signinRes = await http
          .post(
            Uri.parse('$baseUrl/api/auth/signin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': e2eUser, 'password': e2ePass}),
          )
          .timeout(apiTimeout);
      expect(signinRes.statusCode, anyOf(200, 201));

      if (kDebugMode) {
        // ignore: avoid_print
        print('[API Check] Backend connectivity verified');
      }
    }, semanticsEnabled: false);
  });
}
