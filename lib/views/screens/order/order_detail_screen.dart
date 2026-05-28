import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/bloc/OrderBloc/order_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_event.dart';
import 'package:lush/bloc/OrderBloc/order_state.dart';
import 'package:lush/models/order_detail.dart';
import 'package:lush/services/order_service.dart';
import 'package:lush/theme/app_colors.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderBloc _orderBloc;
  String? _orderId;

  @override
  void initState() {
    super.initState();
    _orderBloc = OrderBloc(orderService: OrderService());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null && args != _orderId) {
      _orderId = args;
      _orderBloc.add(LoadOrderDetail(orderId: _orderId!));
    }
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

  void _handleReorder(BuildContext context, OrderDetail order) {
    context.read<CartBloc>().add(
          ReorderItems(
            items: order.lineItems
                .map((item) => ({
                      'itemId': item.itemId,
                      'itemName': item.itemName,
                      'quantity': item.quantity,
                      'unitPrice': item.unitPrice,
                    }))
                .toList(),
          ),
        );
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Items added to cart')),
    );
    Navigator.pushNamed(context, '/cart');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('order_detail_appbar'),
        title: Text(_orderId != null && _orderId!.length >= 8
            ? 'Order #${_orderId!.substring(0, 8)}'
            : 'Order Details'),
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        bloc: _orderBloc,
        builder: (context, state) {
          if (state is OrderDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is OrderDetailError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message,
                      style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        _orderBloc.add(LoadOrderDetail(orderId: _orderId ?? '')),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is OrderDetailLoaded) {
            final order = state.order;
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Card(
                          key: const Key('order_status_card'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Order ID: ${order.id}',
                                    style: const TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 4),
                                Text('${order.date.day}/${order.date.month}/${order.date.year}'),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusColor(order.status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    order.status.toUpperCase(),
                                    style: TextStyle(fontWeight: FontWeight.w600, color: _statusColor(order.status)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          key: const Key('order_items_card'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                ...order.lineItems.map((item) => Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Expanded(child: Text(item.itemName)),
                                          Text('x${item.quantity}'),
                                          const SizedBox(width: 16),
                                          Text('₹${item.lineTotal.toStringAsFixed(0)}',
                                              style: const TextStyle(fontWeight: FontWeight.w600)),
                                        ],
                                      ),
                                    )),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          key: const Key('order_pricing_card'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                _priceRow('Subtotal', '₹${order.subtotal.toStringAsFixed(0)}'),
                                const SizedBox(height: 8),
                                _priceRow('Delivery Fee', '₹${order.deliveryFee.toStringAsFixed(0)}'),
                                const Divider(height: 24),
                                _priceRow('Total', '₹${order.total.toStringAsFixed(0)}', bold: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Card(
                          key: const Key('order_address_card'),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Text(order.deliveryAddress.formatted),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      key: const Key('reorder_button'),
                      icon: const Icon(Icons.replay),
                      label: const Text('Reorder'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => _handleReorder(context, order),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 16 : 14)),
        Text(value,
            style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                fontSize: bold ? 16 : 14)),
      ],
    );
  }
}