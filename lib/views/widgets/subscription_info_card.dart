import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../theme.dart';
import '../models/Subscription.dart';
import 'app_card.dart';

/// Enhanced subscription card that displays real subscription data
class SubscriptionInfoCard extends StatelessWidget {
  final Subscription? subscription;
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
                          color: LushTheme.nearlyBlue,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            hasSubscription
                                ? subscription!.planId.isNotEmpty
                                    ? subscription!.planId
                                    : 'Subscription Plan'
                                : 'No Subscription',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: LushTheme.darkerText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    if (hasSubscription)
                      Text(
                        subscription!.getBillingPeriodString(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: LushTheme.lightText,
                        ),
                      ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: _getStatusColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: _getStatusColor(),
                    width: 1.w,
                  ),
                ),
                child: Text(
                  hasSubscription
                      ? subscription!.getStatusText()
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
              value: subscription!.getStartDate(),
            ),
            SizedBox(height: 8.h),
            _buildDetailRow(
              icon: Icons.event_available,
              label: 'Ends On',
              value: subscription!.getEndDate(),
            ),
            SizedBox(height: 8.h),
            if (subscription!.nextBillingAt != null)
              _buildDetailRow(
                icon: Icons.payment,
                label: 'Next Billing',
                value: subscription!.getNextBillingDate(),
              ),
          ] else ...[
            // No subscription message
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 48.sp,
                    color: LushTheme.grey.withOpacity(0.5),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'No active subscription',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: LushTheme.lightText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Subscribe for regular deliveries',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: LushTheme.lightText.withOpacity(0.7),
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
                foregroundColor: LushTheme.nearlyBlue,
                side: BorderSide(color: LushTheme.nearlyBlue, width: 1.5),
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
            color: LushTheme.nearlyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 18.sp,
            color: LushTheme.nearlyBlue,
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
                  color: LushTheme.lightText,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: LushTheme.darkerText,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor() {
    if (subscription == null) return LushTheme.grey;

    switch (subscription!.status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'paused':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      default:
        return LushTheme.nearlyBlue;
    }
  }
}
