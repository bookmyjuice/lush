import 'order_line_item.dart';
import '../views/models/address.dart';

class OrderDetail {
  final String id;
  final DateTime date;
  final String status;
  final List<OrderLineItem> lineItems;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String currency;
  final Address deliveryAddress;

  const OrderDetail({
    required this.id,
    required this.date,
    required this.status,
    required this.lineItems,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    this.currency = 'INR',
    required this.deliveryAddress,
  });

  factory OrderDetail.fromJson(Map<String, dynamic> json) {
    return OrderDetail(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      lineItems: (json['lineItems'] as List<dynamic>)
          .map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['deliveryFee'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      deliveryAddress:
          Address.fromJson(json['deliveryAddress'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'status': status,
        'lineItems': lineItems.map((e) => e.toJson()).toList(),
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'total': total,
        'currency': currency,
        'deliveryAddress': deliveryAddress.toJson(),
      };
}