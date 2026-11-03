import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:lush/get_it.dart';
import 'package:lush/main.dart';

// Enable with: --dart-define=E2E=true --dart-define=API_BASE_URL=...
const bool runE2E = bool.fromEnvironment('E2E');
const String baseUrl = String.fromEnvironment('API_BASE_URL');

/// On-device checks for the navigation changes: guest entry, the four-item
/// drawer, and the plans page opening from it.
///
/// Explicit `pump` durations are used instead of `pumpAndSettle`: the Home
/// carousel keeps a repeating animation, so settling never happens there.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('guest entry -> drawer -> plans page',
      (WidgetTester tester) async {
    if (!runE2E) return;

    WidgetsFlutterBinding.ensureInitialized();
    registerRepositories();
    if (kDebugMode) {
      // ignore: avoid_print
      print('E2E base URL: $baseUrl');
    }

    await tester.pumpWidget(const BookMyJuiceApp());
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(seconds: 4));

    // ── 0. Normalise: the app may boot on the auth screen or the dashboard.
    final Finder guestOnBoot = find.byKey(const Key('login_continue_as_guest'));
    if (guestOnBoot.evaluate().isNotEmpty) {
      await tester.tap(guestOnBoot);
      await tester.pump(const Duration(seconds: 3));
      await tester.pump(const Duration(seconds: 3));
    }

    // ── 1. The dashboard exposes the drawer handle ──────────────────────────
    expect(
      find.byIcon(Icons.menu_rounded),
      findsOneWidget,
      reason: 'dashboard header should carry the drawer handle',
    );

    // ── 2. The drawer carries exactly the four destinations ─────────────────
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump(const Duration(milliseconds: 800));
    expect(find.byType(Drawer), findsOneWidget, reason: 'drawer should open');

    // Scoped to the drawer: "Profile" is also a bottom-nav destination.
    Finder inDrawer(String text) => find.descendant(
          of: find.byType(Drawer),
          matching: find.text(text),
        );

    expect(inDrawer('Profile'), findsOneWidget);
    expect(inDrawer('Subscription plans'), findsOneWidget);
    expect(inDrawer('Menu'), findsOneWidget);
    // Signed out: the session slot reads "Sign in", not "Logout".
    expect(inDrawer('Sign in'), findsOneWidget);
    expect(inDrawer('Logout'), findsNothing);

    // ── 3. Auth screen offers the guest route ───────────────────────────────
    await tester.tap(inDrawer('Sign in'));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text('Continue with Google'), findsWidgets);
    final Finder guest = find.byKey(const Key('login_continue_as_guest'));
    expect(guest, findsOneWidget,
        reason: 'guest entry missing on the auth screen');

    // ── 4. Guest entry returns to the dashboard ─────────────────────────────
    await tester.tap(guest);
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    expect(
      find.byIcon(Icons.menu_rounded),
      findsOneWidget,
      reason: 'guest entry should land on the dashboard',
    );

    // ── 5. Plans page opens from the drawer ─────────────────────────────────
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.tap(inDrawer('Subscription plans'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 3));
    expect(
      find.text('Subscription Plans'),
      findsOneWidget,
      reason: 'plans page should open from the drawer',
    );
  }, semanticsEnabled: false);
}
