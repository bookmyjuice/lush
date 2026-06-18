/// Unit tests for [SubscriptionBloc] and subscription models.
///
/// Covers: LoadSubscriptionCatalog, CreateSubscriptionFromSelection,
/// LoadActiveSubscriptions, LoadSubscriptionPlans, LoadSubscriptionHistory,
/// CreateSubscription, CancelSubscription, PauseSubscription, ResumeSubscription,
/// ModifySubscriptionSchedule, SubscriptionSelection model, SubscriptionPlanCatalog model.
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/get_it.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/utils/analytics_service.dart';
import 'package:lush/views/models/subscription_plan_catalog.dart';
import 'package:lush/views/models/subscription_selection.dart';
import 'package:lush/views/models/user.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSubscriptionService extends Mock implements SubscriptionService {}

class MockUserRepository extends Mock implements UserRepository {}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

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

/// Builds a subscription response map matching the backend JSON format.
Map<String, dynamic> buildSubscriptionJson({
  String id = 'sub_001',
  int planId = 1,
  String planName = 'Premium',
  String status = 'active',
  String? pausedUntil,
}) {
  return {
    'id': id,
    'planId': planId,
    'planName': planName,
    'status': status,
    'startDate': DateTime.now().toIso8601String(),
    'endDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    'nextDeliveryDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    'totalDeliveries': 30,
    'completedDeliveries': 5,
    'pausedUntil': pausedUntil,
    'createdAt': DateTime.now().toIso8601String(),
    'updatedAt': DateTime.now().toIso8601String(),
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
      itemPriceId: '$itemId-weekly',
      period: 'weekly',
      priceInPaise: weeklyPricePaise,
      bottleCount: 6,
    ),
    SubscriptionPriceOption(
      itemPriceId: '$itemId-monthly',
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
    final mockAnalytics = MockFirebaseAnalytics();
    when(() => mockAnalytics.logEvent(name: any(named: 'name'), parameters: any(named: 'parameters')))
        .thenAnswer((_) async {});
    AnalyticsService.setAnalyticsForTesting(mockAnalytics);
  });

  tearDownAll(() {
    AnalyticsService.resetAnalyticsForTesting();
  });

  setUp(() {
    mockService = MockSubscriptionService();
    mockUserRepo = MockUserRepository();
    SharedPreferences.setMockInitialValues({});

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
            buildPlanMap(itemId: 'bmj-delight-200ml'),
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
            buildPlanMap(itemId: 'bmj-delight-200ml'),
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

  // ─── LoadActiveSubscriptions ─────────────────────────────────
  group('LoadActiveSubscriptions', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, SubscriptionLoaded] on success with active subscription',
      build: () {
        when(() => mockService.getMySubscriptions()).thenAnswer(
          (_) async => [buildSubscriptionJson()],
        );
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadActiveSubscriptions()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SubscriptionLoaded;
        expect(state.subscription.isActive, isTrue);
        expect(state.subscription.id, 'sub_001');
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, SubscriptionEmpty] when no active subscriptions',
      build: () {
        when(() => mockService.getMySubscriptions())
            .thenAnswer((_) async => []);
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadActiveSubscriptions()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionEmpty>(),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, Error] on service exception',
      build: () {
        when(() => mockService.getMySubscriptions())
            .thenThrow(Exception('Server error'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadActiveSubscriptions()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>().having(
          (s) => s.message, 'error message', contains('Server error'),
        ),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'falls back to cache when offline',
      build: () {
        when(() => mockUserRepo.isInternetAvailable())
            .thenAnswer((_) async => false);
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadActiveSubscriptions()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>().having(
          (s) => s.message, 'error message', contains('No internet connection'),
        ),
      ],
    );
  });

  // ─── LoadSubscriptionPlans ───────────────────────────────────
  group('LoadSubscriptionPlans', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, SubscriptionPlansLoaded] on success',
      build: () {
        when(() => mockService.getSubscriptionPlans()).thenAnswer(
          (_) async => [
            {'id': 'plan_1', 'name': 'Premium', 'description': 'Best plan', 'planID': 1},
            {'id': 'plan_2', 'name': 'Delight', 'description': 'Budget plan', 'planID': 2},
          ],
        );
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadSubscriptionPlans()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionPlansLoaded>().having(
          (s) => s.plans.length, 'plan count', 2,
        ),
      ],
      verify: (bloc) {
        final state = bloc.state as SubscriptionPlansLoaded;
        expect(state.plans.first.name, 'Premium');
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, Error] on service exception',
      build: () {
        when(() => mockService.getSubscriptionPlans())
            .thenThrow(Exception('Failed to fetch'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadSubscriptionPlans()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SubscriptionError;
        expect(state.message, contains('Failed to fetch'));
      },
    );
  });

  // ─── LoadSubscriptionHistory ─────────────────────────────────
  group('LoadSubscriptionHistory', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, SubscriptionListLoaded] with subscriptions',
      build: () {
        when(() => mockService.getMySubscriptions()).thenAnswer(
          (_) async => [
            buildSubscriptionJson(id: 'sub_001', status: 'completed'),
            buildSubscriptionJson(id: 'sub_002', status: 'cancelled'),
          ],
        );
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadSubscriptionHistory()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionListLoaded>().having(
          (s) => s.subscriptions.length, 'history count', 2,
        ),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, SubscriptionEmpty] when no history',
      build: () {
        when(() => mockService.getMySubscriptions())
            .thenAnswer((_) async => []);
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadSubscriptionHistory()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionEmpty>(),
      ],
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, Error] on service exception',
      build: () {
        when(() => mockService.getMySubscriptions())
            .thenThrow(Exception('History unavailable'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const LoadSubscriptionHistory()),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>().having(
          (s) => s.message, 'error message', contains('History unavailable'),
        ),
      ],
    );
  });

  // ─── CreateSubscription ──────────────────────────────────────
  group('CreateSubscription', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, SubscriptionCreated, SubscriptionLoaded] on success',
      build: () {
        when(() => mockService.createSubscription(any<String>()))
            .thenAnswer((_) async => {
              'subscriptionId': 'sub_new',
              'status': 'active',
              'totalDeliveries': 30,
            },);
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(CreateSubscription(
        planId: 1,
        startDate: DateTime(2026, 6, 10),
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionCreated>(),
        isA<SubscriptionLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as SubscriptionLoaded;
        expect(state.subscription.status, 'active');
        verify(() => mockService.createSubscription('1')).called(1);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, Error] when create fails',
      build: () {
        when(() => mockService.createSubscription(any<String>()))
            .thenThrow(Exception('Payment required'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(CreateSubscription(
        planId: 2,
        startDate: DateTime(2026, 6, 10),
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>().having(
          (s) => s.message, 'error message', contains('Payment required'),
        ),
      ],
    );
  });

  // ─── CancelSubscription ──────────────────────────────────────
  group('CancelSubscription', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, SubscriptionCancelled] on success',
      build: () {
        when(() => mockService.cancelSubscription(any<String>(),
            reason: any(named: 'reason')))
            .thenAnswer((_) async => {'success': true});
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const CancelSubscription(
        subscriptionId: 'sub_001',
        reason: 'Too expensive',
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionCancelled>().having(
          (s) => s.subscriptionId, 'id', 'sub_001',
        ),
      ],
      verify: (bloc) {
        verify(() => mockService.cancelSubscription(
          'sub_001',
          reason: 'Too expensive',
        )).called(1);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, Error] on cancel failure',
      build: () {
        when(() => mockService.cancelSubscription(any<String>(),
            reason: any(named: 'reason')))
            .thenThrow(Exception('Cannot cancel'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const CancelSubscription(
        subscriptionId: 'sub_001',
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>().having(
          (s) => s.message, 'error message', contains('Cannot cancel'),
        ),
      ],
    );
  });

  // ─── PauseSubscription ───────────────────────────────────────
  group('PauseSubscription', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading] then refetches active subscriptions on success',
      build: () {
        when(() => mockService.pauseSubscription(any<String>(),
            duration: any(named: 'duration')))
            .thenAnswer((_) async => {'success': true, 'message': 'Paused'});
        // After refetch, return active subscription
        when(() => mockService.getMySubscriptions()).thenAnswer(
          (_) async => [buildSubscriptionJson(status: 'paused', pausedUntil: DateTime.now().add(const Duration(days: 7)).toIso8601String())],
        );
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const PauseSubscription(
        subscriptionId: 'sub_001',
        duration: '1_week',
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionLoaded>(),
      ],
      verify: (bloc) {
        verify(() => mockService.pauseSubscription(
          'sub_001',
          duration: '1_week',
        )).called(1);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, Error] on pause failure',
      build: () {
        when(() => mockService.pauseSubscription(any<String>(),
            duration: any(named: 'duration')))
            .thenThrow(Exception('Cannot pause'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const PauseSubscription(
        subscriptionId: 'sub_001',
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>().having(
          (s) => s.message, 'error message', contains('Cannot pause'),
        ),
      ],
    );
  });

  // ─── ResumeSubscription ──────────────────────────────────────
  group('ResumeSubscription', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading] then refetches active subscriptions on success',
      build: () {
        when(() => mockService.resumeSubscription(any<String>()))
            .thenAnswer((_) async => {'success': true, 'message': 'Resumed'});
        // After refetch, return active subscription with status active
        when(() => mockService.getMySubscriptions()).thenAnswer(
          (_) async => [buildSubscriptionJson(status: 'active')],
        );
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const ResumeSubscription(
        subscriptionId: 'sub_001',
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionLoaded>(),
      ],
      verify: (bloc) {
        verify(() => mockService.resumeSubscription('sub_001')).called(1);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, Error] on resume failure',
      build: () {
        when(() => mockService.resumeSubscription(any<String>()))
            .thenThrow(Exception('Cannot resume'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const ResumeSubscription(
        subscriptionId: 'sub_001',
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>().having(
          (s) => s.message, 'error message', contains('Cannot resume'),
        ),
      ],
    );
  });

  // ─── ModifySubscriptionSchedule ──────────────────────────────
  group('ModifySubscriptionSchedule', () {
    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, SubscriptionModified] on success',
      build: () {
        when(() => mockService.modifySchedule(any<String>(), any<Map<String, dynamic>>()))
            .thenAnswer((_) async => {'success': true, 'message': 'Updated'});
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const ModifySubscriptionSchedule(
        subscriptionId: 'sub_001',
        newSchedule: {'monday': 'juice_001'},
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionModified>().having(
          (s) => s.message, 'success message', contains('Schedule updated'),
        ),
      ],
      verify: (bloc) {
        verify(() => mockService.modifySchedule(
          'sub_001',
          {'monday': 'juice_001'},
        )).called(1);
      },
    );

    blocTest<SubscriptionBloc, SubscriptionState>(
      'emits [Loading, Error] on modify failure',
      build: () {
        when(() => mockService.modifySchedule(any<String>(), any<Map<String, dynamic>>()))
            .thenThrow(Exception('Cannot modify'));
        return SubscriptionBloc(subscriptionService: mockService);
      },
      act: (bloc) => bloc.add(const ModifySubscriptionSchedule(
        subscriptionId: 'sub_001',
        newSchedule: {},
      )),
      expect: () => [
        isA<SubscriptionLoading>(),
        isA<SubscriptionError>().having(
          (s) => s.message, 'error message', contains('Cannot modify'),
        ),
      ],
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
      },);
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
      },);
      expect(selection.isComplete, isFalse);
    });

    test('isComplete returns false when fewer than 6 days', () {
      final selection = createTestSelection(daySchedule: {
        'monday': 'mix-punch',
        'tuesday': 'carrot-juice',
      },);
      expect(selection.isComplete, isFalse);
    });

    test('priceInRupees = priceInPaise / 100', () {
      final selection = createTestSelection();
      expect(selection.priceInRupees, 699.0);
    });

    test(
        'toChargebeeMetadata contains itemPriceId, family, size, period, day_schedule',
        () {
      final selection = createTestSelection(
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
        
      );
      final copied = original.copyWith();
      expect(copied.itemId, original.itemId);
      expect(copied.family, original.family);
      expect(copied.size, original.size);
      expect(copied.period, original.period);
    });

    test('copyWith overrides specified fields', () {
      final original = createTestSelection(
        
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
      final plan = createTestPlan();
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
      final plan = createTestPlan();
      final weekly = plan.weeklyPrice;
      expect(weekly, isNotNull);
      expect(weekly!.period, 'weekly');
      expect(weekly.priceInPaise, 69900);
    });

    test('monthlyPrice returns correct SubscriptionPriceOption', () {
      final plan = createTestPlan();
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

  // ─── ActiveSubscription model ────────────────────────────────
  group('ActiveSubscription model', () {
    test('isActive returns true for active status', () {
      final sub = ActiveSubscription(
        id: 'sub_001',
        plan: SubscriptionPlan(id: '1', name: 'Premium', planID: 1),
        status: 'active',
        startDate: DateTime.now(),
        totalDeliveries: 30,
        completedDeliveries: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(sub.isActive, isTrue);
      expect(sub.isPaused, isFalse);
      expect(sub.progress, closeTo(5/30, 0.001));
      expect(sub.remainingDeliveries, 25);
      expect(sub.statusDisplayName, 'Active');
    });

    test('isPaused returns true for paused status', () {
      final sub = ActiveSubscription(
        id: 'sub_001',
        plan: SubscriptionPlan(id: '1', name: 'Premium', planID: 1),
        status: 'paused',
        startDate: DateTime.now(),
        totalDeliveries: 30,
        completedDeliveries: 5,
        pausedUntil: DateTime.now().add(const Duration(days: 7)),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(sub.isPaused, isTrue);
      expect(sub.isActive, isFalse);
      expect(sub.statusDisplayName, 'Paused');
    });

    test('status helpers for cancelled, expired, completed', () {
      final cancelled = ActiveSubscription(
        id: 's1', plan: SubscriptionPlan(id: '1', name: 'P', planID: 1),
        status: 'cancelled', startDate: DateTime.now(),
        totalDeliveries: 10, completedDeliveries: 3,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.statusDisplayName, 'Cancelled');

      final expired = ActiveSubscription(
        id: 's2', plan: SubscriptionPlan(id: '1', name: 'P', planID: 1),
        status: 'expired', startDate: DateTime.now(),
        totalDeliveries: 10, completedDeliveries: 10,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      expect(expired.isExpired, isTrue);
      expect(expired.statusDisplayName, 'Expired');

      final completed = ActiveSubscription(
        id: 's3', plan: SubscriptionPlan(id: '1', name: 'P', planID: 1),
        status: 'completed', startDate: DateTime.now(),
        totalDeliveries: 10, completedDeliveries: 10,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      expect(completed.isCompleted, isTrue);
      expect(completed.statusDisplayName, 'Completed');
    });

    test('copyWith preserves and overrides fields', () {
      final original = ActiveSubscription(
        id: 'sub_001', plan: SubscriptionPlan(id: '1', name: 'P', planID: 1),
        status: 'active', startDate: DateTime.now(),
        totalDeliveries: 30, completedDeliveries: 5,
        createdAt: DateTime.now(), updatedAt: DateTime.now(),
      );
      final copied = original.copyWith(status: 'paused');
      expect(copied.status, 'paused');
      expect(copied.id, original.id);
      expect(copied.totalDeliveries, original.totalDeliveries);
    });

    test('toJson and fromJson round-trip', () {
      final original = ActiveSubscription(
        id: 'sub_001', plan: SubscriptionPlan(id: '1', name: 'Premium', planID: 1),
        status: 'active', startDate: DateTime(2026, 6, 1),
        endDate: DateTime(2026, 7, 1),
        nextDeliveryDate: DateTime(2026, 6, 2),
        totalDeliveries: 30, completedDeliveries: 5,
        createdAt: DateTime(2026, 6, 1), updatedAt: DateTime(2026, 6, 1),
      );
      final json = original.toJson();
      final restored = ActiveSubscription.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.status, original.status);
      expect(restored.totalDeliveries, original.totalDeliveries);
      expect(restored.completedDeliveries, original.completedDeliveries);
    });
  });
}