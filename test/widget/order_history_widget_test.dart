import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/OrderBloc/order_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_event.dart';
import 'package:lush/bloc/OrderBloc/order_state.dart';
import 'package:lush/models/order_summary.dart';
import 'package:lush/models/order_detail.dart';
import 'package:lush/models/order_line_item.dart';
import 'package:lush/views/models/address.dart';
import 'package:lush/views/screens/order/order_history_screen.dart';
import 'package:lush/views/screens/order/order_detail_screen.dart';
import 'package:lush/services/order_service.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderBloc extends Mock implements OrderBloc {}

class MockOrderService extends Mock implements OrderService {}

Widget createHistoryScreen(OrderBloc bloc) {
  return MaterialApp(
    home: BlocProvider<OrderBloc>.value(
      value: bloc,
      child: const OrderHistoryScreen(),
    ),
  );
}

Widget createDetailScreen(OrderBloc bloc) {
  return MaterialApp(
    home: BlocProvider<OrderBloc>.value(
      value: bloc,
      child: const OrderDetailScreen(),
    ),
  );
}

final sampleOrders = [
  OrderSummary(
    id: 'order_1',
    date: DateTime(2026, 5, 28),
    items: [
      OrderLineItem(itemId: 'i1', itemName: 'Mango Juice', quantity: 2, unitPrice: 150, lineTotal: 300),
    ],
    total: 450.0,
    currency: 'INR',
    status: 'delivered',
  ),
];

final sampleAddress = Address(
  firstName: 'Test', lastName: 'User', phone: '9876543210',
  addr: '42 MG Road', extendedAddr: 'Indiranagar', extendedAddr2: '',
  city: 'Bangalore', stateCode: 'KA', zip: '560038',
  validationStatus: true, subscriptionId: '',
);

final sampleDetail = OrderDetail(
  id: 'order_1',
  date: DateTime(2026, 5, 28),
  status: 'delivered',
  lineItems: [
    OrderLineItem(itemId: 'i1', itemName: 'Mango Juice', quantity: 2, unitPrice: 150, lineTotal: 300),
  ],
  subtotal: 400.0,
  deliveryFee: 50.0,
  total: 450.0,
  currency: 'INR',
  deliveryAddress: sampleAddress,
);

void main() {
  group('OrderHistoryScreen', () {
    testWidgets('shows loading indicator on OrderHistoryLoading',
        (tester) async {
      final bloc = MockOrderBloc();
      when(() => bloc.state).thenReturn(const OrderHistoryLoading());
      when(() => bloc.stream).thenAnswer((_) => Stream.value(const OrderHistoryLoading()));

      await tester.pumpWidget(createHistoryScreen(bloc));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state on OrderHistoryEmpty', (tester) async {
      final bloc = MockOrderBloc();
      when(() => bloc.state).thenReturn(const OrderHistoryEmpty());
      when(() => bloc.stream).thenAnswer((_) => Stream.value(const OrderHistoryEmpty()));

      await tester.pumpWidget(createHistoryScreen(bloc));
      expect(find.text('No orders yet'), findsOneWidget);
      expect(find.text('Browse Products'), findsOneWidget);
    });

    testWidgets('shows list on OrderHistoryLoaded', (tester) async {
      final bloc = MockOrderBloc();
      when(() => bloc.state).thenReturn(OrderHistoryLoaded(orders: sampleOrders));
      when(() => bloc.stream).thenAnswer((_) => Stream.value(OrderHistoryLoaded(orders: sampleOrders)));

      await tester.pumpWidget(createHistoryScreen(bloc));
      expect(find.text('28 May 2026'), findsOneWidget);
      expect(find.text('DELIVERED'), findsOneWidget);
    });
  });

  group('OrderDetailScreen', () {
    testWidgets('shows loading indicator on OrderDetailLoading',
        (tester) async {
      final bloc = MockOrderBloc();
      when(() => bloc.state).thenReturn(const OrderDetailLoading());
      when(() => bloc.stream).thenAnswer((_) => Stream.value(const OrderDetailLoading()));

      await tester.pumpWidget(createDetailScreen(bloc));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows all four cards when loaded', (tester) async {
      final bloc = MockOrderBloc();
      when(() => bloc.state).thenReturn(OrderDetailLoaded(order: sampleDetail));
      when(() => bloc.stream).thenAnswer((_) => Stream.value(OrderDetailLoaded(order: sampleDetail)));

      await tester.pumpWidget(createDetailScreen(bloc));
      expect(find.text('Order ID: order_1'), findsOneWidget);
      expect(find.text('Items'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('Delivery Address'), findsOneWidget);
    });

    testWidgets('reorder button is visible', (tester) async {
      final bloc = MockOrderBloc();
      when(() => bloc.state).thenReturn(OrderDetailLoaded(order: sampleDetail));
      when(() => bloc.stream).thenAnswer((_) => Stream.value(OrderDetailLoaded(order: sampleDetail)));

      await tester.pumpWidget(createDetailScreen(bloc));
      expect(find.text('Reorder'), findsOneWidget);
    });
  });
}