import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_event.dart';
import 'package:lush/bloc/OrderBloc/order_state.dart';
import 'package:lush/models/order_summary.dart';
import 'package:lush/models/order_detail.dart';
import 'package:lush/models/order_line_item.dart';
import 'package:lush/services/order_service.dart';
import 'package:lush/views/models/address.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderService _orderService;
  bool _isClosed = false;

  OrderBloc({required OrderService orderService})
      : _orderService = orderService,
        super(const OrderHistoryInitial()) {
    on<LoadOrderHistory>(_onLoadOrderHistory);
    on<RefreshOrderHistory>(_onRefreshOrderHistory);
    on<LoadOrderDetail>(_onLoadOrderDetail);
  }

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  @override
  bool get isClosed => _isClosed;

  Future<void> _onLoadOrderHistory(
      LoadOrderHistory event, Emitter<OrderState> emit,) async {
    emit(const OrderHistoryLoading());
    try {
      final rawOrders = await _orderService.getMyOrders();
      if (_isClosed) return;

      if (rawOrders.isEmpty) {
        emit(const OrderHistoryEmpty());
        return;
      }

      final orders = rawOrders.map((json) {
        final items = (json['line_items'] as List<dynamic>?)
                ?.map((item) => OrderLineItem(
                      itemId: item['item_id']?.toString() ?? '',
                      itemName: item['item_name']?.toString() ?? 'Item',
                      quantity: (item['quantity'] as num?)?.toInt() ?? 1,
                      unitPrice: (item['unit_price'] as num?)?.toDouble() ?? 0.0,
                      lineTotal: (item['amount'] as num?)?.toDouble() ?? 0.0,
                    ),)
                .toList() ??
            [];

        return OrderSummary(
          id: json['id']?.toString() ?? '',
          date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
          items: items,
          total: (json['total'] as num?)?.toDouble() ?? 0.0,
          currency: json['currency']?.toString() ?? 'INR',
          status: json['status']?.toString() ?? 'placed',
        );
      }).toList();

      emit(OrderHistoryLoaded(orders: orders));
    } catch (e) {
      if (_isClosed) return;
      emit(OrderHistoryError(message: e.toString()));
    }
  }

  Future<void> _onRefreshOrderHistory(
      RefreshOrderHistory event, Emitter<OrderState> emit,) async {
    emit(const OrderHistoryLoading());
    await _onLoadOrderHistory(const LoadOrderHistory(), emit);
  }

  Future<void> _onLoadOrderDetail(
      LoadOrderDetail event, Emitter<OrderState> emit,) async {
    emit(const OrderDetailLoading());
    try {
      final raw = await _orderService.getOrderDetails(event.orderId);
      if (_isClosed) return;

      final lineItems = (raw['line_items'] as List<dynamic>?)
              ?.map((item) => OrderLineItem(
                    itemId: item['item_id']?.toString() ?? '',
                    itemName: item['item_name']?.toString() ?? 'Item',
                    quantity: (item['quantity'] as num?)?.toInt() ?? 1,
                    unitPrice: (item['unit_price'] as num?)?.toDouble() ?? 0.0,
                    lineTotal: (item['amount'] as num?)?.toDouble() ?? 0.0,
                  ),)
              .toList() ??
          [];

      final address = Address(
        firstName: raw['shipping_address']?['first_name']?.toString() ?? '',
        lastName: raw['shipping_address']?['last_name']?.toString() ?? '',
        phone: raw['shipping_address']?['phone']?.toString() ?? '',
        addr: raw['shipping_address']?['line1']?.toString() ?? '',
        extendedAddr: raw['shipping_address']?['line2']?.toString() ?? '',
        extendedAddr2: raw['shipping_address']?['line3']?.toString() ?? '',
        city: raw['shipping_address']?['city']?.toString() ?? '',
        stateCode: raw['shipping_address']?['state']?.toString() ?? '',
        zip: raw['shipping_address']?['zip']?.toString() ?? '',
        validationStatus: true,
        subscriptionId: '',
      );

      final detail = OrderDetail(
        id: raw['id']?.toString() ?? event.orderId,
        date: DateTime.tryParse(raw['date']?.toString() ?? '') ?? DateTime.now(),
        status: raw['status']?.toString() ?? 'placed',
        lineItems: lineItems,
        subtotal: (raw['subtotal'] as num?)?.toDouble() ?? 0.0,
        deliveryFee: (raw['delivery_fee'] as num?)?.toDouble() ?? 0.0,
        total: (raw['total'] as num?)?.toDouble() ?? 0.0,
        currency: raw['currency']?.toString() ?? 'INR',
        deliveryAddress: address,
      );

      emit(OrderDetailLoaded(order: detail));
    } catch (e) {
      if (_isClosed) return;
      emit(OrderDetailError(message: e.toString()));
    }
  }
}