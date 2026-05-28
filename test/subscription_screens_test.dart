/// Widget tests for Subscription screens.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/get_it.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/views/models/subscription_plan_catalog.dart';
import 'package:lush/views/models/subscription_selection.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/views/screens/subscription/subscription_family_screen.dart';
import 'package:lush/views/screens/subscription/subscription_plan_screen.dart';
import 'package:lush/views/screens/subscription/subscription_schedule_screen.dart';
import 'package:lush/views/screens/subscription/subscription_summary_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionService extends Mock implements SubscriptionService {}
class MockUserRepository extends Mock implements UserRepository {}

User createTestUser() {
  return User(id: 'test-user-id', email: 'test@example.com', phone: '9876543210',
    role: 'user', firstName: 'Test', lastName: 'User', password: 'password',
    address: '123 Test St', city: 'Mumbai', country: 'IN',
    extendedAddr: '', extendedAddr2: '', state: 'Maharashtra', zip: '400001');
}

SubscriptionPlanCatalog buildTestCatalog({String itemId = 'bmj-delight-200ml',
  String name = 'Delight 200ml', String family = 'delight', String size = '200ml',
  String planType = 'generic', String? defaultJuice, int weeklyPricePaise = 69900,
  int monthlyPricePaise = 249900}) {
  return SubscriptionPlanCatalog(itemId: itemId, name: name, family: family, size: size,
    planType: planType, defaultJuice: defaultJuice, metadata: {'size': size, 'plan_type': planType, if (defaultJuice != null) 'default_juice': defaultJuice},
    prices: [
      SubscriptionPriceOption(itemPriceId: '${itemId}-weekly', period: 'weekly', priceInPaise: weeklyPricePaise, bottleCount: 6),
      SubscriptionPriceOption(itemPriceId: '${itemId}-monthly', period: 'monthly', priceInPaise: monthlyPricePaise, bottleCount: 24),
    ]);
}

void setLargeViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 4000);
  tester.view.devicePixelRatio = 1.0;
}

Widget buildTestApp(Widget child, SubscriptionBloc bloc) {
  return ScreenUtilInit(designSize: const Size(375, 812), minTextAdapt: true,
    builder: (_, __) => MaterialApp(
      home: BlocProvider<SubscriptionBloc>.value(value: bloc, child: child),
    ));
}

void main() {
  late MockSubscriptionService mockService;
  late MockUserRepository mockUserRepo;
  late SubscriptionBloc bloc;

  setUpAll(() => TestWidgetsFlutterBinding.ensureInitialized());

  setUp(() {
    mockService = MockSubscriptionService();
    mockUserRepo = MockUserRepository();
    if (getIt.isRegistered<UserRepository>()) getIt.unregister<UserRepository>();
    getIt.registerSingleton<UserRepository>(mockUserRepo);
    when(() => mockUserRepo.user).thenReturn(createTestUser());
    when(() => mockUserRepo.isInternetAvailable()).thenAnswer((_) async => true);
    bloc = SubscriptionBloc(subscriptionService: mockService);
  });

  tearDown(() {
    bloc.close();
    if (getIt.isRegistered<UserRepository>()) getIt.unregister<UserRepository>();
  });

  group('SubscriptionFamilyScreen', () {
    testWidgets('shows loading indicator', (tester) async {
      await tester.pumpWidget(buildTestApp(const SubscriptionFamilyScreen(), bloc));
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows family cards with CatalogLoaded', (tester) async {
      setLargeViewport(tester);
      bloc.emit(SubscriptionCatalogLoaded(plans: [
        buildTestCatalog(itemId: 'bmj-delight-200ml', family: 'delight'),
        buildTestCatalog(itemId: 'bmj-signature-200ml', family: 'signature'),
        buildTestCatalog(itemId: 'bmj-premium-200ml', family: 'premium'),
      ]));
      await tester.pumpWidget(buildTestApp(const SubscriptionFamilyScreen(), bloc));
      await tester.pumpAndSettle();
      expect(find.text('DELIGHT'), findsOneWidget);
      expect(find.text('SIGNATURE'), findsOneWidget);
      expect(find.text('PREMIUM'), findsOneWidget);
    });

    testWidgets('shows error + retry on CatalogError', (tester) async {
      bloc.emit(const SubscriptionCatalogError(message: 'Failed to load'));
      await tester.pumpWidget(buildTestApp(const SubscriptionFamilyScreen(), bloc));
      await tester.pumpAndSettle();
      expect(find.text('Failed to load plans'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });
  });

  group('SubscriptionPlanScreen', () {
    testWidgets('shows size cards for generic plans', (tester) async {
      setLargeViewport(tester);
      bloc.emit(SubscriptionCatalogLoaded(plans: [
        buildTestCatalog(itemId: 'bmj-delight-200ml', family: 'delight', size: '200ml'),
        buildTestCatalog(itemId: 'bmj-delight-300ml', family: 'delight', size: '300ml'),
        buildTestCatalog(itemId: 'bmj-delight-500ml', family: 'delight', size: '500ml'),
      ]));
      await tester.pumpWidget(buildTestApp(const SubscriptionPlanScreen(family: 'delight'), bloc));
      await tester.pumpAndSettle();
      expect(find.text('Choose a Plan'), findsOneWidget);
      expect(find.text('200ml'), findsOneWidget);
      expect(find.text('300ml'), findsOneWidget);
      expect(find.text('500ml'), findsOneWidget);
    });

    testWidgets('shows juice cards in Section B', (tester) async {
      setLargeViewport(tester);
      bloc.emit(SubscriptionCatalogLoaded(plans: [
        buildTestCatalog(itemId: 'bmj-delight-200ml', family: 'delight', size: '200ml'),
        buildTestCatalog(itemId: 'bmj-delight-mix-punch', name: 'mix-punch', family: 'delight',
          size: '200ml', planType: 'juice_specific', defaultJuice: 'mix-punch'),
      ]));
      await tester.pumpWidget(buildTestApp(const SubscriptionPlanScreen(family: 'delight'), bloc));
      await tester.pumpAndSettle();
      expect(find.text('Start with a Favourite'), findsOneWidget);
      expect(find.text('Mix Punch'), findsOneWidget);
    });

    testWidgets('duration toggle changes displayed price', (tester) async {
      setLargeViewport(tester);
      bloc.emit(SubscriptionCatalogLoaded(plans: [
        buildTestCatalog(itemId: 'bmj-delight-200ml', family: 'delight', size: '200ml',
          weeklyPricePaise: 69900, monthlyPricePaise: 249900),
      ]));
      await tester.pumpWidget(buildTestApp(const SubscriptionPlanScreen(family: 'delight'), bloc));
      await tester.pumpAndSettle();
      expect(find.text('₹699/week'), findsOneWidget);
      await tester.tap(find.text('Monthly'));
      await tester.pumpAndSettle();
      expect(find.text('₹2499/month'), findsOneWidget);
    });
  });

  group('SubscriptionScheduleScreen', () {
    final emptySel = SubscriptionSelection(itemId: 'bmj-d-200ml', itemPriceId: 'bmj-d-200ml-w',
      family: 'delight', size: '200ml', period: 'weekly', priceInPaise: 69900, daySchedule: {});

    testWidgets('shows 6 day rows, no Sunday', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildTestApp(SubscriptionScheduleScreen(selection: emptySel), bloc));
      await tester.pumpAndSettle();
      expect(find.text('Monday'), findsOneWidget);
      expect(find.text('Tuesday'), findsOneWidget);
      expect(find.text('Wednesday'), findsOneWidget);
      expect(find.text('Thursday'), findsOneWidget);
      expect(find.text('Friday'), findsOneWidget);
      expect(find.text('Saturday'), findsOneWidget);
      expect(find.text('Sunday'), findsNothing);
    });

    testWidgets('Same Everyday checked by default', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildTestApp(SubscriptionScheduleScreen(selection: emptySel), bloc));
      await tester.pumpAndSettle();
      expect(find.text('Same Everyday'), findsOneWidget);
      final cb = tester.widget<CheckboxListTile>(find.byType(CheckboxListTile).first);
      expect(cb.value, true);
    });

    testWidgets('CTA disabled when incomplete', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildTestApp(SubscriptionScheduleScreen(selection: emptySel), bloc));
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Review Order').last);
      expect(btn.onPressed, isNull);
    });

    testWidgets('CTA enabled when all filled', (tester) async {
      setLargeViewport(tester);
      final filled = emptySel.copyWith(daySchedule: {
        'monday': 'mix-punch', 'tuesday': 'carrot-juice', 'wednesday': 'mix-punch',
        'thursday': 'carrot-juice', 'friday': 'mix-punch', 'saturday': 'carrot-juice'});
      await tester.pumpWidget(buildTestApp(SubscriptionScheduleScreen(selection: filled), bloc));
      await tester.pumpAndSettle();
      final btn = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Review Order').last);
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('juice_specific: dropdowns pre-filled', (tester) async {
      setLargeViewport(tester);
      final juiceSel = SubscriptionSelection(itemId: 'bmj-d-mix', itemPriceId: 'bmj-d-mix-w',
        family: 'delight', size: '200ml', period: 'weekly', priceInPaise: 79900,
        defaultJuice: 'mix-punch', daySchedule: {
          'monday': 'mix-punch', 'tuesday': 'mix-punch', 'wednesday': 'mix-punch',
          'thursday': 'mix-punch', 'friday': 'mix-punch', 'saturday': 'mix-punch'});
      await tester.pumpWidget(buildTestApp(SubscriptionScheduleScreen(selection: juiceSel), bloc));
      await tester.pumpAndSettle();
      expect(find.text('Mix Punch'), findsWidgets);
    });
  });

  group('SubscriptionSummaryScreen', () {
    final summary = SubscriptionSelection(itemId: 'bmj-d-200ml', itemPriceId: 'bmj-d-200ml-w',
      family: 'delight', size: '200ml', period: 'weekly', priceInPaise: 69900, daySchedule: {
        'monday': 'mix-punch', 'tuesday': 'carrot-juice', 'wednesday': 'mix-punch',
        'thursday': 'carrot-juice', 'friday': 'mix-punch', 'saturday': 'carrot-juice'});

    testWidgets('displays plan info', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildTestApp(SubscriptionSummaryScreen(selection: summary), bloc));
      await tester.pumpAndSettle();
      expect(find.text('DELIGHT 200ml'), findsOneWidget);
      expect(find.text('WEEKLY'), findsOneWidget);
      expect(find.text('₹699 / weekly'), findsOneWidget);
    });

    testWidgets('Sunday = no delivery', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildTestApp(SubscriptionSummaryScreen(selection: summary), bloc));
      await tester.pumpAndSettle();
      expect(find.text('Sunday'), findsOneWidget);
      expect(find.text('No delivery'), findsOneWidget);
    });

    testWidgets('Start Subscription CTA visible', (tester) async {
      setLargeViewport(tester);
      await tester.pumpWidget(buildTestApp(SubscriptionSummaryScreen(selection: summary), bloc));
      await tester.pumpAndSettle();
      expect(find.text('Start Subscription'), findsOneWidget);
    });
  });
}