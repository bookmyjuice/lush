import 'package:equatable/equatable.dart';
import 'package:lush/views/models/Juice.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class CartItemAdded extends CartEvent {
  final Juice juice;

  const CartItemAdded(this.juice);

  @override
  List<Object?> get props => [juice];
}

class CartItemRemoved extends CartEvent {
  final Juice juice;

  const CartItemRemoved(this.juice);

  @override
  List<Object?> get props => [juice];
}

class CartEmptied extends CartEvent {
  const CartEmptied();

  @override
  List<Object?> get props => [];
}

class UpdateQuantity extends CartEvent {
  final Juice juice;
  final int newQuantity;

  const UpdateQuantity(this.juice, this.newQuantity);

  @override
  List<Object?> get props => [juice, newQuantity];
}

class ClearCart extends CartEvent {
  const ClearCart();

  @override
  List<Object?> get props => [];
}
