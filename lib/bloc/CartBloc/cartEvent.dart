
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