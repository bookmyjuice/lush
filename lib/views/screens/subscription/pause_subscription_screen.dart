import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../bloc/SubscriptionBloc/subscription_bloc.dart';
import '../../../theme/app_colors.dart';

class PauseSubscriptionScreen extends StatefulWidget {
  const PauseSubscriptionScreen({super.key});

  @override
  State<PauseSubscriptionScreen> createState() =>
      _PauseSubscriptionScreenState();
}

class _PauseSubscriptionScreenState extends State<PauseSubscriptionScreen> {
  String _selectedDuration = '1_week';

  static const _durations = [
    ('1_week', '1 Week', Duration(days: 7)),
    ('2_weeks', '2 Weeks', Duration(days: 14)),
    ('1_month', '1 Month', Duration(days: 30)),
  ];

  DateTime get _resumeDate => DateTime.now().add(
      _durations.firstWhere((d) => d.$1 == _selectedDuration).$3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Pause Subscription',
            style: TextStyle(color: AppColors.lightTextPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.lightTextPrimary, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionLoaded) {
            Navigator.pushReplacementNamed(context, '/subscription/active');
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SubscriptionLoading;
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How long would you like to pause?',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                ..._durations.map((d) => RadioListTile<String>(
                      value: d.$1,
                      groupValue: _selectedDuration,
                      title: Text(d.$2),
                      onChanged: isLoading
                          ? null
                          : (v) => setState(() => _selectedDuration = v!),
                    )),
                SizedBox(height: 24.h),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: AppColors.info, size: 20.sp),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Your subscription will resume automatically on ${DateFormat('dd MMM yyyy').format(_resumeDate)}',
                            style: TextStyle(
                                fontSize: 14.sp, color: AppColors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<SubscriptionBloc>().add(
                                PauseSubscription(
                                  subscriptionId: '',
                                  duration: _selectedDuration,
                                ));
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Confirm Pause'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
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
        },
      ),
    );
  }
}