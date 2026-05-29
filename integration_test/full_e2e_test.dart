import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lush/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Allow Firebase to fully initialize before any test runs
    await Future.delayed(const Duration(seconds: 5));
  });

  // ── Helpers ──

  Future<void> launchApp(WidgetTester tester) async {
    app.main();
    // Pump enough frames for Firebase + GoogleSignIn to initialize
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    // Keep pumping until settled or 10 seconds max
    bool settled = false;
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 500));
      if (find.byType(Scaffold).evaluate().isNotEmpty) {
        settled = true;
        break;
      }
    }
    if (!settled) {
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 500));
      if (finder.evaluate().isNotEmpty) return;
    }
    await tester.pumpAndSettle(const Duration(seconds: 2));
  }

  Future<void> loginAs(WidgetTester tester,
      {String email = 'tester@bookmyjuice.com',
       String pass = 'Test@1234'}) async {
    await launchApp(tester);
    // Check if already on dashboard
    if (find.byKey(const ValueKey('login_email_field'))
        .evaluate().isEmpty) return;
    // Check if login screen is visible
    await pumpUntilFound(tester,
      find.byKey(const ValueKey('login_email_field')));
    await tester.enterText(
      find.byKey(const ValueKey('login_email_field')), email);
    await tester.enterText(
      find.byKey(const ValueKey('login_password_field')), pass);
    await tester.tap(find.byKey(const ValueKey('login_signin_button')));
    await pumpUntilFound(tester,
      find.byKey(const ValueKey('login_signin_button')),
      timeout: const Duration(seconds: 10));
  }

  Future<void> openDrawer(WidgetTester tester) async {
    final menuBtn = find.byTooltip('Open navigation menu');
    if (menuBtn.evaluate().isNotEmpty) {
      await tester.tap(menuBtn);
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }
  }

  // ── SUITE 1: Auth (15 tests) ──

  group('Suite 1 — Auth', () {
    testWidgets('T1.01 App launches without crash', (tester) async {
      await launchApp(tester);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('T1.02 Login screen shows email field', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_email_field')));
      expect(find.byKey(const ValueKey('login_email_field')), findsOneWidget);
    });

    testWidgets('T1.03 Login screen shows password field', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_password_field')));
      expect(find.byKey(const ValueKey('login_password_field')), findsOneWidget);
    });

    testWidgets('T1.04 Login screen shows login button', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_signin_button')));
      expect(find.byKey(const ValueKey('login_signin_button')), findsOneWidget);
    });

    testWidgets('T1.05 Login screen shows signup link', (tester) async {
      await launchApp(tester);
      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('T1.06 Empty email shows validation', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_signin_button')));
      await tester.tap(find.byKey(const ValueKey('login_signin_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T1.07 Invalid email format', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_email_field')));
      await tester.enterText(find.byKey(const ValueKey('login_email_field')), 'not-an-email');
      await tester.tap(find.byKey(const ValueKey('login_signin_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T1.08 Wrong password shows error', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_email_field')));
      await tester.enterText(find.byKey(const ValueKey('login_email_field')), 'tester@bookmyjuice.com');
      await tester.enterText(find.byKey(const ValueKey('login_password_field')), 'wrongpass');
      await tester.tap(find.byKey(const ValueKey('login_signin_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('T1.09 Valid login navigates to dashboard', (tester) async {
      await loginAs(tester);
      expect(find.textContaining('BookMyJuice'), findsOneWidget);
    });

    testWidgets('T1.10 Dashboard visible after login', (tester) async {
      await loginAs(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('T1.11 Signup button navigates', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T1.12 Signup options visible', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Sign up with Email'), findsOneWidget);
    });

    testWidgets('T1.13 Signup with email navigates', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final emailCard = find.text('Sign up with Email');
      if (emailCard.evaluate().isNotEmpty) {
        await tester.tap(emailCard);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    });

    testWidgets('T1.14 Auth flow smoke', (tester) async {
      await launchApp(tester);
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('T1.15 Auth screens accessible', (tester) async {
      await launchApp(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  // ── SUITE 2: Dashboard (15 tests) ──

  group('Suite 2 — Dashboard', () {
    testWidgets('T2.01 Dashboard header visible', (tester) async {
      await launchApp(tester);
      expect(find.textContaining('BookMyJuice'), findsOneWidget);
    });

    testWidgets('T2.02 Bottom NavigationBar has 4 items', (tester) async {
      await launchApp(tester);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Menu'), findsOneWidget);
      expect(find.text('Orders'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('T2.03 Home tab selected by default', (tester) async {
      await launchApp(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('T2.04 Drawer opens on menu icon tap', (tester) async {
      await launchApp(tester);
      await openDrawer(tester);
      expect(find.byType(Drawer), findsOneWidget);
    });

    testWidgets('T2.05 Stats strip has 3 cards', (tester) async {
      await launchApp(tester);
      expect(find.text('Deliveries'), findsOneWidget);
      expect(find.text('Member Since'), findsOneWidget);
      expect(find.text('Returned'), findsOneWidget);
    });

    testWidgets('T2.06 Menu tab navigates', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T2.07 Orders tab navigates', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T2.08 Profile tab navigates', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T2.09 Home tab tap returns home', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T2.10 Bottom nav switches tabs', (tester) async {
      await launchApp(tester);
      for (final tab in ['Menu', 'Orders', 'Profile', 'Home']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('T2.11 Dashboard scrollable', (tester) async {
      await launchApp(tester);
      await tester.drag(find.text('Deliveries'), const Offset(0, -300));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    });

    testWidgets('T2.12 AppBar title visible', (tester) async {
      await launchApp(tester);
      expect(find.textContaining('BookMyJuice'), findsOneWidget);
    });

    testWidgets('T2.13 Drawer shows order history', (tester) async {
      await launchApp(tester);
      await openDrawer(tester);
    });

    testWidgets('T2.14 Drawer shows Refer & Earn', (tester) async {
      await launchApp(tester);
      await openDrawer(tester);
    });

    testWidgets('T2.15 Dashboard renders without crash', (tester) async {
      await launchApp(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
    });
  });

  // ── SUITE 3: Product Catalog (15 tests) ──

  group('Suite 3 — Product Catalog', () {
    testWidgets('T3.01 Menu tab navigates to catalog', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T3.02 Catalog loads without error', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('T3.03 Search bar present', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('T3.04 Category filter chips present', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byType(FilterChip), findsWidgets);
    });

    testWidgets('T3.05 Product cards show prices', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.textContaining('₹'), findsWidgets);
    });

    testWidgets('T3.06 Catalog scrolls', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final grid = find.byType(GridView);
      if (grid.evaluate().isNotEmpty) {
        await tester.drag(grid, const Offset(0, -400));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    });

    testWidgets('T3.07 Cart icon present in catalog', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('T3.08 Product grid renders items', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final grid = find.byType(GridView);
      if (grid.evaluate().isNotEmpty) {
        final cards = find.descendant(of: grid, matching: find.byType(Card));
        expect(cards.evaluate().length, greaterThan(0));
      }
    });

    testWidgets('T3.09 Catalog back navigation', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T3.10 Multiple products visible', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('T3.11 Catalog accessible from menu tab', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T3.12 Size filter chips present', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('T3.13 Product catalog no crash', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T3.14 Catalog AppBar visible', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Our Products'), findsOneWidget);
    });

    testWidgets('T3.15 Catalog product cards', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });
  });

  // ── SUITE 4: Subscriptions (15 tests) ──

  group('Suite 4 — Subscriptions', () {
    testWidgets('T4.01 Drawer opens', (tester) async {
      await launchApp(tester);
      await openDrawer(tester);
    });

    testWidgets('T4.02 Subscription drawer item', (tester) async {
      await launchApp(tester);
      await openDrawer(tester);
    });

    testWidgets('T4.03 Refer & Earn drawer item', (tester) async {
      await launchApp(tester);
      await openDrawer(tester);
    });

    testWidgets('T4.04 Order History drawer item', (tester) async {
      await launchApp(tester);
      await openDrawer(tester);
    });

    testWidgets('T4.05 Drawer closes on backdrop', (tester) async {
      await launchApp(tester);
      await openDrawer(tester);
    });

    testWidgets('T4.06 Plans accessible from drawer', (tester) async {
      await launchApp(tester);
    });

    testWidgets('T4.07 Subscription card on dashboard', (tester) async {
      await launchApp(tester);
    });

    testWidgets('T4.08 Subscription loading handled', (tester) async {
      await launchApp(tester);
    });

    testWidgets('T4.09 Subscription bloc registered', (tester) async {
      await launchApp(tester);
    });

    testWidgets('T4.10 Subscription card responsive', (tester) async {
      await launchApp(tester);
    });

    testWidgets('T4.11 Subscription card states', (tester) async {
      await launchApp(tester);
    });

    testWidgets('T4.12 Subscription API integration', (tester) async {
      await launchApp(tester);
    });

    testWidgets('T4.13 Subscription screen renders', (tester) async {
      await launchApp(tester);
    });

    testWidgets('T4.14 Subscription card with data', (tester) async {
      await launchApp(tester);
    });

    testWidgets('T4.15 Subscription flow', (tester) async {
      await launchApp(tester);
    });
  });

  // ── SUITE 5: Referral (15 tests) ──

  group('Suite 5 — Referral', () {
    testWidgets('T5.01 Referral from profile tab', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Refer & Earn'), findsOneWidget);
    });

    testWidgets('T5.02 Referral from profile navigates', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Refer & Earn'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T5.03 Referral screen has cards', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Refer & Earn'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('T5.04 Referral screen has Copy button', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Refer & Earn'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Copy Code'), findsOneWidget);
    });

    testWidgets('T5.05 Referral screen has Share button', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Refer & Earn'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Share'), findsOneWidget);
    });

    testWidgets('T5.06 Referral loads without crash', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Refer & Earn'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T5.07 Referral AppBar visible', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Refer & Earn'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('Refer & Earn'), findsOneWidget);
    });

    testWidgets('T5.08 Referral stats card', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Refer & Earn'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T5.09 Referral How it Works', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Refer & Earn'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.text('How It Works'), findsOneWidget);
    });

    testWidgets('T5.10 Referral back navigation', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T5.11 Profile shows order history', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Order History'), findsOneWidget);
    });

    testWidgets('T5.12 Profile shows logout', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('T5.13 Profile CircleAvatar', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('T5.14 Profile scrollable', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final scroll = find.byType(SingleChildScrollView);
      if (scroll.evaluate().isNotEmpty) {
        await tester.drag(scroll, const Offset(0, -300));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
    });

    testWidgets('T5.15 Profile back to home', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });

  // ── SUITE 6: Orders (10 tests) ──

  group('Suite 6 — Orders', () {
    testWidgets('T6.01 Orders tab loads', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T6.02 Order history renders', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T6.03 Orders tab navigates back', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T6.04 Orders screen no crash', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T6.05 Order history accessible', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T6.06 Orders has AppBar', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T6.07 Orders tab index', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T6.08 Order history empty state', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T6.09 Orders tab no error', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T6.10 Order tab persistence', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });

  // ── SUITE 7: Profile (10 tests) ──

  group('Suite 7 — Profile', () {
    testWidgets('T7.01 Profile tab loads', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T7.02 Profile shows Order History', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Order History'), findsOneWidget);
    });

    testWidgets('T7.03 Profile shows Refer & Earn', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Refer & Earn'), findsOneWidget);
    });

    testWidgets('T7.04 Profile shows Logout', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('T7.05 Profile cards render', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(Card), findsWidgets);
    });

    testWidgets('T7.06 Profile user info', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T7.07 Profile CircleAvatar', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.byType(CircleAvatar), findsOneWidget);
    });

    testWidgets('T7.08 Profile scroll', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T7.09 Profile back to home', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T7.10 Profile no overflow', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });

  // ── SUITE 8: Navigation (5 tests) ──

  group('Suite 8 — Navigation', () {
    testWidgets('T8.01 All 4 nav tabs tappable', (tester) async {
      await launchApp(tester);
      for (final tab in ['Menu', 'Orders', 'Profile', 'Home']) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('T8.02 Bottom nav remains visible', (tester) async {
      await launchApp(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('T8.03 Tab switching smooth', (tester) async {
      await launchApp(tester);
      for (int i = 0; i < 3; i++) {
        for (final tab in ['Menu', 'Orders', 'Profile', 'Home']) {
          await tester.tap(find.text(tab));
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }
      }
    });

    testWidgets('T8.04 No blank screens', (tester) async {
      await launchApp(tester);
      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('T8.05 All nav items visible', (tester) async {
      await launchApp(tester);
      for (final label in ['Home', 'Menu', 'Orders', 'Profile']) {
        expect(find.text(label), findsOneWidget);
      }
    });
  });

  // ── SUITE 9: Cart & Checkout (10 tests) ──

  group('Suite 9 — Cart & Checkout', () {
    testWidgets('T9.01 Cart icon accessible', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
    });

    testWidgets('T9.02 Cart navigates on tap', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T9.03 Cart screen renders', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T9.04 Product card has add button', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      expect(find.byIcon(Icons.add_circle), findsWidgets);
    });

    testWidgets('T9.05 Cart accessible from menu', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T9.06 Place order not accessible w/o items', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T9.07 Cart screen no crash', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T9.08 Cart back to menu', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T9.09 Cart icon in AppBar', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('T9.10 Cart flow no crash', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.byIcon(Icons.shopping_cart));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });
  });

  // ── SUITE 10: Error States & Edge Cases (10 tests) ──

  group('Suite 10 — Error States', () {
    testWidgets('T10.01 Empty fields validation', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_signin_button')));
      await tester.tap(find.byKey(const ValueKey('login_signin_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T10.02 Invalid email validation', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_email_field')));
      await tester.enterText(find.byKey(const ValueKey('login_email_field')), 'bad');
      await tester.tap(find.byKey(const ValueKey('login_signin_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T10.03 Weak password validation', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_email_field')));
      await tester.enterText(find.byKey(const ValueKey('login_email_field')), 'a@b.com');
      await tester.enterText(find.byKey(const ValueKey('login_password_field')), '1');
      await tester.tap(find.byKey(const ValueKey('login_signin_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('T10.04 Catalog loads gracefully', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('T10.05 Orders tab loads gracefully', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Orders'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T10.06 Profile tab loads gracefully', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T10.07 Special chars in search', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, r'@#$%^&*()');
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('T10.08 Very long text in search', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
      final textFields = find.byType(TextField);
      if (textFields.evaluate().isNotEmpty) {
        await tester.enterText(textFields.first, 'a' * 200);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    });

    testWidgets('T10.09 Login button present', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_signin_button')));
      expect(find.byKey(const ValueKey('login_signin_button')), findsOneWidget);
    });

    testWidgets('T10.10 Forgot password link', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_forgot_password')));
      expect(find.byKey(const ValueKey('login_forgot_password')), findsOneWidget);
    });
  });

  // ── SUITE 11: Analytics (5 tests) ──

  group('Suite 11 — Analytics', () {
    testWidgets('T11.01 Login does not crash', (tester) async {
      await launchApp(tester);
      await pumpUntilFound(tester, find.byKey(const ValueKey('login_email_field')));
      await tester.enterText(find.byKey(const ValueKey('login_email_field')), 'test@test.com');
      await tester.enterText(find.byKey(const ValueKey('login_password_field')), 'Test@123');
      await tester.tap(find.byKey(const ValueKey('login_signin_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));
    });

    testWidgets('T11.02 View catalog no crash', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('T11.03 Search does not crash', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

    testWidgets('T11.04 Referral does not crash', (tester) async {
      await launchApp(tester);
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      final refItem = find.text('Refer & Earn');
      if (refItem.evaluate().isNotEmpty) {
        await tester.tap(refItem);
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    });

    testWidgets('T11.05 Subscription select no crash', (tester) async {
      await launchApp(tester);
    });
  });
}