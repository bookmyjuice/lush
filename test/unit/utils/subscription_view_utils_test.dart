/// Unit tests for the subscription dashboard date/quantity helpers.
///
/// These lock the "never invent a date" rule: the dashboard may only show a
/// delivery date the backend published, or one derived from the documented
/// prepaid-cycle invariant (daily/weekly + ACTIVE). Everything else is an em
/// dash.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lush/utils/subscription_view_utils.dart';

/// 2026-11-04 00:00:00 IST as Chargebee seconds.
const int _nov4 = 1793740200;

void main() {
  group('formatEpochDate', () {
    test('formats epoch seconds as YYYY-MM-DD', () {
      expect(formatEpochDate(_nov4), '2026-11-04');
    });

    test('accepts an ISO string', () {
      expect(formatEpochDate('2026-11-14T00:00:00Z'), '2026-11-14');
    });

    test('renders the fallback for null and garbage', () {
      expect(formatEpochDate(null), kDateFallback);
      expect(formatEpochDate('not-a-date'), kDateFallback);
    });
  });

  group('quantityOf', () {
    test('reads the top-level quantity when present', () {
      expect(quantityOf(<String, dynamic>{'quantity': 2}), 2);
    });

    test('falls back to the first item quantity (the API shape)', () {
      expect(
        quantityOf(<String, dynamic>{
          'items': <dynamic>[
            <String, dynamic>{'itemPriceId': 'p-200', 'quantity': 3},
          ],
        }),
        3,
      );
    });

    test('returns null when nothing is known', () {
      expect(quantityOf(<String, dynamic>{}), isNull);
      expect(quantityOf(<String, dynamic>{'items': <dynamic>[]}), isNull);
    });
  });

  group('nextDeliveryDateLabel', () {
    test('renders the published nextDeliveryAt', () {
      expect(
        nextDeliveryDateLabel(<String, dynamic>{'nextDeliveryAt': _nov4}),
        '2026-11-04',
      );
    });

    test('accepts an ISO timestamp too', () {
      expect(
        nextDeliveryDateLabel(<String, dynamic>{
          'nextDeliveryAt': '2026-11-14T00:00:00Z',
        }),
        '2026-11-14',
      );
    });

    test('never derives a delivery date from the billing cycle', () {
      expect(
        nextDeliveryDateLabel(<String, dynamic>{
          'status': 'active',
          'billingPeriodUnit': 'week',
          'nextBillingAt': _nov4,
        }),
        kDateFallback,
        reason: 'a billing date is not a confirmed delivery date',
      );
    });

    test('renders the fallback when the payload is empty', () {
      expect(nextDeliveryDateLabel(<String, dynamic>{}), kDateFallback);
    });
  });
}
