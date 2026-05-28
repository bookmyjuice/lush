import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../bloc/SubscriptionBloc/subscription_bloc.dart';
import '../../../theme/app_colors.dart';

class ActiveSubscriptionScreen extends StatefulWidget {
  const ActiveSubscriptionScreen({super.key});

  @override
  State<ActiveSubscriptionScreen> createState() =>
      _ActiveSubscriptionScreenState();
}

class _ActiveSubscriptionScreenState extends State<ActiveSubscriptionScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(const LoadActiveSubscriptions());
  }

  Color _statusBgColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success.withValues(alpha: 0.12);
      case 'paused':
        return AppColors.warning.withValues(alpha: 0.12);
      case 'cancelled':
      case 'expired':
        return AppColors.error.withValues(alpha: 0.12);
      default:
        return AppColors.grey.withValues(alpha: 0.12);
    }
  }

  Color _statusFgColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'paused':
        return AppColors.warning;
      case 'cancelled':
      case 'expired':
        return AppColors.error;
      default:
        return AppColors.grey;
    }
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        shadowColor: AppColors.grey.withValues(alpha: 0.2),
        title: Text(
          'My Subscription',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.lightTextPrimary, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SubscriptionLoaded) {
            return _buildContent(state.subscription);
          } else if (state is SubscriptionError) {
            return _buildError(state.message);
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.sp, color: AppColors.error),
            SizedBox(height: 16.h),
            Text(message,
                style: TextStyle(fontSize: 16.sp, color: AppColors.error)),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () =>
                  context.read<SubscriptionBloc>().add(const LoadActiveSubscriptions()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ActiveSubscription sub) {
    final dateFmt = DateFormat('dd MMM yyyy');

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card 1: Plan Summary
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        sub.plan.name,
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: _statusBgColor(sub.status),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        sub.statusDisplayName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: _statusFgColor(sub.status),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                _infoRow('Started', dateFmt.format(sub.startDate)),
                SizedBox(height: 8.h),
                _infoRow('Next Renewal',
                    sub.nextDeliveryDate != null ? dateFmt.format(sub.nextDeliveryDate!) : 'N/A'),
                SizedBox(height: 8.h),
                _infoRow(
                    'Amount', '₹${(sub.plan.planID * 499).toString()} / month'),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Card 2: Schedule (placeholder)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Schedule',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  '${sub.completedDeliveries} of ${sub.totalDeliveries} deliveries completed',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                ),
                SizedBox(height: 8.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: LinearProgressIndicator(
                    value: sub.progress,
                    minHeight: 8.h,
                    backgroundColor: AppColors.grey.withValues(alpha: 0.2),
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.success),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Card 3: Actions
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildActions(sub.status),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 14.sp, color: AppColors.grey)),
        Text(value,
            style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary)),
      ],
    );
  }

  Widget _buildActions(String status) {
    switch (status) {
      case 'active':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/subscription/modify'),
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Modify Schedule'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/subscription/pause'),
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Pause'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.warning,
                  side: const BorderSide(color: AppColors.warning),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/subscription/cancel'),
                child: Text(
                  'Cancel Subscription',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
              ),
            ),
          ],
        );
      case 'paused':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/subscription/resume'),
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Resume'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/subscription/cancel'),
                child: Text(
                  'Cancel Subscription',
                  style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                ),
              ),
            ),
          ],
        );
      case 'cancelled':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/subscription-family'),
            icon: const Icon(Icons.refresh),
            label: const Text('Resubscribe'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryOrange,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}