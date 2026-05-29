import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../bloc/SubscriptionBloc/subscription_bloc.dart';
import '../../../theme/app_colors.dart';

class CancelSubscriptionScreen extends StatefulWidget {
  const CancelSubscriptionScreen({super.key});

  @override
  State<CancelSubscriptionScreen> createState() =>
      _CancelSubscriptionScreenState();
}

class _CancelSubscriptionScreenState extends State<CancelSubscriptionScreen> {
  int _step = 1;
  String? _selectedReason;
  bool _isLoading = false;

  static const _reasons = [
    'Too expensive',
    'Not satisfied with quality',
    'Delivery issues',
    'Health reasons',
    'Switching to another service',
    'Temporary break (consider pausing instead)',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Cancel Subscription',
            style: TextStyle(color: AppColors.lightTextPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.lightTextPrimary, size: 20.sp),
          onPressed: () => _step == 2
              ? setState(() => _step = 1)
              : Navigator.pop(context),
        ),
      ),
      body: BlocListener<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          setState(() => _isLoading = state is SubscriptionLoading);
          if (state is SubscriptionCancelled) {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Subscription cancelled')),
            );
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: _step == 1 ? _buildStep1() : _buildStep2(),
      ),
    );
  }

  Widget _buildStep1() {
    final isPauseSuggestion = _selectedReason ==
        'Temporary break (consider pausing instead)';

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Why are you cancelling?',
              style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.lightTextPrimary)),
          SizedBox(height: 16.h),
          DropdownButtonFormField<String>(
            value: _selectedReason,
            decoration: InputDecoration(
              labelText: 'Select a reason',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r)),
            ),
            items: _reasons.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
            onChanged: (v) => setState(() => _selectedReason = v),
          ),
          if (isPauseSuggestion) ...[
            SizedBox(height: 16.h),
            Card(
              color: AppColors.info.withValues(alpha: 0.08),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        'Did you know you can pause instead?',
                        style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextPrimary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/subscription/pause'),
                      child: const Text('Pause my subscription'),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedReason == null
                  ? null
                  : () => setState(() => _step = 2),
              child: const Text('Continue'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: AppColors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: AppColors.error.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: const BorderSide(color: AppColors.error),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: AppColors.error, size: 24.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Are you sure? Your subscription will be cancelled immediately and cannot be undone.',
                      style: TextStyle(fontSize: 14.sp, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Plan: $_selectedReason',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  SizedBox(height: 8.h),
                  Text('Reason: $_selectedReason',
                      style: TextStyle(fontSize: 14.sp, color: AppColors.grey)),
                ],
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() => _step = 1),
                  child: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          context.read<SubscriptionBloc>().add(
                              CancelSubscription(
                                subscriptionId: '',
                                reason: _selectedReason ?? '',
                              ));
                        },
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Confirm Cancel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}