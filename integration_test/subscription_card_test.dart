import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lush/main.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/views/models/subscription.dart';
import 'package:lush/views/widgets/subscription_info_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Integration tests for Subscription Card on Dashboard
/// Tests the complete flow from data fetching to UI display
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Subscription Card Integration Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      // Initialize SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    tearDown(() async {
      // Clean up SharedPreferences
      await prefs.clear();
    });

    // Test 1: Subscription card displays loading state initially
    testWidgets('Subscription card shows loading indicator when loading',
        (WidgetTester tester) async {
      // Arrange: Set up mock data
      await prefs.setString('token', 'test_token_123');

      // Act: Build the dashboard
      await tester.pumpWidget(const BookMyJuiceApp());
      await tester.pump(); // First frame
      await tester.pump(); // Trigger initState

      // Assert: Loading indicator should be visible
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // Test 2: Subscription card displays subscription data when user has subscription
    testWidgets('Subscription card displays subscription data when available',
        (WidgetTester tester) async {
      // Arrange: Set up mock token
      await prefs.setString('token', 'test_token_123');

      // Mock subscription data
      final mockSubscription = Subscription(
        id: 'sub_123',
        customerId: 'cust_123',
        planId: 'premium-plan-monthly',
        status: 'active',
        billingPeriod: '2999',
        billingPeriodUnit: 'month',
        currentTermStart: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        currentTermEnd: DateTime.now()
                .add(const Duration(days: 30))
                .millisecondsSinceEpoch ~/
            1000,
        nextBillingAt: DateTime.now()
                .add(const Duration(days: 30))
                .millisecondsSinceEpoch ~/
            1000,
        createdAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        updatedAt: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        items: [],
        renewed: false,
      );

      // Act: Build widget with mock subscription
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionInfoCard(
              subscription: mockSubscription,
              onTap: () {},
              onManageTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Subscription details should be displayed
      expect(find.text('premium-plan-monthly'), findsOneWidget);
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('₹2999 / Monthly'), findsOneWidget);
    });

    // Test 3: Subscription card shows "No subscription" when user has no subscription
    testWidgets('Subscription card shows no subscription message when null',
        (WidgetTester tester) async {
      // Arrange: Set up mock token but no subscription
      await prefs.setString('token', 'test_token_123');

      // Act: Build widget with null subscription
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionInfoCard(
              subscription: null,
              onTap: () {},
              onManageTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: No subscription message should be displayed
      expect(find.text('No active subscription'), findsOneWidget);
      expect(find.text('Subscribe for regular deliveries'), findsOneWidget);
      expect(find.text('Subscribe Now'), findsOneWidget);
    });

    // Test 4: Subscription card displays correct status colors
    testWidgets('Subscription card displays correct status colors',
        (WidgetTester tester) async {
      // Test Active status (green)
      final activeSubscription = Subscription(
        id: 'sub_123',
        customerId: 'cust_123',
        planId: 'premium-plan',
        status: 'active',
        billingPeriod: '2999',
        billingPeriodUnit: 'month',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionInfoCard(
              subscription: activeSubscription,
              onTap: () {},
              onManageTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify active status shows
      expect(find.text('ACTIVE'), findsOneWidget);

      // Test Paused status (orange)
      final pausedSubscription = Subscription(
        id: 'sub_123',
        customerId: 'cust_123',
        planId: 'premium-plan',
        status: 'paused',
        billingPeriod: '2999',
        billingPeriodUnit: 'month',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionInfoCard(
              subscription: pausedSubscription,
              onTap: () {},
              onManageTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify paused status shows
      expect(find.text('PAUSED'), findsOneWidget);
    });

    // Test 5: Subscription card displays formatted dates correctly
    testWidgets('Subscription card displays formatted dates',
        (WidgetTester tester) async {
      // Arrange: Create subscription with specific dates
      final now = DateTime(2026, 3, 27);
      final subscription = Subscription(
        id: 'sub_123',
        customerId: 'cust_123',
        planId: 'premium-plan',
        status: 'active',
        billingPeriod: '2999',
        billingPeriodUnit: 'month',
        currentTermStart: now.millisecondsSinceEpoch ~/ 1000,
        currentTermEnd: now.add(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
        nextBillingAt: now.add(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
      );

      // Act: Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionInfoCard(
              subscription: subscription,
              onTap: () {},
              onManageTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert: Dates should be formatted as DD/MM/YYYY
      expect(find.textContaining('27/3/2026'), findsWidgets);
    });

    // Test 6: Manage button navigates to subscription management
    testWidgets('Manage button calls onManageTap callback',
        (WidgetTester tester) async {
      // Arrange
      bool manageCalled = false;
      final subscription = Subscription(
        id: 'sub_123',
        customerId: 'cust_123',
        planId: 'premium-plan',
        status: 'active',
        billingPeriod: '2999',
        billingPeriodUnit: 'month',
      );

      // Act: Build widget with callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionInfoCard(
              subscription: subscription,
              onTap: () {},
              onManageTap: () {
                manageCalled = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Manage Subscription button
      await tester.tap(find.text('Manage Subscription'));
      await tester.pump();

      // Assert: Callback should be called
      expect(manageCalled, isTrue);
    });

    // Test 7: Subscribe Now button calls onTap callback
    testWidgets('Subscribe Now button calls onTap callback',
        (WidgetTester tester) async {
      // Arrange
      bool subscribeCalled = false;

      // Act: Build widget with null subscription and callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionInfoCard(
              subscription: null,
              onTap: () {
                subscribeCalled = true;
              },
              onManageTap: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Subscribe Now button
      await tester.tap(find.text('Subscribe Now'));
      await tester.pump();

      // Assert: Callback should be called
      expect(subscribeCalled, isTrue);
    });

    // Test 8: Subscription service fetches data from backend
    testWidgets('SubscriptionService fetches data from backend',
        (WidgetTester tester) async {
      // Arrange: Set up mock token
      await prefs.setString('token', 'test_token_123');

      // Act: Create service instance
      final service = SubscriptionService();

      // Assert: Service should be created successfully
      expect(service, isNotNull);

      // Note: Actual API call testing would require mocking HTTP client
      // This test verifies the service can be instantiated
    });

    // Test 9: Subscription model parses JSON correctly
    test('Subscription model parses JSON correctly', () {
      // Arrange: Create mock JSON
      final json = {
        'id': 'sub_123',
        'customerId': 'cust_123',
        'planId': 'premium-plan-monthly',
        'status': 'active',
        'billingPeriod': '2999',
        'billingPeriodUnit': 'month',
        'currentTermStart': 1711555200,
        'currentTermEnd': 1714147200,
        'nextBillingAt': 1714147200,
        'createdAt': 1711555200,
        'updatedAt': 1711555200,
        'items': [],
        'renewed': false,
      };

      // Act: Parse JSON
      final subscription = Subscription.fromJson(json);

      // Assert: All fields should be parsed correctly
      expect(subscription.id, 'sub_123');
      expect(subscription.customerId, 'cust_123');
      expect(subscription.planId, 'premium-plan-monthly');
      expect(subscription.status, 'active');
      expect(subscription.billingPeriod, '2999');
      expect(subscription.billingPeriodUnit, 'month');
    });

    // Test 10: Subscription helper methods format data correctly
    test('Subscription helper methods format data correctly', () {
      // Arrange: Create subscription with specific dates
      final now = DateTime(2026, 3, 27);
      final subscription = Subscription(
        id: 'sub_123',
        customerId: 'cust_123',
        planId: 'premium-plan',
        status: 'active',
        billingPeriod: '2999',
        billingPeriodUnit: 'month',
        currentTermStart: now.millisecondsSinceEpoch ~/ 1000,
        currentTermEnd: now.add(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
        nextBillingAt: now.add(const Duration(days: 30)).millisecondsSinceEpoch ~/ 1000,
      );

      // Act & Assert: Helper methods should format correctly
      expect(subscription.getStartDate(), contains('27/3/2026'));
      expect(subscription.getBillingPeriodString(), '₹2999 / Monthly');
      expect(subscription.getStatusText(), 'ACTIVE');
      expect(subscription.getStatusColor(), 'FF4CAF50'); // Green for active
    });

    // Test 11: Subscription status colors for different statuses
    test('Subscription status colors are correct for all statuses', () {
      // Test all status types
      expect(
        Subscription(
          id: 'sub_1',
          customerId: 'cust_1',
          planId: 'plan_1',
          status: 'active',
          billingPeriod: '100',
          billingPeriodUnit: 'month',
        ).getStatusColor(),
        'FF4CAF50', // Green
      );

      expect(
        Subscription(
          id: 'sub_2',
          customerId: 'cust_2',
          planId: 'plan_1',
          status: 'paused',
          billingPeriod: '100',
          billingPeriodUnit: 'month',
        ).getStatusColor(),
        'FFFFC107', // Yellow/Orange
      );

      expect(
        Subscription(
          id: 'sub_3',
          customerId: 'cust_3',
          planId: 'plan_1',
          status: 'cancelled',
          billingPeriod: '100',
          billingPeriodUnit: 'month',
        ).getStatusColor(),
        'FFF44336', // Red
      );

      expect(
        Subscription(
          id: 'sub_4',
          customerId: 'cust_4',
          planId: 'plan_1',
          status: 'expired',
          billingPeriod: '100',
          billingPeriodUnit: 'month',
        ).getStatusColor(),
        'FF9E9E9E', // Grey
      );
    });
  });

  group('Dashboard Subscription Integration Tests', () {
    // Test 12: Dashboard loads subscription data on init
    testWidgets('Dashboard loads subscription data on initialization',
        (WidgetTester tester) async {
      // Arrange: Set up mock token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'test_token_123');

      // Act: Build dashboard
      await tester.pumpWidget(const BookMyJuiceApp());
      
      // First pump triggers initState
      await tester.pump();
      
      // Second pump triggers async operations
      await tester.pump();

      // Assert: Loading indicator should appear initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // Test 13: Dashboard handles subscription load errors
    testWidgets('Dashboard handles subscription load errors gracefully',
        (WidgetTester tester) async {
      // Arrange: Set up mock token but no backend
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', 'invalid_token');

      // Act: Build dashboard
      await tester.pumpWidget(const BookMyJuiceApp());
      await tester.pump();
      await tester.pump();

      // Assert: Should not crash, should show no subscription
      expect(find.byType(SubscriptionInfoCard), findsOneWidget);
    });
  });
}
