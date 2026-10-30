import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:integration_test/integration_test.dart';

// Gated execution to avoid accidental hits to live/staging
const bool runE2E = bool.fromEnvironment('E2E');
const String baseUrl = String.fromEnvironment('API_BASE_URL');
const String e2eUser = String.fromEnvironment('E2E_USER');
const String e2ePass = String.fromEnvironment('E2E_PASS');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Auth -> Profile -> Retired routes -> Production checkout',
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
        'E2E_USER and E2E_PASS are required',);

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
    final profileRes = await http.get(Uri.parse('$baseUrl/api/v1/user/profile'),
        headers: authHeader,);
    expect(profileRes.statusCode, 200);

    // Validate expected URL host for test mode
    bool hasChargebeeHost(String? url) =>
        url?.contains('bookmyjuice-test.chargebee.com') ?? false;

    // 3) Retired-by-design routes must stay gone (V1 launch freeze).
    //    Chargebee Pricing Pages and the Self-Serve Portal are replaced by native
    //    BMJ screens, so these non-production routes return 410 Gone.
    final pricingRes = await http.get(
      Uri.parse('$baseUrl/api/test/generate_pricing_page_session_url'),
      headers: authHeader,
    );
    expect(pricingRes.statusCode, 410,
        reason: 'Chargebee pricing pages are retired (native screens replace them)');

    final portalRes = await http.get(
      Uri.parse('$baseUrl/api/test/portal'),
      headers: authHeader,
    );
    expect(portalRes.statusCode, 410,
        reason: 'Chargebee Portal is retired (native screens replace it)');

    // 4) One-time checkout must go through the production checkout contract.
    final oneTimeCheckoutRes = await http.post(
      Uri.parse('$baseUrl/api/v2/checkout/with-items'),
      headers: {...authHeader, 'Content-Type': 'application/json'},
      body: jsonEncode({
        'items': [
          {'price_id': 'pineapple300-INR', 'quantity': 1},
        ],
      }),
    );
    // 200 when the account is checkout-ready; 400 when the test account is not
    // (missing Chargebee customer id / unknown price id). Never 404 or 410.
    expect(oneTimeCheckoutRes.statusCode, anyOf(200, 400));
    if (oneTimeCheckoutRes.statusCode == 200) {
      final oneTimeJson =
          jsonDecode(oneTimeCheckoutRes.body) as Map<String, dynamic>;
      final data = oneTimeJson['data'] as Map<String, dynamic>;
      expect(hasChargebeeHost(data['url'] as String?), isTrue);
    }
  }, semanticsEnabled: false,);
}
