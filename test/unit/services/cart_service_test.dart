/// Unit tests for [CartService].
///
/// Covers: getCart, addItem, removeItem, clearCart, mergeCart.
///
/// Uses [MockClient] from package:http/testing.dart to mock HTTP responses,
/// and [MockSecureStorageService] (mocktail) to inject test tokens.
///
/// Also tests [CartTypeConflictException] and [CartMergeConflictException].
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lush/services/cart_service.dart';
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
    baseUrl = CartService.baseUrl;
  });

  tearDown(() {
    SecureStorageService.resetTestInstance();
  });

  // ─── getCart ───────────────────────────────────────────────
  group('getCart', () {
    test('returns cart map on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/v1/cart');
        return http.Response(
          json.encode({'cart_id': 'cart_1', 'items': []}),
          200,
        );
      });
      final service = CartService(client: client);
      final result = await service.getCart();
      expect(result['cart_id'], 'cart_1');
    });

    test('throws Unauthorized on 401', () async {
      final client = MockClient((_) async => http.Response('', 401));
      final service = CartService(client: client);
      expect(() => service.getCart(), throwsA(predicate(
        (e) => e.toString().contains('Unauthorized'),
      )));
    });

    test('throws generic error on non-200/401', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'error': 'Server error'}), 500));
      final service = CartService(client: client);
      expect(() => service.getCart(), throwsA(predicate(
        (e) => e.toString().contains('Server error'),
      )));
    });

    test('propagates network exceptions', () async {
      final client = MockClient((_) async => throw Exception('Connection lost'));
      final service = CartService(client: client);
      expect(() => service.getCart(), throwsA(predicate(
        (e) => e.toString().contains('Connection lost'),
      )));
    });
  });

  // ─── addItem ───────────────────────────────────────────────
  group('addItem', () {
    test('adds item and returns updated cart on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString().contains('/api/v1/cart/items'), true);
        expect(request.url.queryParameters['priceId'], 'price-1');
        expect(request.url.queryParameters['quantity'], '2');
        return http.Response(
          json.encode({'cart_id': 'cart_1', 'items': [{'priceId': 'price-1'}]}),
          200,
        );
      });
      final service = CartService(client: client);
      final result = await service.addItem('price-1', quantity: 2);
      expect(result['cart_id'], 'cart_1');
    });

    test('throws CartTypeConflictException on 409', () async {
      final client = MockClient((_) async => http.Response(
        json.encode({'message': 'Cannot mix one-time and subscription items'}),
        409,
      ));
      final service = CartService(client: client);
      expect(() => service.addItem('price-1'), throwsA(isA<CartTypeConflictException>()));
    });

    test('throws Unauthorized on 401', () async {
      final client = MockClient((_) async => http.Response('', 401));
      final service = CartService(client: client);
      expect(() => service.addItem('price-1'), throwsA(predicate(
        (e) => e.toString().contains('Unauthorized'),
      )));
    });

    test('throws generic error on non-200', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'error': 'Bad request'}), 400));
      final service = CartService(client: client);
      expect(() => service.addItem('price-1'), throwsA(predicate(
        (e) => e.toString().contains('Bad request'),
      )));
    });
  });

  // ─── removeItem ────────────────────────────────────────────
  group('removeItem', () {
    test('removes item and returns updated cart on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.toString(), '$baseUrl/api/v1/cart/items/price-1');
        return http.Response(
          json.encode({'cart_id': 'cart_1', 'items': []}),
          200,
        );
      });
      final service = CartService(client: client);
      final result = await service.removeItem('price-1');
      expect(result['items'], isEmpty);
    });

    test('throws on 404', () async {
      final client = MockClient((_) async => http.Response('', 404));
      final service = CartService(client: client);
      expect(() => service.removeItem('invalid'), throwsA(predicate(
        (e) => e.toString().contains('Item not found'),
      )));
    });

    test('throws Unauthorized on 401', () async {
      final client = MockClient((_) async => http.Response('', 401));
      final service = CartService(client: client);
      expect(() => service.removeItem('x'), throwsA(predicate(
        (e) => e.toString().contains('Unauthorized'),
      )));
    });
  });

  // ─── clearCart ─────────────────────────────────────────────
  group('clearCart', () {
    test('clears cart and returns response on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'DELETE');
        expect(request.url.toString(), '$baseUrl/api/v1/cart/clear');
        return http.Response(
          json.encode({'message': 'Cart cleared'}),
          200,
        );
      });
      final service = CartService(client: client);
      final result = await service.clearCart();
      expect(result['message'], 'Cart cleared');
    });

    test('throws Unauthorized on 401', () async {
      final client = MockClient((_) async => http.Response('', 401));
      final service = CartService(client: client);
      expect(() => service.clearCart(), throwsA(predicate(
        (e) => e.toString().contains('Unauthorized'),
      )));
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'error': 'Failed'}), 500));
      final service = CartService(client: client);
      expect(() => service.clearCart(), throwsA(predicate(
        (e) => e.toString().contains('Failed'),
      )));
    });
  });

  // ─── mergeCart ─────────────────────────────────────────────
  group('mergeCart', () {
    test('merges cart and returns result on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), '$baseUrl/api/v1/cart/merge');
        final body = json.decode(request.body!) as Map<String, dynamic>;
        expect(body['guest_cart_id'], 'guest-123');
        expect(body['keep'], 'remote');
        return http.Response(
          json.encode({'cart_id': 'merged_cart', 'items': []}),
          200,
        );
      });
      final service = CartService(client: client);
      final result = await service.mergeCart(
        guestCartId: 'guest-123',
        keepPreference: 'remote',
      );
      expect(result['cart_id'], 'merged_cart');
    });

    test('throws CartMergeConflictException on 409', () async {
      final client = MockClient((_) async => http.Response(
        json.encode({'error': 'Cart type conflict on merge'}),
        409,
      ));
      final service = CartService(client: client);
      expect(() => service.mergeCart(), throwsA(isA<CartMergeConflictException>()));
    });

    test('throws Unauthorized on 401', () async {
      final client = MockClient((_) async => http.Response('', 401));
      final service = CartService(client: client);
      expect(() => service.mergeCart(), throwsA(predicate(
        (e) => e.toString().contains('Unauthorized'),
      )));
    });

    test('throws generic error on non-200', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'error': 'Merge failed'}), 400));
      final service = CartService(client: client);
      expect(() => service.mergeCart(), throwsA(predicate(
        (e) => e.toString().contains('Merge failed'),
      )));
    });

    test('sends items list when provided', () async {
      final client = MockClient((request) async {
        final body = json.decode(request.body!) as Map<String, dynamic>;
        expect(body['items'], isA<List>());
        expect(body['items'].length, 1);
        expect(body['items'][0]['priceId'], 'price-1');
        return http.Response(json.encode({}), 200);
      });
      final service = CartService(client: client);
      await service.mergeCart(items: [
        {'priceId': 'price-1', 'quantity': 2, 'type': 'one_time'},
      ]);
    });
  });
}