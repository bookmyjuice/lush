import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../bloc/SubscriptionBloc/subscription_bloc.dart';
import '../../../theme/app_colors.dart';

class ModifyScheduleScreen extends StatefulWidget {
  const ModifyScheduleScreen({super.key});

  @override
  State<ModifyScheduleScreen> createState() => _ModifyScheduleScreenState();
}

class _ModifyScheduleScreenState extends State<ModifyScheduleScreen> {
  late Map<String, String> _schedule;
  bool _sameEveryday = true;
  String? _singleJuice; // common juice for all days

  static const _days = [
    'monday', 'tuesday', 'wednesday',
    'thursday', 'friday', 'saturday',
  ];

  static const _dayLabels = {
    'monday': 'Monday', 'tuesday': 'Tuesday', 'wednesday': 'Wednesday',
    'thursday': 'Thursday', 'friday': 'Friday', 'saturday': 'Saturday',
  };

  @override
  void initState() {
    super.initState();
    _schedule = {for (var d in _days) d: ''};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text('Modify Schedule',
            style: TextStyle(color: AppColors.lightTextPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: AppColors.lightTextPrimary, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<SubscriptionBloc, SubscriptionState>(
        listener: (context, state) {
          if (state is SubscriptionModified) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Schedule updated')),
            );
          } else if (state is SubscriptionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is SubscriptionLoading;
          final sub = state is SubscriptionLoaded ? state.subscription : null;
          final subId = sub?.id ?? '';

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Change your day-wise juice selection',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.grey),
                ),
                SizedBox(height: 16.h),
                SwitchListTile(
                  title: const Text('Same every day'),
                  value: _sameEveryday,
                  onChanged: (v) => setState(() => _sameEveryday = v),
                ),
                Expanded(
                  child: ListView(
                    children: _days.map((day) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: _dayLabels[day],
                            hintText: 'Enter juice name / item price ID',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.r)),
                          ),
                          enabled: !_sameEveryday,
                          onChanged: (v) => _schedule[day] = v,
                        ),
                      );
                    }).toList(),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                            context.read<SubscriptionBloc>().add(
                                ModifySubscriptionSchedule(
                                  subscriptionId: subId,
                                  newSchedule: _schedule,
                                ));
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child:
                                CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Save Changes'),
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
        },
      ),
    );
  }
}