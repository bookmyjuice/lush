/// Unit tests for [ReferralInfo] model.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lush/models/referral_info.dart';

void main() {
  group('ReferralInfo', () {
    test('constructor sets fields correctly', () {
      const info = ReferralInfo(
        referralCode: 'TEST123',
        referralCount: 2,
        totalRewardAmount: 100.0,
      );
      expect(info.referralCode, 'TEST123');
      expect(info.referralCount, 2);
      expect(info.totalRewardAmount, 100.0);
    });

    test('constructor defaults count to 0 and amount to 0.0', () {
      const info = ReferralInfo(
        referralCode: 'CODE01',
        referralCount: 0,
        totalRewardAmount: 0.0,
      );
      expect(info.referralCount, 0);
      expect(info.totalRewardAmount, 0.0);
    });

    test('fromJson parses fields correctly', () {
      final json = {
        'referralCode': 'MYCODE',
        'referralCount': 5,
        'totalRewardAmount': 250.0,
      };
      final info = ReferralInfo.fromJson(json);
      expect(info.referralCode, 'MYCODE');
      expect(info.referralCount, 5);
      expect(info.totalRewardAmount, 250.0);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final info = ReferralInfo.fromJson(json);
      expect(info.referralCode, '');
      expect(info.referralCount, 0);
      expect(info.totalRewardAmount, 0.0);
    });

    test('toJson returns correct map', () {
      const info = ReferralInfo(
        referralCode: 'CODE42',
        referralCount: 3,
        totalRewardAmount: 75.0,
      );
      final json = info.toJson();
      expect(json['referralCode'], 'CODE42');
      expect(json['referralCount'], 3);
      expect(json['totalRewardAmount'], 75.0);
    });

    test('fromJson and toJson round-trip', () {
      final json = {
        'referralCode': 'ROUNDTRIP',
        'referralCount': 10,
        'totalRewardAmount': 500.0,
      };
      final info = ReferralInfo.fromJson(json);
      final output = info.toJson();
      expect(output['referralCode'], 'ROUNDTRIP');
      expect(output['referralCount'], 10);
      expect(output['totalRewardAmount'], 500.0);
    });

    test('equals/hashCode compares all fields', () {
      const a = ReferralInfo(referralCode: 'A', referralCount: 1, totalRewardAmount: 10.0);
      const b = ReferralInfo(referralCode: 'A', referralCount: 1, totalRewardAmount: 10.0);
      const c = ReferralInfo(referralCode: 'A', referralCount: 2, totalRewardAmount: 10.0);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}