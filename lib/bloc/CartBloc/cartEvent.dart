
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:lush/views/models/Juice.dart';

abstract class CartEvent extends Equatable {
  const CartEvent({Key? key});
  @override
  List<Object?> get props => [];
}

class CartItemAdded extends CartEvent{
  final Juice juice;
  const CartItemAdded(this.juice);
}

class CartItemRemoved extends CartEvent{
  final Juice juice;
  const CartItemRemoved(this.juice);
}
class CartEmptied extends CartEvent{
  // final Juice juice;
  const CartEmptied();
}

class AddItem extends CartEvent {
  final Juice product;
  final int quantity;

  const AddItem(this.product, this.quantity);

  @override
  List<Object> get props => [product, quantity];
}

class RemoveItem extends CartEvent {
  final Juice product;

  const RemoveItem(this.product);

  @override
  List<Object> get props => [product];
}

class UpdateQuantity extends CartEvent {
  final Juice product;
  final int newQuantity;

  const UpdateQuantity(this.product, this.newQuantity);

  @override
  List<Object> get props => [product, newQuantity];
}

class ClearCart extends CartEvent {
  @override
  List<Object> get props => [];
}