import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/UserBloc/user_bloc.dart';
import 'package:lush/bloc/UserBloc/user_events.dart';
import 'package:lush/bloc/UserBloc/user_state.dart';
import 'package:lush/views/models/bottle_ledger.dart';
import 'package:lush/theme/app_colors.dart';

/// Screen showing the authenticated customer's bottle ledger and transactions.
class MyBottlesScreen extends StatefulWidget {
  const MyBottlesScreen({super.key});

  @override
  State<MyBottlesScreen> createState() => _MyBottlesScreenState();
}

class _MyBottlesScreenState extends State<MyBottlesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<UserBloc>().add(const LoadBottleLedger());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bottles'),
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
      ),
      body: BlocBuilder<UserBloc, UserState>(
        builder: (context, state) {
          if (state is UserLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is BottleLedgerLoaded) {
            return _buildContent(state);
          } else if (state is UserError) {
            return _buildError(state.message);
          } else {
            return _buildEmpty();
          }
        },
      ),
    );
  }

  Widget _buildContent(BottleLedgerLoaded state) {
    if (state.ledger.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<UserBloc>().add(const LoadBottleLedger());
      },
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Summary header
          _buildSummaryHeader(state.ledger.length),
          SizedBox(height: 16.h),

          // Ledger cards
          ...state.ledger.map((entry) => _buildLedgerCard(entry)),
          SizedBox(height: 24.h),

          // Recent transactions section
          if (state.transactions.isNotEmpty) ...[
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
            ...state.transactions.take(10).map(
                  (tx) => _buildTransactionTile(tx),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryHeader(int bottleTypeCount) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryOrange, AppColors.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.recycling,
              color: AppColors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              'You have $bottleTypeCount bottle type(s) in your ledger. Track your reusable bottle deposits and returns.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerCard(BottleLedgerEntry entry) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bottle type header
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.local_drink,
                  color: AppColors.primaryOrange,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  entry.bottleType.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              // Outstanding badge
              Container(
                padding:
                    EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: entry.outstanding > 0
                      ? AppColors.error.withValues(alpha: 0.1)
                      : AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  '${entry.outstanding} outstanding',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: entry.outstanding > 0
                        ? AppColors.error
                        : AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Stats row
          Row(
            children: [
              _buildStatItem('Issued', entry.totalIssued, AppColors.info),
              SizedBox(width: 12.w),
              _buildStatItem('Returned', entry.totalReturned, AppColors.success),
              SizedBox(width: 12.w),
              _buildStatItem('Broken', entry.totalBroken, AppColors.error),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              '$value',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTile(BottleTransaction tx) {
    final actionColor = switch (tx.action) {
      'ISSUED' => AppColors.info,
      'RETURNED' => AppColors.success,
      'BROKEN' => AppColors.error,
      _ => AppColors.grey,
    };

    final actionIcon = switch (tx.action) {
      'ISSUED' => Icons.arrow_upward,
      'RETURNED' => Icons.arrow_downward,
      'BROKEN' => Icons.dangerous,
      _ => Icons.circle,
    };

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.grey.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(actionIcon, color: actionColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${tx.action} - ${tx.bottleType.replaceAll('_', ' ')}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Qty: ${tx.quantity} | Order: #${tx.orderId.length > 8 ? tx.orderId.substring(0, 8) : tx.orderId}...',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (tx.createdAt != null && tx.createdAt!.length >= 10)
            Text(
              tx.createdAt!.substring(0, 10),
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.lightTextSecondary,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                context.read<UserBloc>().add(const LoadBottleLedger());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.recycling,
              size: 72.sp,
              color: AppColors.primaryOrange.withValues(alpha: 0.5),
            ),
            SizedBox(height: 16.h),
            Text(
              'No Bottles Yet',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Your bottle ledger will appear here once you start ordering. We track reusable bottles issued with each delivery.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
