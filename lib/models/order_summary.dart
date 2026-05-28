import 'order_line_item.dart';

class OrderSummary {
  final String id;
  final DateTime date;
  final List<OrderLineItem> items;
  final double total;
  final String currency;
  final String status;

  const OrderSummary({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
    this.currency = 'INR',
    required this.status,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      items: (json['items'] as List<dynamic>)
          .map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'currency': currency,
        'status': status,
      };

  String get formattedDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}