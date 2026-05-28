import 'package:equatable/equatable.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderHistory extends OrderEvent {
  const LoadOrderHistory();
}

class RefreshOrderHistory extends OrderEvent {
  const RefreshOrderHistory();
}

class LoadOrderDetail extends OrderEvent {
  final String orderId;

  const LoadOrderDetail({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}