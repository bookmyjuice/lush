import 'package:equatable/equatable.dart';
import 'package:lush/views/models/Juice.dart';

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartEmpty extends CartState {
  const CartEmpty();

  @override
  List<Object?> get props => [];
}

class CartNotEmpty extends CartState {
  final List<Juice> juices;

  const CartNotEmpty({required this.juices});

  @override
  List<Object?> get props => [juices];
}