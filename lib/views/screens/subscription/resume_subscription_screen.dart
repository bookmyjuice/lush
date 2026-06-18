import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../bloc/SubscriptionBloc/subscription_bloc.dart';
import '../../../theme/app_colors.dart';

class ResumeSubscriptionScreen extends StatefulWidget {
  const ResumeSubscriptionScreen({super.key});

  @override
  State<ResumeSubscriptionScreen> createState() =>
      _ResumeSubscriptionScreenState();
}

class _ResumeSubscriptionScreenState
    extends State<ResumeSubscriptionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Resume Subscription',
            style: TextStyle(color: AppColors.lightTextPrimary),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.lightTextPrimary, size: 20.sp,),
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
          final sub = state is SubscriptionLoaded ? state.subscription : null;

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (sub != null)
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(sub.plan.name,
                              style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,),),
                          SizedBox(height: 8.h),
                          Text('Paused since: ${DateFormat('dd MMM yyyy').format(sub.startDate)}',
                              style: TextStyle(
                                  fontSize: 14.sp, color: AppColors.grey,),),
                        ],
                      ),
                    ),
                  ),
                SizedBox(height: 32.h),
                Center(
                  child: Text(
                    'Resume your subscription now?',
                    style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextPrimary,),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () {
                            final subId = sub?.id ?? '';
                            context.read<SubscriptionBloc>().add(
                                ResumeSubscription(subscriptionId: subId),);
                          },
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),)
                        : const Icon(Icons.play_circle_outline),
                    label: const Text('Resume Now'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),),
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