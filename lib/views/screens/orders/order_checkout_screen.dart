import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/bloc/CartBloc/cart_state.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/cart_item.dart';

class OrderCheckoutScreen extends StatefulWidget {
  const OrderCheckoutScreen({super.key});

  @override
  State<OrderCheckoutScreen> createState() => _OrderCheckoutScreenState();
}

class _OrderCheckoutScreenState extends State<OrderCheckoutScreen> {
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _isPlacing = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state is OrderPlaced) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Order placed! 🎉'), backgroundColor: AppColors.success),
          );
          Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (_) => false);
        }
        if (state is CartError) {
          setState(() => _isPlacing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      builder: (context, state) {
        if (state is! CartLoaded) {
          return Scaffold(
            appBar: AppBar(title: const Text('Checkout')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final items = state.items;
        final grandTotal = items.fold<double>(0, (sum, item) => sum + item.totalPrice);
        final itemCount = items.fold<int>(0, (sum, item) => sum + item.quantity);

        return Scaffold(
          backgroundColor: AppColors.lightBackground,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            title: Text('Checkout', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
            iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
          ),
          body: _isPlacing
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Order summary
                    _buildSection('Order Summary', [
                      ...items.map((item) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(children: [
                          Expanded(child: Text(
                            '${item.item.name} × ${item.quantity}',
                            style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextPrimary),
                          )),
                          Text('₹${item.totalPrice.toStringAsFixed(0)}',
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
                        ]),
                      )),
                      Divider(color: AppColors.lightDivider, height: 24.h),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text('$itemCount items', style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextSecondary)),
                        Text('Total: ₹${grandTotal.toStringAsFixed(0)}',
                            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
                      ]),
                    ]),
                    SizedBox(height: 16.h),

                    // Delivery date picker
                    _buildSection('Delivery Date', [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(_formatDate(_selectedDate),
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
                        subtitle: Text('Tap to change', style: TextStyle(color: AppColors.lightTextSecondary)),
                        trailing: const Icon(Icons.calendar_today, color: AppColors.primaryOrange),
                        onTap: () => _pickDate(context),
                      ),
                    ]),
                    SizedBox(height: 16.h),

                    // CTA
                    SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() => _isPlacing = true);
                          context.read<CartBloc>().add(PlaceOneTimeOrder(
                            items: items,
                            deliveryAddress: 'User address',
                            deliveryDate: _selectedDate,
                          ));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text('Place Order', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.white)),
                      ),
                    ),
                  ]),
                ),
        );
      },
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
        SizedBox(height: 12.h),
        ...children,
      ]),
    );
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.add(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 7)),
      selectableDayPredicate: (day) => day.weekday != DateTime.sunday,
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[d.weekday - 1]}, ${d.day} ${months[d.month - 1]} ${d.year}';
  }
}