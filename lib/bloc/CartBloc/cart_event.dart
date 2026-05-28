import '../../views/models/cart_item.dart';
import 'package:equatable/equatable.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class LoadCart extends CartEvent {}

class AddToCart extends CartEvent {
  final CartItem item;
  const AddToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveFromCart extends CartEvent {
  final CartItem item;
  const RemoveFromCart(this.item);

  @override
  List<Object?> get props => [item];
}

class ClearCart extends CartEvent {}

class UpdateCartItem extends CartEvent {
  final CartItem item;
  const UpdateCartItem(this.item);

  @override
  List<Object?> get props => [item];
}

class PlaceOneTimeOrder extends CartEvent {
  final List<CartItem> items;
  final String deliveryAddress;
  final DateTime deliveryDate;

  const PlaceOneTimeOrder({
    required this.items,
    required this.deliveryAddress,
    required this.deliveryDate,
  });

  @override
  List<Object?> get props => [items, deliveryAddress, deliveryDate];
}

class ReorderItems extends CartEvent {
  final String orderId;
  final List<Map<String, dynamic>> items;

  const ReorderItems({required this.orderId, required this.items});

  @override
  List<Object?> get props => [orderId, items];
}