/// Unit tests for [ProductsRepository].
///
/// Covers: getProducts, getProductById, getProductsByFamily,
/// searchProducts, getFeaturedProducts.
///
/// Uses [MockClient] from package:http/testing.dart to mock HTTP responses,
/// and [MockSecureStorageService] (mocktail) to inject test tokens.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lush/repositories/products_repository.dart';
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
    baseUrl = 'http://localhost:8080';
  });

  tearDown(() {
    SecureStorageService.resetTestInstance();
  });

  // ─── getProducts ────────────────────────────────────────────
  group('getProducts', () {
    test('returns product list on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/products');
        return http.Response(
          json.encode([
            {'id': 'prod-1', 'name': 'Juice', 'price': 10.0},
            {'id': 'prod-2', 'name': 'Smoothie', 'price': 15.0},
          ]),
          200,
        );
      });
      final repo = ProductsRepository(client: client);
      final result = await repo.getProducts();
      expect(result.length, 2);
      expect(result[0]['name'], 'Juice');
    });

    test('returns empty list when body is not a list', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'error': 'bad'}), 200));
      final repo = ProductsRepository(client: client);
      final result = await repo.getProducts();
      expect(result, isEmpty);
    });

    test('throws on non-200 status', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'error': 'Server error'}), 500));
      final repo = ProductsRepository(client: client);
      expect(() => repo.getProducts(), throwsA(predicate(
        (e) => e.toString().contains('Failed to load products'),
      )));
    });

    test('propagates network exceptions', () async {
      final client = MockClient((_) async => throw Exception('Connection lost'));
      final repo = ProductsRepository(client: client);
      expect(() => repo.getProducts(), throwsA(predicate(
        (e) => e.toString().contains('Connection lost'),
      )));
    });
  });

  // ─── getProductById ─────────────────────────────────────────
  group('getProductById', () {
    test('returns product map on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/products/prod-1');
        return http.Response(
          json.encode({'id': 'prod-1', 'name': 'Juice', 'price': 10.0}),
          200,
        );
      });
      final repo = ProductsRepository(client: client);
      final result = await repo.getProductById('prod-1');
      expect(result['id'], 'prod-1');
      expect(result['name'], 'Juice');
    });

    test('throws on 404', () async {
      final client = MockClient((_) async => http.Response('Not found', 404));
      final repo = ProductsRepository(client: client);
      expect(() => repo.getProductById('missing'), throwsA(predicate(
        (e) => e.toString().contains('Product not found'),
      )));
    });

    test('throws when response body is not a map on 200', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode(['not_a_map']), 200));
      final repo = ProductsRepository(client: client);
      expect(() => repo.getProductById('bad'), throwsA(predicate(
        (e) => e.toString().contains('Invalid response format'),
      )));
    });

    test('throws on non-200/404 status', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'error': 'Server error'}), 500));
      final repo = ProductsRepository(client: client);
      expect(() => repo.getProductById('x'), throwsA(predicate(
        (e) => e.toString().contains('Failed to load product'),
      )));
    });
  });

  // ─── getProductsByFamily ────────────────────────────────────
  group('getProductsByFamily', () {
    test('returns product list for family on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/products/family/juice');
        return http.Response(
          json.encode([
            {'id': 'prod-1', 'name': 'Orange Juice'},
          ]),
          200,
        );
      });
      final repo = ProductsRepository(client: client);
      final result = await repo.getProductsByFamily('juice');
      expect(result.length, 1);
    });

    test('returns empty list when body is not a list on 200', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'single': 'object'}), 200));
      final repo = ProductsRepository(client: client);
      final result = await repo.getProductsByFamily('detox');
      expect(result, isEmpty);
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 500));
      final repo = ProductsRepository(client: client);
      expect(() => repo.getProductsByFamily('x'), throwsA(predicate(
        (e) => e.toString().contains('Failed to load products by family'),
      )));
    });
  });

  // ─── searchProducts ─────────────────────────────────────────
  group('searchProducts', () {
    test('returns search results on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString().contains('/api/products/search'), true);
        expect(request.url.queryParameters['q'], 'orange');
        return http.Response(
          json.encode([
            {'id': 'prod-1', 'name': 'Orange Juice'},
          ]),
          200,
        );
      });
      final repo = ProductsRepository(client: client);
      final result = await repo.searchProducts('orange');
      expect(result.length, 1);
    });

    test('returns empty list when body is not a list', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({}), 200));
      final repo = ProductsRepository(client: client);
      final result = await repo.searchProducts('x');
      expect(result, isEmpty);
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 500));
      final repo = ProductsRepository(client: client);
      expect(() => repo.searchProducts('x'), throwsA(predicate(
        (e) => e.toString().contains('Failed to search products'),
      )));
    });
  });

  // ─── getFeaturedProducts ────────────────────────────────────
  group('getFeaturedProducts', () {
    test('returns featured products on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/products/featured');
        return http.Response(
          json.encode([
            {'id': 'feat-1', 'name': 'Featured Juice'},
          ]),
          200,
        );
      });
      final repo = ProductsRepository(client: client);
      final result = await repo.getFeaturedProducts();
      expect(result.length, 1);
    });

    test('returns empty list when body is not a list', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode(null), 200));
      final repo = ProductsRepository(client: client);
      final result = await repo.getFeaturedProducts();
      expect(result, isEmpty);
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async => http.Response('', 500));
      final repo = ProductsRepository(client: client);
      expect(() => repo.getFeaturedProducts(), throwsA(predicate(
        (e) => e.toString().contains('Failed to load featured products'),
      )));
    });
  });
}