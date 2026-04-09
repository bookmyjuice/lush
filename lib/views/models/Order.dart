import 'dart:convert';

class Order {
  final String id;
  final String documentNumber;
  final String status;
  final String createdAt;
  final int total;
  final String paymentStatus;
  final List<String> items;

  Order({
    required this.id,
    required this.documentNumber,
    required this.status,
    required this.createdAt,
    required this.total,
    required this.paymentStatus,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<String> items = [];
    try {
      if (json['orderLineItems'] != null && json['orderLineItems'] is String) {
        var parsed = jsonDecode(json['orderLineItems'] as String);
        if (parsed is List) {
          items = parsed.map<String>((e) {
            if (e is Map<String, dynamic>) {
              // Try to extract name and price
              String name = (e['name'] ?? e['description'] ?? '') as String;
              String price = '';
              if (e['price'] != null) {
                price = '₹${e['price']}';
              } else if (e['itemPrice'] != null && e['itemPrice'] is Map) {
                var itemPrice = e['itemPrice'];
                if (itemPrice['price'] != null) {
                  price = '₹${itemPrice['price']}';
                }
              }
              if (name.isNotEmpty && price.isNotEmpty) {
                return '$name ($price)';
              } else if (name.isNotEmpty) {
                return name;
              } else if (price.isNotEmpty) {
                return price;
              } else {
                return e.toString();
              }
            } else if (e is String) {
              return e;
            } else {
              return e.toString();
            }
          }).toList();
        }
      }
    } catch (_) {}
    return Order(
      id: (json['id'] as String?) ?? '',
      documentNumber: (json['documentNumber'] as String?) ?? '',
      status: (json['status'] as String?) ?? '',
      createdAt: (json['createdAt'] as String?) ?? '',
      total: json['total'] is int
          ? json['total'] as int
          : int.tryParse(json['total'].toString()) ?? 0,
      paymentStatus: (json['paymentStatus'] as String?) ?? '',
      items: items,
    );
  }
}
