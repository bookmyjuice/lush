import 'package:equatable/equatable.dart';

import 'item.dart';

class CartItem extends Equatable {
  final Item item;
  final int quantity;
  final String? selectedSize;
  final Map<String, dynamic>? customizations;
  final ItemPrice? selectedPrice; // Add this for selected price/variety

  const CartItem({
    required this.item,
    this.quantity = 1,
    this.selectedSize,
    this.customizations,
    this.selectedPrice,
  });

  CartItem copyWith({
    Item? item,
    int? quantity,
    String? selectedSize,
    Map<String, dynamic>? customizations,
    ItemPrice? selectedPrice,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      selectedSize: selectedSize ?? this.selectedSize,
      customizations: customizations ?? this.customizations,
      selectedPrice: selectedPrice ?? this.selectedPrice,
    );
  }

  String get type => item.type ?? 'CHARGE';

  double get totalPrice => (selectedPrice?.price ?? 0.0) * quantity;

  @override
  List<Object?> get props =>
      [item, quantity, selectedSize, customizations, selectedPrice];

  @override
  String toString() {
    return 'CartItem(item: ${item.name}, quantity: $quantity, price: ${totalPrice.toStringAsFixed(2)})';
  }
}
