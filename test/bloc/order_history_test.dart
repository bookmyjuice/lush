import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/OrderBloc/order_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_event.dart';
import 'package:lush/bloc/OrderBloc/order_state.dart';
import 'package:lush/services/order_service.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderService extends Mock implements OrderService {}

void main() {
  late MockOrderService mockService;
  late OrderBloc orderBloc;

  setUp(() {
    mockService = MockOrderService();
    orderBloc = OrderBloc(orderService: mockService);
  });

  tearDown(() {
    orderBloc.close();
  });

  group('LoadOrderHistory', () {
    blocTest<OrderBloc, OrderState>(
      'emits [OrderHistoryLoading, OrderHistoryLoaded] on success',
      build: () {
        when(() => mockService.getMyOrders()).thenAnswer((_) async => [
              {
                'id': 'order_1',
                'date': '2026-05-28T10:00:00Z',
                'total': 450.0,
                'currency': 'INR',
                'status': 'delivered',
                'line_items': [
                  {'item_id': 'item_1', 'item_name': 'Mango Juice', 'quantity': 2, 'unit_price': 150.0, 'amount': 300.0},
                  {'item_id': 'item_2', 'item_name': 'Apple Juice', 'quantity': 1, 'unit_price': 150.0, 'amount': 150.0},
                ],
              },
            ],);
        return orderBloc;
      },
      act: (bloc) => bloc.add(const LoadOrderHistory()),
      expect: () => [
        isA<OrderHistoryLoading>(),
        isA<OrderHistoryLoaded>(),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [OrderHistoryLoading, OrderHistoryEmpty] when list empty',
      build: () {
        when(() => mockService.getMyOrders()).thenAnswer((_) async => []);
        return orderBloc;
      },
      act: (bloc) => bloc.add(const LoadOrderHistory()),
      expect: () => [
        isA<OrderHistoryLoading>(),
        isA<OrderHistoryEmpty>(),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [OrderHistoryLoading, OrderHistoryError] on failure',
      build: () {
        when(() => mockService.getMyOrders()).thenThrow(Exception('API error'));
        return orderBloc;
      },
      act: (bloc) => bloc.add(const LoadOrderHistory()),
      expect: () => [
        isA<OrderHistoryLoading>(),
        isA<OrderHistoryError>(),
      ],
    );
  });

  group('LoadOrderDetail', () {
    blocTest<OrderBloc, OrderState>(
      'emits [OrderDetailLoading, OrderDetailLoaded] on success',
      build: () {
        when(() => mockService.getOrderDetails('order_1')).thenAnswer((_) async => {
              'id': 'order_1',
              'date': '2026-05-28T10:00:00Z',
              'status': 'delivered',
              'subtotal': 400.0,
              'delivery_fee': 50.0,
              'total': 450.0,
              'currency': 'INR',
              'line_items': [
                {'item_id': 'item_1', 'item_name': 'Mango Juice', 'quantity': 2, 'unit_price': 150.0, 'amount': 300.0},
              ],
              'shipping_address': {
                'first_name': 'Test', 'last_name': 'User', 'phone': '9876543210',
                'line1': '42 MG Road', 'line2': 'Indiranagar', 'city': 'Bangalore',
                'state': 'KA', 'zip': '560038',
              },
            },);
        return orderBloc;
      },
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId: 'order_1')),
      expect: () => [
        isA<OrderDetailLoading>(),
        isA<OrderDetailLoaded>(),
      ],
    );

    blocTest<OrderBloc, OrderState>(
      'emits [OrderDetailLoading, OrderDetailError] on failure',
      build: () {
        when(() => mockService.getOrderDetails('bad_id'))
            .thenThrow(Exception('Not found'));
        return orderBloc;
      },
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId: 'bad_id')),
      expect: () => [
        isA<OrderDetailLoading>(),
        isA<OrderDetailError>(),
      ],
    );
  });

  group('isClosed guard', () {
    late OrderBloc freshBloc;

    setUp(() {
      freshBloc = OrderBloc(orderService: MockOrderService());
    });

    tearDown(() {
      freshBloc.close();
    });

    test('isClosed returns true after close', () {
      expect(freshBloc.isClosed, false);
      freshBloc.close();
      expect(freshBloc.isClosed, true);
    });

    test('events after close do not emit', () async {
      expect(freshBloc.isClosed, false);
      freshBloc.close();
      expect(freshBloc.isClosed, true);
      // After close, add() throws StateError — verify it throws
      try {
        freshBloc.add(const LoadOrderHistory());
        fail('Expected StateError was not thrown');
      } on StateError {
        // Expected — cannot add events after close
      }
    });
  });
}