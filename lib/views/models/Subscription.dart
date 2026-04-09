/// Model class for Subscription data
class Subscription {
  final String id;
  final String customerId;
  final String planId;
  final String status;
  final String? billingPeriod;
  final String? billingPeriodUnit;
  final int? currentTermStart;
  final int? currentTermEnd;
  final int? nextBillingAt;
  final int? createdAt;
  final int? updatedAt;
  final List<SubscriptionItem>? items;
  final bool? renewed;

  Subscription({
    required this.id,
    required this.customerId,
    required this.planId,
    required this.status,
    this.billingPeriod,
    this.billingPeriodUnit,
    this.currentTermStart,
    this.currentTermEnd,
    this.nextBillingAt,
    this.createdAt,
    this.updatedAt,
    this.items,
    this.renewed,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json['id'] as String? ?? '',
      customerId: json['customerId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      billingPeriod: json['billingPeriod'] as String?,
      billingPeriodUnit: json['billingPeriodUnit'] as String?,
      currentTermStart: json['currentTermStart'] as int?,
      currentTermEnd: json['currentTermEnd'] as int?,
      nextBillingAt: json['nextBillingAt'] as int?,
      createdAt: json['createdAt'] as int?,
      updatedAt: json['updatedAt'] as int?,
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => SubscriptionItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      renewed: json['renewed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'planId': planId,
      'status': status,
      'billingPeriod': billingPeriod,
      'billingPeriodUnit': billingPeriodUnit,
      'currentTermStart': currentTermStart,
      'currentTermEnd': currentTermEnd,
      'nextBillingAt': nextBillingAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'items': items?.map((item) => item.toJson()).toList(),
      'renewed': renewed,
    };
  }

  /// Get formatted start date
  String getStartDate() {
    if (currentTermStart == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(currentTermStart! * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get formatted end date
  String getEndDate() {
    if (currentTermEnd == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(currentTermEnd! * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get formatted next billing date
  String getNextBillingDate() {
    if (nextBillingAt == null) return 'N/A';
    final date = DateTime.fromMillisecondsSinceEpoch(nextBillingAt! * 1000);
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Get formatted billing period string
  String getBillingPeriodString() {
    if (billingPeriod == null || billingPeriodUnit == null) return 'N/A';
    final unit = billingPeriodUnit == 'month' ? 'Monthly' : 'Weekly';
    return '₹$billingPeriod / $unit';
  }

  /// Get status display color
  String getStatusColor() {
    switch (status.toLowerCase()) {
      case 'active':
        return 'FF4CAF50'; // Green
      case 'paused':
        return 'FFFFC107'; // Yellow
      case 'cancelled':
        return 'FFF44336'; // Red
      case 'expired':
        return 'FF9E9E9E'; // Grey
      default:
        return 'FF2196F3'; // Blue
    }
  }

  /// Get status display text
  String getStatusText() {
    return status.toUpperCase();
  }
}

/// Model class for Subscription Item
class SubscriptionItem {
  final String itemPriceId;
  final String? itemType;
  final int? quantity;
  final double? unitPrice;
  final double? amount;
  final int? currentTermStart;
  final int? currentTermEnd;
  final int? nextBillingAt;
  final String? billingPeriod;
  final String? billingPeriodUnit;

  SubscriptionItem({
    required this.itemPriceId,
    this.itemType,
    this.quantity,
    this.unitPrice,
    this.amount,
    this.currentTermStart,
    this.currentTermEnd,
    this.nextBillingAt,
    this.billingPeriod,
    this.billingPeriodUnit,
  });

  factory SubscriptionItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionItem(
      itemPriceId: (json['itemPriceId'] as String?) ?? '',
      itemType: json['itemType'] as String?,
      quantity: json['quantity'] as int?,
      unitPrice: json['unitPrice'] != null
          ? (json['unitPrice'] as num).toDouble()
          : null,
      amount: json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      currentTermStart: json['currentTermStart'] as int?,
      currentTermEnd: json['currentTermEnd'] as int?,
      nextBillingAt: json['nextBillingAt'] as int?,
      billingPeriod: json['billingPeriod'] as String?,
      billingPeriodUnit: json['billingPeriodUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemPriceId': itemPriceId,
      'itemType': itemType,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'amount': amount,
      'currentTermStart': currentTermStart,
      'currentTermEnd': currentTermEnd,
      'nextBillingAt': nextBillingAt,
      'billingPeriod': billingPeriod,
      'billingPeriodUnit': billingPeriodUnit,
    };
  }
}
