/// Unit tests for [OrderService].
///
/// Covers: getMyOrders, getOrderDetails, getLocalOrderHistory, getLocalOrderDetails.
///
/// Uses [MockClient] from package:http/testing.dart to mock HTTP responses,
/// and [MockSecureStorageService] (mocktail) to inject test tokens.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lush/services/order_service.dart';
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
    baseUrl = OrderService.baseUrl;
  });

  tearDown(() {
    SecureStorageService.resetTestInstance();
  });

  // ─── getMyOrders ───────────────────────────────────────────
  group('getMyOrders', () {
    test('returns order list on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/orders');
        expect(request.headers['Authorization'], 'Bearer test-jwt-token');
        return http.Response(
          json.encode({'data': [
            {'id': 'order_1', 'status': 'delivered'},
            {'id': 'order_2', 'status': 'pending'},
          ]}),
          200,
        );
      });
      final service = OrderService(client: client);
      final result = await service.getMyOrders();
      expect(result.length, 2);
      expect(result[0]['id'], 'order_1');
      expect(result[1]['status'], 'pending');
    });

    test('returns empty list when data is null', () async {
      final client = MockClient((request) async {
        return http.Response(json.encode({}), 200);
      });
      final service = OrderService(client: client);
      final result = await service.getMyOrders();
      expect(result, isEmpty);
    });

    test('throws Unauthorized on 401', () async {
      final client = MockClient((_) async => http.Response('', 401));
      final service = OrderService(client: client);
      expect(() => service.getMyOrders(), throwsA(predicate(
        (e) => e.toString().contains('Unauthorized'),
      )));
    });

    test('throws generic error on non-200', () async {
      final client = MockClient((_) async => http.Response('', 500));
      final service = OrderService(client: client);
      expect(() => service.getMyOrders(), throwsA(predicate(
        (e) => e.toString().contains('Failed to load orders'),
      )));
    });

    test('propagates network exceptions', () async {
      final client = MockClient((_) async => throw Exception('Network failed'));
      final service = OrderService(client: client);
      expect(() => service.getMyOrders(), throwsA(predicate(
        (e) => e.toString().contains('Network failed'),
      )));
    });
  });

  // ─── getOrderDetails ───────────────────────────────────────
  group('getOrderDetails', () {
    test('returns order detail map on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/orders/order_1');
        return http.Response(
          json.encode({'data': {'id': 'order_1', 'status': 'delivered'}}),
          200,
        );
      });
      final service = OrderService(client: client);
      final result = await service.getOrderDetails('order_1');
      expect(result['id'], 'order_1');
      expect(result['status'], 'delivered');
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 404));
      final service = OrderService(client: client);
      expect(() => service.getOrderDetails('bad_id'), throwsA(predicate(
        (e) => e.toString().contains('Failed to load order details'),
      )));
    });

    test('propagates network exceptions', () async {
      final client = MockClient((_) async => throw Exception('timeout'));
      final service = OrderService(client: client);
      expect(() => service.getOrderDetails('x'), throwsA(predicate(
        (e) => e.toString().contains('timeout'),
      )));
    });
  });

  // ─── getLocalOrderHistory ──────────────────────────────────
  group('getLocalOrderHistory', () {
    test('returns local order list on 200', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), '$baseUrl/api/orders/local/history');
        return http.Response(
          json.encode({'data': [{'id': 'local_1'}]}),
          200,
        );
      });
      final service = OrderService(client: client);
      final result = await service.getLocalOrderHistory();
      expect(result.length, 1);
      expect(result[0]['id'], 'local_1');
    });

    test('returns empty list when data null', () async {
      final client = MockClient((_) async => http.Response(json.encode({}), 200));
      final service = OrderService(client: client);
      final result = await service.getLocalOrderHistory();
      expect(result, isEmpty);
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 400));
      final service = OrderService(client: client);
      expect(() => service.getLocalOrderHistory(), throwsA(predicate(
        (e) => e.toString().contains('Failed to load local orders'),
      )));
    });
  });

  // ─── getLocalOrderDetails ──────────────────────────────────
  group('getLocalOrderDetails', () {
    test('returns local order detail map on 200', () async {
      final client = MockClient((request) async {
        expect(request.url.toString(), '$baseUrl/api/orders/local/local_1');
        return http.Response(
          json.encode({'data': {'id': 'local_1'}}),
          200,
        );
      });
      final service = OrderService(client: client);
      final result = await service.getLocalOrderDetails('local_1');
      expect(result['id'], 'local_1');
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 404));
      final service = OrderService(client: client);
      expect(() => service.getLocalOrderDetails('x'), throwsA(predicate(
        (e) => e.toString().contains('Failed to load local order'),
      )));
    });
  });
}