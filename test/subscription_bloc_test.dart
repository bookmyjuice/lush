/// Unit tests for [SubscriptionBloc] and subscription models.
///
/// Covers: LoadSubscriptionCatalog, CreateSubscriptionFromSelection,
/// SubscriptionSelection model, SubscriptionPlanCatalog model.
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/get_it.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/views/models/subscription_plan_catalog.dart';
import 'package:lush/views/models/subscription_selection.dart';
import 'package:lush/views/models/user.dart';
import 'package:mocktail/mocktail.dart';

class MockSubscriptionService extends Mock implements SubscriptionService {}

class MockUserRepository extends Mock implements UserRepository {}

/// Helper to create a test User for UserRepository mock
User createTestUser() {
  return User(
    id: 'test-user-id',
    email: 'test@example.com',
    phone: '9876543210',
    role: 'user',
    firstName: 'Test',
    lastName: 'User',
    password: 'password',
    address: '123 Test St',
    city: 'Mumbai',
    country: 'IN',
    extendedAddr: '',
    extendedAddr2: '',
    state: 'Maharashtra',
    zip: '400001',
  );
}

/// Builds a map that matches the Chargebee-like format [SubscriptionPlanCatalog.fromMap] expects.
Map<String, dynamic> buildPlanMap({
  required String itemId,
  String name = 'test-plan',
  String family = 'delight',
  String size = '200ml',
  String planType = 'generic',
  String? defaultJuice,
}) {
  return {
    'id': itemId,
    'name': name,
    'item_family_id': family,
    'metadata': {
      'size': size,
      'plan_type': planType,
      if (defaultJuice != null) 'default_juice': defaultJuice,
    },
  };
}

/// Helper to create a test [SubscriptionPlanCatalog] for model tests.
SubscriptionPlanCatalog createTestPlan({
  String itemId = 'bmj-delight-200ml',
  String name = 'delight-200ml',
  String family = 'delight',
  String size = '200ml',
  String planType = 'generic',
  String? defaultJuice,
  int weeklyPricePaise = 69900,
  int monthlyPricePaise = 249900,
}) {
  final prices = <SubscriptionPriceOption>[
    SubscriptionPriceOption(
      itemPriceId: '${itemId}-weekly',
      period: 'weekly',
      priceInPaise: weeklyPricePaise,
      bottleCount: 6,
    ),
    SubscriptionPriceOption(
      itemPriceId: '${itemId}-monthly',
      period: 'monthly',
      priceInPaise: monthlyPricePaise,
      bottleCount: 24,
    ),
  ];

  return SubscriptionPlanCatalog(
    itemId: itemId,
    name: name,
    family: family,
    size: size,
    planType: planType,
    defaultJuice: defaultJuice,
    prices: prices,
    metadata: {
      'size': size,
      'plan_type': planType,
      if (defaultJuice != null) 'default_juice': defaultJuice,
    },
  );
}

/// Helper to create a test [SubscriptionSelection].
SubscriptionSelection createTestSelection({
  String itemId = 'bmj-delight-200ml',
  String itemPriceId = 'bmj-delight-200ml-weekly',
  String family = 'delight',
  String size = '200ml',
  String period = 'weekly',
  int priceInPaise = 69900,
  String? defaultJuice,
  Map<String, String>? daySchedule,
}) {
  return SubscriptionSelection(
    itemId: itemId,
    itemPriceId: itemPriceId,
    family: family,
    size: size,
    period: period,
    priceInPaise: priceInPaise,
    defaultJuice: defaultJuice,
    daySchedule: daySchedule ?? {},
  );
}

void main() {
  late MockSubscriptionService mockService;
  late MockUserRepository mockUserRepo;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockService = MockSubscriptionService();
    mockUserRepo = MockUserRepository();
    if (getIt.isRegistered<UserRepository>()) {
      getIt.unregister<UserRepository>();
    }
    getIt.registerSingleton<UserRepository>(mockUserRepo);
    when(() => mockUserRepo.user).thenReturn(createTestUser());
    when(() => mockUserRepo.isInternetAvailable())
        .thenAnswer((_) async => true);
  });

  tearDown(() {
    if (getIt.isRegistered<UserRepository>()) {
      getIt.unregister<UserRepository>();
    }
  });

  // ─── LoadSubscriptionCatalog ─────────────────────────────────
  group('LoadSubscriptionCatalog', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionLoading, SubscriptionCatalogLoaded] on success',
      build: () {
        when(() => mockService.getSubscriptionPlans()).thenAnswer(
          (_) async => [
            buildPlanMap(itemId: 'bmj-delight-200ml', family: 'delight'),
            buildPlanMap(itemId: 'bmj-signature-200ml', family: 'signature'),
          ],
        );
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadSubscriptionCatalog()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionCatalogLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SubscriptionCatalogLoaded;
        expect(state.plans.length, 2);
        for (final plan in state.plans) {
          expect(plan.itemId, startsWith('bmj-'));
        }
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionLoading, SubscriptionCatalogError] on service exception',
      build: () {
        when(() => mockService.getSubscriptionPlans())
            .thenThrow(Exception('network error'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadSubscriptionCatalog()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionCatalogError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SubscriptionCatalogError;
        expect(state.message, isNotEmpty);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'filters out non-bmj plans',
      build: () {
        when(() => mockService.getSubscriptionPlans()).thenAnswer(
          (_) async => [
            buildPlanMap(itemId: 'bmj-delight-200ml', family: 'delight'),
            buildPlanMap(itemId: 'other-plan', family: 'other'),
          ],
        );
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadSubscriptionCatalog()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionCatalogLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SubscriptionCatalogLoaded;
        expect(state.plans.length, 1);
      },
    );
  });

  // ─── CreateSubscriptionFromSelection ─────────────────────────
  group('CreateSubscriptionFromSelection', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionLoading, SubscriptionCreatedSuccess] on success',
      build: () {
        when(() => mockService.createSubscription(any<String>()))
            .thenAnswer((_) async => {'success': true, 'message': 'Created'});
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(
        CreateSubscriptionFromSelection(selection: createTestSelection()),
      ),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionCreatedSuccess>(),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [SubscriptionLoading, SubscriptionError] on service exception',
      build: () {
        when(() => mockService.createSubscription(any<String>()))
            .thenThrow(Exception('Service unavailable'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(
        CreateSubscriptionFromSelection(selection: createTestSelection()),
      ),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SubscriptionError;
        expect(state.message, isNotEmpty);
      },
    );
  });

  // ─── SubscriptionSelection model ─────────────────────────────
  group('SubscriptionSelection model', () {
    test('isComplete returns true when all 6 days filled', () {
      final selection = createTestSelection(daySchedule: {
        'monday': 'mix-punch',
        'tuesday': 'carrot-juice',
        'wednesday': 'mix-punch',
        'thursday': 'carrot-juice',
        'friday': 'mix-punch',
        'saturday': 'carrot-juice',
      });
      expect(selection.isComplete, isTrue);
    });

    test('isComplete returns false when any day empty', () {
      final selection = createTestSelection(daySchedule: {
        'monday': 'mix-punch',
        'tuesday': '',
        'wednesday': 'mix-punch',
        'thursday': 'carrot-juice',
        'friday': 'mix-punch',
        'saturday': 'carrot-juice',
      });
      expect(selection.isComplete, isFalse);
    });

    test('isComplete returns false when fewer than 6 days', () {
      final selection = createTestSelection(daySchedule: {
        'monday': 'mix-punch',
        'tuesday': 'carrot-juice',
      });
      expect(selection.isComplete, isFalse);
    });

    test('priceInRupees = priceInPaise / 100', () {
      final selection = createTestSelection(priceInPaise: 69900);
      expect(selection.priceInRupees, 699.0);
    });

    test(
        'toChargebeeMetadata contains itemPriceId, family, size, period, day_schedule',
        () {
      final selection = createTestSelection(
        itemPriceId: 'bmj-delight-200ml-weekly',
        family: 'delight',
        size: '200ml',
        period: 'weekly',
        daySchedule: {'monday': 'mix-punch'},
      );
      final metadata = selection.toChargebeeMetadata();
      expect(metadata['item_price_id'], 'bmj-delight-200ml-weekly');
      expect(metadata['family'], 'delight');
      expect(metadata['size'], '200ml');
      expect(metadata['period'], 'weekly');
      expect(metadata['day_schedule'], {'monday': 'mix-punch'});
    });

    test('copyWith preserves unchanged fields', () {
      final original = createTestSelection(
        itemId: 'bmj-delight-200ml',
        family: 'delight',
        size: '200ml',
        period: 'weekly',
      );
      final copied = original.copyWith();
      expect(copied.itemId, original.itemId);
      expect(copied.family, original.family);
      expect(copied.size, original.size);
      expect(copied.period, original.period);
    });

    test('copyWith overrides specified fields', () {
      final original = createTestSelection(
        itemId: 'bmj-delight-200ml',
        family: 'delight',
      );
      final copied = original.copyWith(family: 'signature', size: '500ml');
      expect(copied.family, 'signature');
      expect(copied.size, '500ml');
      expect(copied.itemId, original.itemId);
    });
  });

  // ─── SubscriptionPlanCatalog ──────────────────────────────────
  group('SubscriptionPlanCatalog', () {
    test('isGeneric true when planType = generic', () {
      final plan = createTestPlan(planType: 'generic');
      expect(plan.isGeneric, isTrue);
      expect(plan.isJuiceSpecific, isFalse);
    });

    test('isJuiceSpecific true when planType = juice_specific', () {
      final plan =
          createTestPlan(planType: 'juice_specific', defaultJuice: 'mix-punch');
      expect(plan.isJuiceSpecific, isTrue);
      expect(plan.isGeneric, isFalse);
    });

    test('weeklyPrice returns correct SubscriptionPriceOption', () {
      final plan = createTestPlan(weeklyPricePaise: 69900);
      final weekly = plan.weeklyPrice;
      expect(weekly, isNotNull);
      expect(weekly!.period, 'weekly');
      expect(weekly.priceInPaise, 69900);
    });

    test('monthlyPrice returns correct SubscriptionPriceOption', () {
      final plan = createTestPlan(monthlyPricePaise: 249900);
      final monthly = plan.monthlyPrice;
      expect(monthly, isNotNull);
      expect(monthly!.period, 'monthly');
      expect(monthly.priceInPaise, 249900);
    });

    test('fromChargebee parses snake_case keys correctly', () {
      final itemData = {
        'id': 'bmj-delight-200ml',
        'name': 'delight-200ml',
        'item_family_id': 'delight',
        'metadata': {
          'size': '200ml',
          'plan_type': 'generic',
        },
      };
      final priceData = <Map<String, dynamic>>[
        {'id': 'price-weekly', 'period_unit': 'week', 'price': 69900},
        {'id': 'price-monthly', 'period_unit': 'month', 'price': 249900},
      ];
      final catalog = SubscriptionPlanCatalog.fromMap(itemData, priceData);
      expect(catalog.itemId, 'bmj-delight-200ml');
      expect(catalog.family, 'delight');
      expect(catalog.size, '200ml');
      expect(catalog.planType, 'generic');
      expect(catalog.isGeneric, isTrue);
      expect(catalog.prices.length, 2);
      expect(catalog.weeklyPrice!.priceInPaise, 69900);
      expect(catalog.monthlyPrice!.priceInPaise, 249900);
    });
  });
}