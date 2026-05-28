import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/subscription_selection.dart';

class SubscriptionSummaryScreen extends StatefulWidget {
  final SubscriptionSelection selection;
  const SubscriptionSummaryScreen({super.key, required this.selection});

  @override
  State<SubscriptionSummaryScreen> createState() =>
      _SubscriptionSummaryScreenState();
}

class _SubscriptionSummaryScreenState
    extends State<SubscriptionSummaryScreen> {
  bool _isSubmitting = false;

  static const _dayLabels = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
  };

  static const _juiceDisplayNames = {
    'delight': {
      'mix-punch': 'Mix Punch',
      'carrot-juice': 'Carrot Juice',
      'colon-cleanser': 'Colon Cleanser',
      'beat-the-heat': 'Beat the Heat',
      'winter-special': 'Winter Special',
    },
    'signature': {
      'abc-juice': 'ABC Juice',
      'pineapple': 'Pineapple',
      'amla-juice': 'Amla Juice',
      'ashguard-juice': 'Ashguard Juice',
      'citrus-juice': 'Citrus Juice',
    },
    'premium': {
      'black-grapes': 'Black Grapes',
      'antioxidant-juice': 'Antioxidant Juice',
      'wheatgrass-juice': 'Wheatgrass Juice',
      'coconut-milk': 'Coconut Milk',
      'detox-smoothie': 'Detox Smoothie',
    },
  };

  @override
  Widget build(BuildContext context) {
    final price = widget.selection.priceInRupees;
    final bottleCount = widget.selection.period == 'weekly' ? 6 : 24;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Order Summary',
          style: TextStyle(color: AppColors.lightTextPrimary),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(
              title: 'Your Plan',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.selection.family.toUpperCase()} ${widget.selection.size}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          widget.selection.period.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    '₹${price.toStringAsFixed(0)} / ${widget.selection.period}',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryOrange,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$bottleCount bottles / ${widget.selection.period}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _buildCard(
              title: 'Your Weekly Schedule',
              child: Column(
                children: [
                  ..._dayLabels.entries.map((e) {
                    final day = e.key;
                    final juiceSlug = widget.selection.daySchedule[day] ?? '';
                    final displayName = _juiceDisplayNames[widget.selection.family]?[juiceSlug] ?? juiceSlug;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 80.w,
                            child: Text(
                              e.value,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              displayName.isNotEmpty ? displayName : '—',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: displayName.isNotEmpty
                                    ? AppColors.lightTextPrimary
                                    : AppColors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      children: [
                        SizedBox(width: 80.w, child: Text('Sunday', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary))),
                        Text('No delivery', style: TextStyle(fontSize: 14.sp, color: AppColors.grey, fontStyle: FontStyle.italic)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            _buildCard(
              title: 'Price Breakdown',
              child: Column(
                children: [
                  _buildPriceRow('Plan', price),
                  _buildPriceRow('Delivery', 0, isFree: true),
                  Divider(color: AppColors.lightDivider, height: 24.h),
                  _buildPriceRow('Total', price, isTotal: true),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() => _isSubmitting = true);
                        context.read<SubscriptionBloc>().add(
                              CreateSubscriptionFromSelection(selection: widget.selection),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.lightDivider,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: _isSubmitting
                    ? SizedBox(width: 20.r, height: 20.r, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                    : Text('Start Subscription', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ),
            ),
            BlocListener<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (state is SubscriptionCreatedSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.success));
                  Navigator.of(context).pushNamedAndRemoveUntil('/dashboard', (_) => false);
                }
                if (state is SubscriptionError) {
                  setState(() => _isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.error));
                }
              },
              child: const SizedBox.shrink(),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.lightDivider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextSecondary)),
        SizedBox(height: 12.h),
        child,
      ]),
    );
  }

  Widget _buildPriceRow(String label, double amount, {bool isFree = false, bool isTotal = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: isTotal ? 16.sp : 14.sp, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: isTotal ? AppColors.lightTextPrimary : AppColors.lightTextSecondary)),
        isFree
            ? Text('FREE', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.success))
            : Text('₹${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: isTotal ? 18.sp : 14.sp, fontWeight: isTotal ? FontWeight.bold : FontWeight.w500, color: isTotal ? AppColors.primaryOrange : AppColors.lightTextPrimary)),
      ]),
    );
  }
}