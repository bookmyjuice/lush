import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:lush/views/models/Juice.dart';

abstract class CartState extends Equatable {
  const CartState({Key? key, required this.juices});
  final List<Juice?> juices;

  @override
  List<Juice?> get props => [];
}

class CartEmpty extends CartState {
  CartEmpty() : super(juices: []);

  @override
  List<Juice?> get props => [];
}

class CartNotEmpty extends CartState {
  const CartNotEmpty({required super.juices});

  addJuice(Juice juice) {
    super.juices.add(juice);
  }

  removeJuice(Juice juice) {
    super.juices.remove(juice);
  }

  @override
  List<Juice?> get props => [...juices];
}
