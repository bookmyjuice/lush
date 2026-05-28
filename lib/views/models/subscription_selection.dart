/// Represents a user's subscription selection across screens 2-4.
/// Passed as constructor argument between screens — not stored in BLoC
/// until the final "Start Subscription" CTA on Screen 4.
class SubscriptionSelection {
  final String itemId;
  final String itemPriceId;
  final String family;
  final String size;
  final String period; // 'weekly' | 'monthly'
  final int priceInPaise;
  final String? defaultJuice; // null for generic plans
  final Map<String, String> daySchedule;
  // keys: 'monday','tuesday','wednesday','thursday','friday','saturday'
  // values: juice slug (e.g. 'mix-punch')

  const SubscriptionSelection({
    required this.itemId,
    required this.itemPriceId,
    required this.family,
    required this.size,
    required this.period,
    required this.priceInPaise,
    this.defaultJuice,
    required this.daySchedule,
  });

  double get priceInRupees => priceInPaise / 100;

  bool get isComplete =>
      daySchedule.length == 6 &&
      daySchedule.values.every((j) => j.isNotEmpty);

  bool get isJuiceSpecific => defaultJuice != null;

  Map<String, dynamic> toChargebeeMetadata() => {
        'item_price_id': itemPriceId,
        'family': family,
        'size': size,
        'period': period,
        'day_schedule': daySchedule,
      };

  SubscriptionSelection copyWith({
    String? itemId,
    String? itemPriceId,
    String? family,
    String? size,
    String? period,
    int? priceInPaise,
    String? defaultJuice,
    Map<String, String>? daySchedule,
  }) {
    return SubscriptionSelection(
      itemId: itemId ?? this.itemId,
      itemPriceId: itemPriceId ?? this.itemPriceId,
      family: family ?? this.family,
      size: size ?? this.size,
      period: period ?? this.period,
      priceInPaise: priceInPaise ?? this.priceInPaise,
      defaultJuice: defaultJuice ?? this.defaultJuice,
      daySchedule: daySchedule ?? this.daySchedule,
    );
  }
}