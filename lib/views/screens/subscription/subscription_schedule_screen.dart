import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/subscription_selection.dart';

class SubscriptionScheduleScreen extends StatefulWidget {
  final SubscriptionSelection selection;
  const SubscriptionScheduleScreen({super.key, required this.selection});

  @override
  State<SubscriptionScheduleScreen> createState() =>
      _SubscriptionScheduleScreenState();
}

class _SubscriptionScheduleScreenState
    extends State<SubscriptionScheduleScreen> {
  bool _sameEveryday = true;
  late Map<String, String> _schedule;

  static const _days = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
  ];

  static const _dayLabels = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
  };

  static const _juiceNames = {
    'delight': {
      'mix-punch': 'Mix Punch',
      'carrot-juice': 'Carrot Juice',
      'colon-cleanser': 'Colon Cleanser',
      'beat-the-heat': 'Beat the Heat',
      'winter-special': 'Winter Special',
    },
    'signature': {
      'abc-juice': 'ABC Juice',
      'pineapple': 'Pineapple',
      'amla-juice': 'Amla Juice',
      'ashguard-juice': 'Ashguard Juice',
      'citrus-juice': 'Citrus Juice',
    },
    'premium': {
      'black-grapes': 'Black Grapes',
      'antioxidant-juice': 'Antioxidant Juice',
      'wheatgrass-juice': 'Wheatgrass Juice',
      'coconut-milk': 'Coconut Milk',
      'detox-smoothie': 'Detox Smoothie',
    },
  };

  @override
  void initState() {
    super.initState();
    _schedule = Map<String, String>.from(widget.selection.daySchedule);
    if (_schedule.isEmpty) {
      for (final d in _days) {
        _schedule[d] = '';
      }
    }
  }

  List<String> _getJuiceOptions(String family) {
    return (_juiceNames[family] ?? _juiceNames['delight']!).keys.toList();
  }

  String _getJuiceDisplay(String family, String slug) {
    return _juiceNames[family]?[slug] ?? slug;
  }

  void _onJuiceChanged(String day, String? juice) {
    if (juice == null) return;
    setState(() {
      if (_sameEveryday) {
        for (final d in _days) {
          _schedule[d] = juice;
        }
      } else {
        _schedule[day] = juice;
      }
    });
  }

  bool get _allFilled => _days.every((d) => _schedule[d]?.isNotEmpty == true);

  @override
  Widget build(BuildContext context) {
    final family = widget.selection.family;
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Pick Your Juices',
          style: TextStyle(color: AppColors.lightTextPrimary),
        ),
      ),
      body: Column(
        children: [
          // Header card
          Container(
            margin: EdgeInsets.all(16.r),
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryOrange,
                  AppColors.gradientEnd,
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${widget.selection.family.toUpperCase()} ${widget.selection.size}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '₹${widget.selection.priceInRupees.toStringAsFixed(0)}/${widget.selection.period}',
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Same Everyday checkbox
          CheckboxListTile(
            title: Text(
              'Same Everyday',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary,
              ),
            ),
            value: _sameEveryday,
            activeColor: AppColors.primaryOrange,
            onChanged: (v) {
              setState(() {
                _sameEveryday = v ?? false;
              });
            },
            controlAffinity: ListTileControlAffinity.leading,
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Divider(color: AppColors.lightDivider),
          ),

          // Day rows
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.h),
              itemCount: _days.length,
              itemBuilder: (context, index) {
                final day = _days[index];
                final selectedJuice = _schedule[day];
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80.w,
                        child: Text(
                          _dayLabels[day]!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: selectedJuice != null &&
                                      selectedJuice.isNotEmpty
                                  ? AppColors.primaryOrange
                                  : AppColors.lightDivider,
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: selectedJuice != null &&
                                    selectedJuice.isNotEmpty
                                ? selectedJuice
                                : null,
                            hint: Text(
                              'Select juice',
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: 14.sp,
                              ),
                            ),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items: _getJuiceOptions(family)
                                .map((slug) => DropdownMenuItem(
                                      value: slug,
                                      child: Text(
                                        _getJuiceDisplay(family, slug),
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (v) => _onJuiceChanged(day, v),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // CTA
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.grey.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _allFilled
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/subscription/summary',
                            arguments:
                                widget.selection.copyWith(daySchedule: _schedule),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: AppColors.white,
                    disabledBackgroundColor: AppColors.lightDivider,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Review Order',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}