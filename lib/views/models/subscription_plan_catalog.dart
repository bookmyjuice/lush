import 'package:equatable/equatable.dart';

/// Represents a single price option (weekly or monthly) for a subscription plan.
class SubscriptionPriceOption extends Equatable {
  final String itemPriceId;
  final String period; // 'weekly' | 'monthly'
  final int priceInPaise;
  final int bottleCount;

  const SubscriptionPriceOption({
    required this.itemPriceId,
    required this.period,
    required this.priceInPaise,
    required this.bottleCount,
  });

  double get priceInRupees => priceInPaise / 100;

  factory SubscriptionPriceOption.fromJson(Map<String, dynamic> json) {
    final rawPeriod = json['period_unit'] as String? ?? '';

    // Determine period: 'week' → 'weekly', 'month' → 'monthly'
    String period = rawPeriod == 'week' ? 'weekly' : 'monthly';
    // Bottle count from metadata: 6 for weekly, 24 for monthly
    int bottleCount = period == 'weekly' ? 6 : 24;

    return SubscriptionPriceOption(
      itemPriceId: json['id'] as String? ?? '',
      period: period,
      priceInPaise: json['price'] is int ? json['price'] as int : 0,
      bottleCount: bottleCount,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_price_id': itemPriceId,
    'period': period,
    'price_in_paise': priceInPaise,
    'bottle_count': bottleCount,
  };

  @override
  List<Object?> get props => [itemPriceId, period, priceInPaise, bottleCount];
}

/// Represents a subscription plan catalog entry (item + its price options).
class SubscriptionPlanCatalog extends Equatable {
  final String itemId;
  final String name;
  final String family;
  final String size;
  final String planType; // 'generic' | 'juice_specific'
  final String? defaultJuice;
  final List<SubscriptionPriceOption> prices;
  final Map<String, dynamic> metadata;

  const SubscriptionPlanCatalog({
    required this.itemId,
    required this.name,
    required this.family,
    required this.size,
    required this.planType,
    this.defaultJuice,
    required this.prices,
    required this.metadata,
  });

  bool get isJuiceSpecific => planType == 'juice_specific';
  bool get isGeneric => planType == 'generic';

  SubscriptionPriceOption? get weeklyPrice =>
      prices.where((p) => p.period == 'weekly').firstOrNull;

  SubscriptionPriceOption? get monthlyPrice =>
      prices.where((p) => p.period == 'monthly').firstOrNull;

  /// Creates a SubscriptionPlanCatalog from a Chargebee item + item_prices response.
  /// Expects data shaped like Chargebee's item list response.
  factory SubscriptionPlanCatalog.fromMap(Map<String, dynamic> itemData, List<Map<String, dynamic>> priceData) {
    final metadata = itemData['metadata'] as Map<String, dynamic>? ?? {};
    final prices = priceData
        .map((p) => SubscriptionPriceOption.fromJson(p))
        .toList();

    return SubscriptionPlanCatalog(
      itemId: itemData['id'] as String? ?? '',
      name: itemData['name'] as String? ?? '',
      family: itemData['item_family_id'] as String? ?? '',
      size: metadata['size'] as String? ?? '',
      planType: metadata['plan_type'] as String? ?? 'generic',
      defaultJuice: metadata['default_juice'] as String?,
      prices: prices,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'item_id': itemId,
    'name': name,
    'family': family,
    'size': size,
    'plan_type': planType,
    'default_juice': defaultJuice,
    'prices': prices.map((p) => p.toJson()).toList(),
    'metadata': metadata,
  };

  @override
  List<Object?> get props => [itemId, name, family, size, planType, prices];
}

/// Helper extension for finding first matching element or null.
extension FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    if (iterator.moveNext()) return iterator.current;
    return null;
  }
}