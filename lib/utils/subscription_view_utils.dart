/// Presentation helpers for the subscription dashboard.
///
/// Kept out of the screen so they can be unit-tested without HTTP: the screen
/// talks to `SubscriptionService` directly, so anything it decides about dates
/// or quantities lives here instead.
///
/// The rule is the same as the price helpers: show what the backend published,
/// otherwise render the em dash — a date is never invented.
library;

/// Em dash used whenever a value is not known.
const String kDateFallback = '—';

/// Epoch seconds (or ISO string) → `YYYY-MM-DD`; [kDateFallback] when unknown.
String formatEpochDate(Object? value) {
  DateTime? parsed;
  if (value is num) {
    parsed = DateTime.fromMillisecondsSinceEpoch(value.toInt() * 1000);
  } else if (value is String) {
    parsed = DateTime.tryParse(value);
  }
  if (parsed == null) return kDateFallback;
  return parsed.toLocal().toString().split(' ').first;
}

/// Bottles per delivery.
///
/// The API exposes the count on `items[].quantity` (the entity mapper returns
/// `items`, not a top-level `quantity`), so the first item is the fallback.
/// `null` means "not known" and callers must omit the line entirely.
int? quantityOf(Map<String, dynamic> subscription) {
  final Object? direct = subscription['quantity'];
  if (direct is num) return direct.toInt();

  final Object? items = subscription['items'];
  if (items is List) {
    for (final Object? item in items) {
      if (item is Map) {
        final Object? quantity = item['quantity'];
        if (quantity is num) return quantity.toInt();
      }
    }
  }
  return null;
}

/// Next delivery date for [subscription].
///
/// Only `nextDeliveryAt` — the field the backend will publish once the day-wise
/// checkout schedule is persisted on the subscription — is rendered. Nothing is
/// derived from `nextBillingAt`: a weekly *billing* cycle does not prove the
/// delivery cadence (a weekly plan can deliver daily), so an inferred date could
/// promise a delivery on a day that is not scheduled. Until then the tile shows
/// the em dash, exactly like an unknown price.
String nextDeliveryDateLabel(Map<String, dynamic> subscription) =>
    formatEpochDate(subscription['nextDeliveryAt']);
