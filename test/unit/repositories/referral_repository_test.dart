/// Unit tests for [ReferralRepository].
///
/// Covers: getReferralInfo, applyReferralCode.
///
/// Uses [MockClient] from package:http/testing.dart to mock HTTP responses,
/// and [MockSecureStorageService] (mocktail) to inject test tokens.
library;

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lush/models/referral_info.dart';
import 'package:lush/repositories/referral_repository.dart';
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

  // ─── getReferralInfo ────────────────────────────────────────
  group('getReferralInfo', () {
    test('returns ReferralInfo on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.toString(), '$baseUrl/api/referral/code');
        return http.Response(
          json.encode({
            'referralCode': 'ABC123',
            'referralCount': 5,
            'totalRewardAmount': 25.0,
          }),
          200,
        );
      });
      final repo = ReferralRepository(client: client);
      final result = await repo.getReferralInfo();
      expect(result, isA<ReferralInfo>());
      expect(result.referralCode, 'ABC123');
      expect(result.referralCount, 5);
      expect(result.totalRewardAmount, 25.0);
    });

    test('returns ReferralInfo with defaults when fields are missing', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({}), 200));
      final repo = ReferralRepository(client: client);
      final result = await repo.getReferralInfo();
      expect(result.referralCode, '');
      expect(result.referralCount, 0);
      expect(result.totalRewardAmount, 0.0);
    });

    test('throws on non-200', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'error': 'Server error'}), 500));
      final repo = ReferralRepository(client: client);
      expect(() => repo.getReferralInfo(), throwsA(predicate(
        (e) => e.toString().contains('Failed to load referral info'),
      )));
    });

    test('propagates network exceptions', () async {
      final client = MockClient((_) async => throw Exception('Connection lost'));
      final repo = ReferralRepository(client: client);
      expect(() => repo.getReferralInfo(), throwsA(predicate(
        (e) => e.toString().contains('Connection lost'),
      )));
    });
  });

  // ─── applyReferralCode ──────────────────────────────────────
  group('applyReferralCode', () {
    test('returns true on 200', () async {
      final client = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.toString(), '$baseUrl/api/referral/apply');
        final body = json.decode(request.body!) as Map<String, dynamic>;
        expect(body['referralCode'], 'ABC123');
        return http.Response(json.encode({'message': 'Applied'}), 200);
      });
      final repo = ReferralRepository(client: client);
      final result = await repo.applyReferralCode('ABC123');
      expect(result, true);
    });

    test('returns false on non-200', () async {
      final client = MockClient((_) async =>
          http.Response(json.encode({'error': 'Invalid code'}), 400));
      final repo = ReferralRepository(client: client);
      final result = await repo.applyReferralCode('INVALID');
      expect(result, false);
    });

    test('propagates network exceptions', () async {
      final client = MockClient((_) async => throw Exception('Connection lost'));
      final repo = ReferralRepository(client: client);
      expect(() => repo.applyReferralCode('x'), throwsA(predicate(
        (e) => e.toString().contains('Connection lost'),
      )));
    });
  });
}