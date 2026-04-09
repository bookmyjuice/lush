import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';

// Gated execution to avoid accidental hits to live/staging
const bool runE2E = bool.fromEnvironment('E2E', defaultValue: false);
const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
const String e2eUser = String.fromEnvironment('E2E_USER', defaultValue: '');
const String e2ePass = String.fromEnvironment('E2E_PASS', defaultValue: '');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Auth → Profile → Pricing URLs → Checkout → Portal',
      (tester) async {
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

    // 1) Sign in
    final signinRes = await http.post(
      Uri.parse('$baseUrl/api/auth/signin'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': e2eUser, 'password': e2ePass}),
    );
    expect(signinRes.statusCode, anyOf(200, 201));
    final signinJson = jsonDecode(signinRes.body) as Map<String, dynamic>;
    final token = signinJson['accessToken'] as String?;
    expect(token, isNotEmpty);

    final authHeader = {'Authorization': 'Bearer $token'};

    // 2) Fetch profile (sanity check token)
    final profileRes = await http.get(Uri.parse('$baseUrl/api/test/user'),
        headers: authHeader);
    expect(profileRes.statusCode, 200);

    // 3) Pricing page session URLs
    final pricingRes = await http.get(
      Uri.parse('$baseUrl/api/test/generate_pricing_page_session_url'),
      headers: authHeader,
    );
    expect(pricingRes.statusCode, 200);
    final pricingJson = jsonDecode(pricingRes.body) as Map<String, dynamic>;

    // Validate expected URL host for test mode
    bool hasChargebeeHost(String? url) =>
        url?.contains('bookmyjuice-test.chargebee.com') ?? false;

    final premiumUrl = (pricingJson['premium']?['url']) as String?;
    final signatureUrl = (pricingJson['signature']?['url']) as String?;
    final delightUrl = (pricingJson['delight']?['url']) as String?;

    expect(hasChargebeeHost(premiumUrl), isTrue);
    expect(hasChargebeeHost(signatureUrl), isTrue);
    expect(hasChargebeeHost(delightUrl), isTrue);

    // 4) One-time checkout page URL + content
    final oneTimeCheckoutRes = await http.get(
      Uri.parse('$baseUrl/api/test/oneTimeCheckoutPageUrl'),
      headers: authHeader,
    );
    expect(oneTimeCheckoutRes.statusCode, 200);
    final oneTimeJson =
        jsonDecode(oneTimeCheckoutRes.body) as Map<String, dynamic>;
    final hostedUrl = oneTimeJson['url'] as String?;
    expect(hasChargebeeHost(hostedUrl), isTrue);

    // Validate content structure
    final content = oneTimeJson['content'] as Map<String, dynamic>?;
    expect(content, isNotNull);
    final customer = content?['customer'] as Map<String, dynamic>?;
    expect(customer?['id'], isNotEmpty);
    expect(customer?['email'], isNotEmpty);
    final items = content?['items'] as List?;
    expect(items, isNotEmpty);
    expect((items?.first as Map?)?['item_price_id'], isNotEmpty);
    expect((items?.first as Map?)?['quantity'], isNotNull);

    // 5) Cart checkout page URL + content
    final cartCheckoutRes = await http.get(
      Uri.parse('$baseUrl/api/test/cartCheckout'),
      headers: authHeader,
    );
    expect(cartCheckoutRes.statusCode, 200);
    final cartJson = jsonDecode(cartCheckoutRes.body) as Map<String, dynamic>;
    final cartUrl = cartJson['url'] as String?;
    expect(hasChargebeeHost(cartUrl), isTrue);

    // Validate cart response has required structure
    expect(cartJson['id'], isNotEmpty);
    expect(cartJson['type'], equals('checkout_one_time_for_items'));
    expect(cartJson['state'], equals('created'));

    // 6) Self-serve portal session
    final portalRes = await http.get(
      Uri.parse('$baseUrl/api/test/portal'),
      headers: authHeader,
    );
    expect(portalRes.statusCode, 200);
    final portalJson = jsonDecode(portalRes.body) as Map<String, dynamic>;
    final accessUrl = portalJson['access_url'] as String?;
    expect(hasChargebeeHost(accessUrl), isTrue);
  }, semanticsEnabled: false);
}
