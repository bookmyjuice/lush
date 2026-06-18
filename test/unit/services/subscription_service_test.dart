/// Unit tests for [SubscriptionService].
///
/// Covers: getSubscriptionPlans, getMySubscriptions, getSubscriptionDetails,
/// createSubscription, pauseSubscription, resumeSubscription, cancelSubscription,
/// modifySchedule.
///
/// Uses [MockClient] from package:http/testing.dart to mock HTTP responses,
/// and [MockSecureStorageService] (mocktail) to inject test tokens.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/services/secure_storage_service.dart';
import 'package:mocktail/mocktail.dart';

class MockSecureStorage extends Mock implements SecureStorageService {}

void main() {
  late MockSecureStorage mockStorage;
  late String baseUrl;

  setUp(() {
    mockStorage = MockSecureStorage();
    when(() => mockStorage.getAuthToken()).thenAnswer((_) async => 'test-jwt-token');
    SecureStorageService.setTestInstance(mockStorage);
    baseUrl = SubscriptionService.baseUrl;
  });

  tearDown(() {
    SecureStorageService.resetTestInstance();
  });

  // ─── getSubscriptionPlans ──────────────────────────────────
  group('getSubscriptionPlans', () {
    test('returns plan list on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/subscriptions/pricing/plans');
        return http.Response(
          json.encode({'data': [
            {'id': 'plan_1', 'name': 'Delight Weekly'},
            {'id': 'plan_2', 'name': 'Detox Monthly'},
          ]}),
          200,
        );
      });
      final service = SubscriptionService(client: client);
      final result = await service.getSubscriptionPlans();
      expect(result.length, 2);
      expect(result[0]['name'], 'Delight Weekly');
      expect(result[1]['id'], 'plan_2');
    });

    test('returns empty list when data is null', () async {
      final client = MockClient((_) async => http.Response(json.encode({}), 200));
      final service = SubscriptionService(client: client);
      final result = await service.getSubscriptionPlans();
      expect(result, isEmpty);
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 500));
      final service = SubscriptionService(client: client);
      expect(() => service.getSubscriptionPlans(), throwsA(predicate(
        (e) => e.toString().contains('Failed to load subscription plans'),
      )));
    });
  });

  // ─── getMySubscriptions ────────────────────────────────────
  group('getMySubscriptions', () {
    test('returns subscription list on 200', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), '$baseUrl/api/subscriptions/my');
        return http.Response(
          json.encode({'subscriptions': [
            {'id': 'sub_1', 'status': 'active'},
          ]}),
          200,
        );
      });
      final service = SubscriptionService(client: client);
      final result = await service.getMySubscriptions();
      expect(result.length, 1);
      expect(result[0]['status'], 'active');
    });

    test('returns empty list when subscriptions null', () async {
      final client = MockClient((_) async => http.Response(json.encode({}), 200));
      final service = SubscriptionService(client: client);
      final result = await service.getMySubscriptions();
      expect(result, isEmpty);
    });

    test('throws Unauthorized on 401', () async {
      final client = MockClient((_) async => http.Response('', 401));
      final service = SubscriptionService(client: client);
      expect(() => service.getMySubscriptions(), throwsA(predicate(
        (e) => e.toString().contains('Unauthorized'),
      )));
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 500));
      final service = SubscriptionService(client: client);
      expect(() => service.getMySubscriptions(), throwsA(predicate(
        (e) => e.toString().contains('Failed to load subscriptions'),
      )));
    });
  });

  // ─── getSubscriptionDetails ────────────────────────────────
  group('getSubscriptionDetails', () {
    test('returns detail map on 200', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), '$baseUrl/api/subscriptions/sub_1');
        return http.Response(
          json.encode({'data': {'id': 'sub_1', 'status': 'active'}}),
          200,
        );
      });
      final service = SubscriptionService(client: client);
      final result = await service.getSubscriptionDetails('sub_1');
      expect(result['id'], 'sub_1');
      expect(result['status'], 'active');
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 404));
      final service = SubscriptionService(client: client);
      expect(() => service.getSubscriptionDetails('x'), throwsA(predicate(
        (e) => e.toString().contains('Failed to load subscription details'),
      )));
    });
  });

  // ─── createSubscription ────────────────────────────────────
  group('createSubscription', () {
    test('returns response map on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), '$baseUrl/api/subscriptions/create');
        final body = json.decode(request.body!) as Map<String, dynamic>;
        expect(body['planId'], 'plan_1');
        return http.Response(
          json.encode({'url': 'https://checkout.chargebee.com/hosted/xxx'}),
          200,
        );
      });
      final service = SubscriptionService(client: client);
      final result = await service.createSubscription('plan_1');
      expect(result['url'], contains('chargebee.com'));
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 400));
      final service = SubscriptionService(client: client);
      expect(() => service.createSubscription('x'), throwsA(predicate(
        (e) => e.toString().contains('Failed to create subscription'),
      )));
    });
  });

  // ─── pauseSubscription ─────────────────────────────────────
  group('pauseSubscription', () {
    test('returns success on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.toString(), '$baseUrl/api/subscriptions/sub_1/pause');
        final body = json.decode(request.body!) as Map<String, dynamic>;
        expect(body['duration'], '2_weeks');
        return http.Response(
          json.encode({'message': 'Paused until 2026-07-01'}),
          200,
        );
      });
      final service = SubscriptionService(client: client);
      final result = await service.pauseSubscription('sub_1', duration: '2_weeks');
      expect(result['success'], true);
      expect(result['message'], 'Paused until 2026-07-01');
    });

    test('returns success on 202', () async {
      final client = MockClient((_) async => http.Response(
        json.encode({'message': 'Pause initiated'}),
        202,
      ));
      final service = SubscriptionService(client: client);
      final result = await service.pauseSubscription('sub_1');
      expect(result['success'], true);
    });

    test('throws on non-200/202', () async {
      final client = MockClient((_) async => http.Response(
        json.encode({'message': 'Conflict'}), 409,
      ));
      final service = SubscriptionService(client: client);
      expect(() => service.pauseSubscription('sub_1'), throwsA(predicate(
        (e) => e.toString().contains('Conflict'),
      )));
    });
  });

  // ─── resumeSubscription ────────────────────────────────────
  group('resumeSubscription', () {
    test('returns success on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.toString(), '$baseUrl/api/subscriptions/sub_1/resume');
        return http.Response(
          json.encode({'message': 'Subscription resumed'}),
          200,
        );
      });
      final service = SubscriptionService(client: client);
      final result = await service.resumeSubscription('sub_1');
      expect(result['success'], true);
    });

    test('returns success on 202', () async {
      final client = MockClient((_) async => http.Response(
        json.encode({'message': 'Resume initiated'}), 202,
      ));
      final service = SubscriptionService(client: client);
      final result = await service.resumeSubscription('sub_1');
      expect(result['success'], true);
    });

    test('throws on non-200/202', () async {
      final client = MockClient((_) async => http.Response(
        json.encode({'message': 'Not found'}), 404,
      ));
      final service = SubscriptionService(client: client);
      expect(() => service.resumeSubscription('x'), throwsA(predicate(
        (e) => e.toString().contains('Not found'),
      )));
    });
  });

  // ─── cancelSubscription ────────────────────────────────────
  group('cancelSubscription', () {
    test('returns success on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.toString(), '$baseUrl/api/subscriptions/sub_1/cancel');
        final body = json.decode(request.body!) as Map<String, dynamic>;
        expect(body['reason'], 'No longer needed');
        return http.Response(
          json.encode({'message': 'Subscription canceled'}),
          200,
        );
      });
      final service = SubscriptionService(client: client);
      final result = await service.cancelSubscription('sub_1', reason: 'No longer needed');
      expect(result['success'], true);
    });

    test('returns default message when body missing message', () async {
      final client = MockClient((_) async => http.Response(json.encode({}), 200));
      final service = SubscriptionService(client: client);
      final result = await service.cancelSubscription('sub_1');
      expect(result['message'], 'Subscription canceled');
    });

    test('throws on non-200/202', () async {
      final client = MockClient((_) async => http.Response(
        json.encode({'message': 'Forbidden'}), 403,
      ));
      final service = SubscriptionService(client: client);
      expect(() => service.cancelSubscription('x'), throwsA(predicate(
        (e) => e.toString().contains('Forbidden'),
      )));
    });
  });

  // ─── modifySchedule ────────────────────────────────────────
  group('modifySchedule', () {
    test('returns success on 200', () async {
      final schedule = {'monday': 'Morning', 'wednesday': 'Evening'};
      final client = MockClient((request) async {
        expect(request.method, 'PUT');
        expect(request.url.toString(), '$baseUrl/api/subscriptions/sub_1/modify');
        final body = json.decode(request.body!) as Map<String, dynamic>;
        expect(body['schedule'], schedule);
        return http.Response(
          json.encode({'message': 'Schedule updated'}),
          200,
        );
      });
      final service = SubscriptionService(client: client);
      final result = await service.modifySchedule('sub_1', schedule);
      expect(result['success'], true);
      expect(result['message'], 'Schedule updated');
    });

    test('returns success on 202', () async {
      final client = MockClient((_) async => http.Response(
        json.encode({'message': 'Update initiated'}), 202,
      ));
      final service = SubscriptionService(client: client);
      final result = await service.modifySchedule('sub_1', {});
      expect(result['success'], true);
    });

    test('throws on non-200/202', () async {
      final client = MockClient((_) async => http.Response(
        json.encode({'message': 'Bad request'}), 400,
      ));
      final service = SubscriptionService(client: client);
      expect(() => service.modifySchedule('x', {}), throwsA(predicate(
        (e) => e.toString().contains('Bad request'),
      )));
    });
  });
}