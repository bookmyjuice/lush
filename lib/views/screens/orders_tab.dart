/// Glassmorphism Orders Tab
///
/// Wraps the existing OrderHistoryScreen (which creates its own OrderBloc
/// locally) in a glassmorphism container. Preserves all Bloc wiring.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/OrderBloc/order_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_event.dart';
import 'package:lush/bloc/OrderBloc/order_state.dart';
import 'package:lush/models/order_summary.dart';
import 'package:lush/services/order_service.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/widgets/glass_card.dart';

/// Orders tab — glassmorphism version of OrderHistoryScreen.
class OrdersTab extends StatefulWidget {
  final bool isAuth;

  const OrdersTab({super.key, required this.isAuth});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final bgColor = isDark ? AppColors.glassBg : AppColors.glassBgLight;

    if (!widget.isAuth) {
      return Container(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_outlined,
                size: 64,
                color: AppColors.glassTextDim,
              ),
              SizedBox(height: 16.h),
              Text(
                'Sign in to view orders',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  color: AppColors.glassTextDim,
                ),
              ),
              SizedBox(height: 24.h),
              GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                borderRadius: AppRadius.lg,
                onTap: () => Navigator.pushNamed(context, '/login'),
                child: Text(
                  'Sign In',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.glassAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      color: bgColor,
      child: SafeArea(
        child: _OrderHistoryGlass(),
      ),
    );
  }
}

/// Glass-wrapped order history list.
class _OrderHistoryGlass extends StatefulWidget {
  @override
  State<_OrderHistoryGlass> createState() => _OrderHistoryGlassState();
}

class _OrderHistoryGlassState extends State<_OrderHistoryGlass> {
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
    final isDark = context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;

    return Column(
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
          child: Row(
            children: [
              Text(
                'Order History',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => _orderBloc.add(const RefreshOrderHistory()),
                child: GlassCard(
                  padding: const EdgeInsets.all(8),
                  borderRadius: AppRadius.md,
                  child: Icon(
                    Icons.refresh,
                    size: 18,
                    color: AppColors.glassAccent,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Content
        Expanded(
          child: BlocBuilder<OrderBloc, OrderState>(
            bloc: _orderBloc,
            builder: (context, state) {
              if (state is OrderHistoryLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (state is OrderHistoryEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 64,
                        color: AppColors.glassTextDim,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No orders yet',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: AppColors.glassTextDim,
                          fontFamily: 'Inter',
                        ),
                      ),
                      SizedBox(height: 16.h),
                      GlassCard(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        borderRadius: AppRadius.lg,
                        onTap: () => Navigator.pushNamed(context, '/catalog'),
                        child: Text(
                          'Browse Products',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.glassAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (state is OrderHistoryError) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          borderRadius: AppRadius.lg,
                          onTap: () => _orderBloc.add(const RefreshOrderHistory()),
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.glassAccent,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is OrderHistoryLoaded) {
                return RefreshIndicator(
                  onRefresh: () async {
                    _orderBloc.add(const RefreshOrderHistory());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: state.orders.length,
                    itemBuilder: (context, index) {
                      final order = state.orders[index];
                      return _GlassOrderTile(
                        order: order,
                        statusColor: _statusColor(order.status),
                        isDark: isDark,
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
        ),
      ],
    );
  }
}

/// Glassmorphism order list tile.
class _GlassOrderTile extends StatelessWidget {
  final OrderSummary order;
  final Color statusColor;
  final bool isDark;
  final VoidCallback onTap;

  const _GlassOrderTile({
    required this.order,
    required this.statusColor,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderRadius: AppRadius.md,
        onTap: onTap,
        child: Row(
          children: [
            // Date column
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.formattedDate,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                  ),
                ),
                Text(
                  '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    color: AppColors.glassTextDim,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Price
            Text(
              '₹${order.total.toStringAsFixed(0)}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(width: 8.w),
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(
                  color: statusColor.withValues(alpha: 0.3),
                  width: 0.5,
                ),
              ),
              child: Text(
                order.status.toUpperCase(),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9.sp,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.glassTextDim,
            ),
          ],
        ),
      ),
    );
  }
}