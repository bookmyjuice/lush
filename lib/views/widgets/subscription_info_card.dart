import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:lush/theme/app_colors.dart';
import 'app_card.dart';

/// Formats an epoch-seconds value to a readable date string.
String _formatEpochToDate(dynamic epochValue) {
  if (epochValue == null) return '--';
  final epoch = (epochValue is int) ? epochValue : int.tryParse(epochValue.toString()) ?? 0;
  if (epoch == 0) return '--';
  final date = DateTime.fromMillisecondsSinceEpoch(epoch * 1000);
  return '${date.day}/${date.month}/${date.year}';
}

/// Computes a human-readable billing period string from map fields.
String _getBillingPeriodString(Map<String, dynamic> sub) {
  final period = sub['billingPeriod'];
  final unit = sub['billingPeriodUnit'];
  if (period == null || unit == null) return '';
  final p = period is int ? period : int.tryParse(period.toString()) ?? 0;
  final u = unit.toString().toLowerCase();
  if (u == 'day') return 'Every ${p}d';
  if (u == 'month') return 'Every ${p}mo';
  if (u == 'week') return 'Every ${p}w';
  return 'Period: $p $u';
}

/// Enhanced subscription card that displays real subscription data
class SubscriptionInfoCard extends StatelessWidget {
  final Map<String, dynamic>? subscription;
  final VoidCallback? onTap;
  final VoidCallback? onManageTap;

  const SubscriptionInfoCard({
    super.key,
    this.subscription,
    this.onTap,
    this.onManageTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubscription = subscription != null;

    return AppCard(
      onTap: hasSubscription ? onTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status badge
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 20.sp,
                          color: AppColors.info,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            hasSubscription
                                ? (subscription!['planId']?.toString().isNotEmpty == true
                                    ? subscription!['planId'].toString()
                                    : 'Subscription Plan')
                                : 'No Subscription',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightTextPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    if (hasSubscription)
                      Text(
                        _getBillingPeriodString(subscription!),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _getStatusColor(),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  hasSubscription
                      ? (subscription!['status']?.toString().toUpperCase() ?? 'ACTIVE')
                      : 'INACTIVE',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Subscription details
          if (hasSubscription) ...[
            _buildDetailRow(
              icon: Icons.calendar_today,
              label: 'Started',
              value: _formatEpochToDate(subscription!['currentTermStart']),
            ),
            SizedBox(height: 8.h),
            _buildDetailRow(
              icon: Icons.event_available,
              label: 'Ends On',
              value: _formatEpochToDate(subscription!['currentTermEnd']),
            ),
            SizedBox(height: 8.h),
            if (subscription!['nextBillingAt'] != null)
              _buildDetailRow(
                icon: Icons.payment,
                label: 'Next Billing',
                value: _formatEpochToDate(subscription!['nextBillingAt']),
              ),
          ] else ...[
            // No subscription message
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48.sp,
                    color: AppColors.grey.withValues(alpha: 0.5),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No active subscription',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Subscribe for regular deliveries',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.lightTextSecondary.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Action button
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: hasSubscription ? onManageTap : onTap,
              icon: Icon(
                hasSubscription ? Icons.settings : Icons.add_shopping_cart,
                size: 18.sp,
              ),
              label: Text(
                hasSubscription ? 'Manage Subscription' : 'Subscribe Now',
                style: TextStyle(fontSize: 14.sp),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.info,
                side: const BorderSide(color: AppColors.info, width: 1.5),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: AppColors.info,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.lightTextSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (subscription == null) return AppColors.grey;
    final status = (subscription!['status']?.toString() ?? '').toLowerCase();
    switch (status) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return AppColors.info;
    }
  }
}