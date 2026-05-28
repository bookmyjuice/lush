import 'package:equatable/equatable.dart';
import 'package:lush/models/order_summary.dart';
import 'package:lush/models/order_detail.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderHistoryInitial extends OrderState {
  const OrderHistoryInitial();
}

class OrderHistoryLoading extends OrderState {
  const OrderHistoryLoading();
}

class OrderHistoryLoaded extends OrderState {
  final List<OrderSummary> orders;

  const OrderHistoryLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class OrderHistoryEmpty extends OrderState {
  const OrderHistoryEmpty();
}

class OrderHistoryError extends OrderState {
  final String message;

  const OrderHistoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderDetailInitial extends OrderState {
  const OrderDetailInitial();
}

class OrderDetailLoading extends OrderState {
  const OrderDetailLoading();
}

class OrderDetailLoaded extends OrderState {
  final OrderDetail order;

  const OrderDetailLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

class OrderDetailError extends OrderState {
  final String message;

  const OrderDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}