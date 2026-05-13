import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../UserRepository/user_repository.dart';
import '../widgets/app_card.dart';
import '../models/order.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_text_styles.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});
  static const routeName = '/orders';

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  int _selectedTab = 0;
  List<Order> _orders = [];
  bool _loading = true;
  String? _error;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _userRepository.fetchOrders();
      setState(() {
        _orders = data.map((e) => Order.fromJson(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Orders',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTextPrimary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.grey,
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: Row(
              children: [
                _buildTab('All Orders', 0),
                _buildTab('Delivered', 1),
                _buildTab('Pending', 2),
              ],
            ),
          ),

          // Content
          Expanded(
            child: _loading
                ? Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text(_error!))
                    : _buildOrdersList(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
    List<Order> filtered = _orders;
    if (_selectedTab == 1) {
      filtered = _orders.where((o) => o.status == 'DELIVERED').toList();
    } else if (_selectedTab == 2) {
      filtered = _orders
          .where((o) => o.status == 'QUEUED' || o.status == 'PROCESSING')
          .toList();
    }
    if (filtered.isEmpty) {
      return Center(child: Text('No orders found.'));
    }
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      children: filtered
          .map((order) => _buildOrderCard(
                orderId: order.documentNumber.isNotEmpty
                    ? order.documentNumber
                    : '#${order.id}',
                date: order.createdAt,
                status: order.status,
                items: order.items.isNotEmpty ? order.items : ['No items'],
                total: '?${order.total}',
                statusColor: _getStatusColor(order.status),
              ))
          .toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'DELIVERED':
        return AppColors.success;
      case 'QUEUED':
      case 'PROCESSING':
        return AppColors.primaryOrange;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  Widget _buildTab(String title, int index) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          margin: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.grey,
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.lightTextPrimary : AppColors.lightTextSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Removed static order lists, now using fetched orders

  Widget _buildOrderCard({
    required String orderId,
    required String date,
    required String status,
    required List<String> items,
    required String total,
    required Color statusColor,
  }) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      orderId,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Items
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Items:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              ...items.map((item) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      children: [
                        Container(
                          width: 4.w,
                          height: 4.w,
                          decoration: BoxDecoration(
                            color: AppColors.lightTextSecondary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          item,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),

          SizedBox(height: 16.h),

          // Total and actions
          Row(
            children: [
              Text(
                'Total: ',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              Text(
                total,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              Spacer(),
              if (status == 'Delivered') ...[
                TextButton(
                  onPressed: () {
                    // Reorder functionality
                  },
                  child: Text(
                    'Reorder',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ] else if (status == 'Processing') ...[
                TextButton(
                  onPressed: () {
                    // Track order functionality
                  },
                  child: Text(
                    'Track',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
