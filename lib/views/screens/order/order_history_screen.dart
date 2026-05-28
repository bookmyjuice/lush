import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_event.dart';
import 'package:lush/bloc/OrderBloc/order_state.dart';
import 'package:lush/models/order_summary.dart';
import 'package:lush/services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late OrderBloc _orderBloc;

  @override
  void initState() {
    super.initState();
    _orderBloc = OrderBloc(orderService: OrderService());
    _orderBloc.add(const LoadOrderHistory());
  }

  @override
  void dispose() {
    _orderBloc.close();
    super.dispose();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'placed':
        return Colors.blue;
      case 'confirmed':
        return Colors.amber;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('order_history_appbar'),
        title: const Text('Order History'),
        actions: [
          IconButton(
            key: const Key('order_history_refresh'),
            icon: const Icon(Icons.refresh),
            onPressed: () => _orderBloc.add(const RefreshOrderHistory()),
          ),
        ],
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        bloc: _orderBloc,
        builder: (context, state) {
          if (state is OrderHistoryLoading) {
            return const Center(
              key: Key('order_history_loading'),
              child: CircularProgressIndicator(),
            );
          }

          if (state is OrderHistoryEmpty) {
            return Center(
              key: const Key('empty_order_history'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No orders yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    key: const Key('order_history_browse_products'),
                    onPressed: () =>
                        Navigator.pushNamed(context, '/catalog'),
                    child: const Text('Browse Products'),
                  ),
                ],
              ),
            );
          }

          if (state is OrderHistoryError) {
            return Center(
              key: const Key('order_history_error'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _orderBloc.add(const RefreshOrderHistory()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is OrderHistoryLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                _orderBloc.add(const RefreshOrderHistory());
              },
              child: ListView.builder(
                key: const Key('order_history_list'),
                itemCount: state.orders.length,
                itemBuilder: (context, index) {
                  final order = state.orders[index];
                  return _OrderHistoryTile(
                    order: order,
                    statusColor: _statusColor(order.status),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/order-detail',
                        arguments: order.id,
                      );
                    },
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderHistoryTile extends StatelessWidget {
  final OrderSummary order;
  final Color statusColor;
  final VoidCallback onTap;

  const _OrderHistoryTile({
    required this.order,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          key: Key('order_tile_${order.id}'),
          onTap: onTap,
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.formattedDate,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '₹${order.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}