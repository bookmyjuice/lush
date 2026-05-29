import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StatsStrip extends StatelessWidget {
  final String deliveryCount;
  final String memberSince;
  final String returnedCount;

  const StatsStrip({
    super.key,
    this.deliveryCount = '47',
    this.memberSince = 'Jan 2026',
    this.returnedCount = '12',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          _statCard(Icons.local_drink, deliveryCount, 'Deliveries'),
          SizedBox(width: 8.w),
          _statCard(Icons.calendar_month, memberSince, 'Member Since'),
          SizedBox(width: 8.w),
          _statCard(Icons.recycling, returnedCount, 'Returned'),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String number, String label) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Column(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
              SizedBox(height: 4.h),
              Text(
                number,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}