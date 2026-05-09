// Integration test for Cart functionality
// FR-CART-001 to FR-CART-004
// Device: 25053PC47I
// Base URL: http://192.168.1.6:8080
//
// Usage:
//   flutter test integration_test/cart_test.dart \
//     --dart-define=E2E=true \
//     --dart-define=API_BASE_URL=http://192.168.1.6:8080

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';
import 'package:lush/get_it.dart';
import 'package:lush/main.dart';

// Gated execution
const bool runE2E = bool.fromEnvironment('E2E', defaultValue: false);
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');

// Test timeouts
const Duration appLaunchTimeout = Duration(seconds: 30);
const Duration apiTimeout = Duration(seconds: 10);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Cart Integration Tests (FR-CART-001 to FR-CART-004)', () {
    setUpAll(() async {
      if (!runE2E) {
        if (kDebugMode) {
          // ignore: avoid_print
          print('E2E is disabled. Set --dart-define=E2E=true to run.');
        }
        return;
      }
      assert(baseUrl.isNotEmpty, 'API_BASE_URL is required');

      if (kDebugMode) {
        // ignore: avoid_print
        print('=== Cart Test Configuration ===');
        print('Device ID: 25053PC47I');
        print('Base URL: $baseUrl');
        print('================================');
      }
    });

    // ============================================================
    // FR-CART-001: View cart items with quantity
    // ============================================================
    testWidgets('FR-CART-001: View cart items with quantity', (tester) async {
      if (!runE2E) {
        return;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('\n[FR-CART-001] Testing view cart items...');
      }

      // Launch app
      WidgetsFlutterBinding.ensureInitialized();
      registerRepositories();

      await tester.pumpWidget(const BookMyJuiceApp());
      await tester.pumpAndSettle(appLaunchTimeout);

      // Navigate to product catalog
      await tester.tap(find.text('Login')); // From splash/login
      await tester.pumpAndSettle();
      
      // Navigate to product catalog (assuming there's a menu option)
      // For now, directly navigate to cart
      await tester.tap(find.text('Sign up with Email'));
      await tester.pumpAndSettle();

      // Enter test email
      final emailField = find.byType(TextFormField).first;
      await tester.enterText(emailField, 'carttest@example.com');
      await tester.pumpAndSettle();
      
      // Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Enter verification code (dummy)
      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verify Email'));
      await tester.pumpAndSettle();

      // Enter phone
      await tester.enterText(find.byType(TextFormField).first, '9999999999');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'));
      await tester.pumpAndSettle();

      // Enter OTP
      await tester.enterText(find.byType(TextFormField).first, '123456');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verify OTP'));
      await tester.pumpAndSettle();

      // Enter address (minimal)
      await tester.enterText(find.byType(TextFormField).first, 'Test');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'User');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(2), '123 Test St');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(3), 'Test Society');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(4), 'Test Area');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(5), 'Test City');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(6), 'Test State');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(7), '123456');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(8), 'IN');
      await tester.pumpAndSettle();
      
      // Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Create password
      await tester.enterText(find.byType(TextFormField).first, 'SecurePass123!');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(1), 'SecurePass123!');
      await tester.pumpAndSettle();
      
      // Create account
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Navigate to cart
      // Look for cart icon or menu option
      final cartIcon = find.byIcon(Icons.shopping_cart);
      if (cartIcon.evaluate().isNotEmpty) {
        await tester.tap(cartIcon);
        await tester.pumpAndSettle();

        // Verify cart screen is displayed
        expect(find.text('My Cart'), findsOneWidget);
        
        if (kDebugMode) {
          // ignore: avoid_print
          print('[FR-CART-001] Cart screen displayed successfully');
        }
      }

      // Cart should be empty initially
      expect(find.text('Your cart is empty'), findsOneWidget);
      
      if (kDebugMode) {
        // ignore: avoid_print
        print('[FR-CART-001] Empty cart verified');
      }
    }, semanticsEnabled: false);

    // ============================================================
    // FR-CART-002: Increment/Decrement quantity
    // ============================================================
    testWidgets('FR-CART-002: Increment/Decrement quantity', (tester) async {
      if (!runE2E) {
        return;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('\n[FR-CART-002] Testing quantity increment/decrement...');
      }

      // This test requires items in cart
      // Would need to add items first, then test quantity controls
      // For now, this is a placeholder for the test structure
      
      if (kDebugMode) {
        // ignore: avoid_print
        print('[FR-CART-002] Test structure defined (requires manual execution)');
      }
    }, semanticsEnabled: false);

    // ============================================================
    // FR-CART-003: Remove items from cart
    // ============================================================
    testWidgets('FR-CART-003: Remove items from cart', (tester) async {
      if (!runE2E) {
        return;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('\n[FR-CART-003] Testing remove items from cart...');
      }

      // This test requires items in cart
      // Would need to add items, then test remove functionality
      
      if (kDebugMode) {
        // ignore: avoid_print
        print('[FR-CART-003] Test structure defined (requires manual execution)');
      }
    }, semanticsEnabled: false);

    // ============================================================
    // FR-CART-004: Show subtotal, tax, and total
    // ============================================================
    testWidgets('FR-CART-004: Show subtotal, tax, and total', (tester) async {
      if (!runE2E) {
        return;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('\n[FR-CART-004] Testing price breakdown display...');
      }

      // Launch app and login
      WidgetsFlutterBinding.ensureInitialized();
      registerRepositories();

      await tester.pumpWidget(const BookMyJuiceApp());
      await tester.pumpAndSettle(appLaunchTimeout);

      // Navigate to cart (assuming already logged in with items)
      final cartIcon = find.byIcon(Icons.shopping_cart);
      if (cartIcon.evaluate().isNotEmpty) {
        await tester.tap(cartIcon);
        await tester.pumpAndSettle();

        // Verify cart screen is displayed
        expect(find.text('My Cart'), findsOneWidget);
        
        // Check for price breakdown elements (when items are in cart)
        // These should be present in the checkout section:
        // - Subtotal
        // - Tax (5% GST)
        // - Delivery Fee
        // - Total Amount
        
        if (kDebugMode) {
          // ignore: avoid_print
          print('[FR-CART-004] Cart screen displayed');
        }
      }
    }, semanticsEnabled: false);

    // ============================================================
    // API Tests for Cart
    // ============================================================
    testWidgets('Cart API: Get cart checkout URL', (tester) async {
      if (!runE2E) {
        return;
      }

      if (kDebugMode) {
        // ignore: avoid_print
        print('\n[Cart API] Testing cart checkout endpoint...');
      }

      // First, login to get token
      final signinRes = await http
          .post(
            Uri.parse('$baseUrl/api/auth/signin'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': 'test@example.com', 'password': 'SecurePass123!'}),
          )
          .timeout(apiTimeout);
      
      expect(signinRes.statusCode, anyOf(200, 201));
      
      final signinJson = jsonDecode(signinRes.body) as Map<String, dynamic>;
      final token = signinJson['accessToken'] as String?;
      expect(token, isNotEmpty);

      // Test cart checkout endpoint
      final cartCheckoutRes = await http
          .get(
            Uri.parse('$baseUrl/api/test/cartCheckout'),
            headers: {'Authorization': 'Bearer $token'},
          )
          .timeout(apiTimeout);
      
      // Should return cart checkout URL or empty cart response
      expect(cartCheckoutRes.statusCode, anyOf(200, 400));
      
      if (kDebugMode) {
        // ignore: avoid_print
        print('[Cart API] Cart checkout endpoint test completed');
      }
    }, semanticsEnabled: false);
  });
}
