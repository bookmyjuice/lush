import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionCard extends StatelessWidget {
  final String planName;
  final bool isActive;
  final String nextDelivery;
  final VoidCallback? onPause;
  final VoidCallback? onModify;
  final VoidCallback? onHistory;

  const SubscriptionCard({
    super.key,
    required this.planName,
    this.isActive = false,
    this.nextDelivery = '',
    this.onPause,
    this.onModify,
    this.onHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1565C0), Color(0xFF0288D1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
          ),
          padding: EdgeInsets.all(16.w),
          child: isActive ? _buildActiveCard() : _buildInactiveCard(),
        ),
      ),
    );
  }

  Widget _buildActiveCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              planName,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 17.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'ACTIVE',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            const Icon(Icons.calendar_today, size: 14, color: Colors.white70),
            SizedBox(width: 6.w),
            Text(
              'Next delivery: $nextDelivery',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.sp,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            _actionChip(Icons.pause, 'Pause', onPause),
            SizedBox(width: 8.w),
            _actionChip(Icons.edit, 'Modify', onModify),
            SizedBox(width: 8.w),
            _actionChip(Icons.history, 'History', onHistory),
          ],
        ),
      ],
    );
  }

  Widget _buildInactiveCard() {
    return Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.white70),
        SizedBox(width: 12.w),
        Text(
          'No active plan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15.sp,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _actionChip(IconData icon, String label, VoidCallback? onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontSize: 12)),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.white),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }
}