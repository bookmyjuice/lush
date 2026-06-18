import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/models/subscription_selection.dart';
import 'package:lush/widgets/glass_card.dart';

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
    final isDark =
        context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final bgColor = isDark ? AppColors.glassBg : AppColors.glassBgLight;
    final textPrimaryColor =
        isDark ? AppColors.glassText : AppColors.lightTextPrimary;
    final accentColor =
        isDark ? AppColors.glassAccent : AppColors.primaryOrange;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Pick Your Juices 🧃',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header Card
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: GlassCard(
              padding: EdgeInsets.all(16.r),
              borderRadius: AppRadius.lg,
              hasGlow: true,
              glowColor: accentColor.withValues(alpha: 0.15),
              child: Row(
                children: [
                  Container(
                    width: 50.r,
                    height: 50.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.glassAccent, AppColors.glassAccentDark]
                            : [
                                AppColors.primaryOrange,
                                AppColors.primaryOrangeDark
                              ],
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: const Icon(Icons.local_drink_rounded,
                        color: Colors.white, size: 28),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.selection.family.toUpperCase()} • ${widget.selection.size}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '₹${widget.selection.priceInRupees.toStringAsFixed(0)} / ${widget.selection.period}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Same Everyday Checkbox styled as an elegant Glass Segment Control
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: GlassCard(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              borderRadius: AppRadius.md,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _sameEveryday = !_sameEveryday;
                    if (_sameEveryday) {
                      // Synchronize all days to Monday's juice if Mon is selected
                      final monJuice = _schedule['monday'] ?? '';
                      for (final d in _days) {
                        _schedule[d] = monJuice;
                      }
                    }
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _sameEveryday
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: _sameEveryday
                          ? AppColors.glassAccent
                          : AppColors.glassTextDim,
                      size: 22.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Same juice everyday 🍊',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: textPrimaryColor,
                            ),
                          ),
                          Text(
                            'Choose once, we map it to all delivery days!',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.sp,
                              color: AppColors.glassTextDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Day Schedule list with Mon-Sat and non-selectable Sunday Holiday
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: _days.length + 1, // +1 for Sunday
              itemBuilder: (context, index) {
                // Let's inject Sunday at the end
                final isSunday = index == _days.length;

                if (isSunday) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: GlassCard(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 14.h),
                      borderRadius: AppRadius.md,
                      backgroundColor: isDark
                          ? const Color(0x08FFFFFF)
                          : const Color(0x05000000),
                      borderColor: isDark
                          ? AppColors.glassBorderSubtle
                          : AppColors.glassBorderLight,
                      child: Row(
                        children: [
                          Container(
                            width: 32.r,
                            height: 32.r,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black12,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.beach_access,
                                color: Colors.grey, size: 18),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sunday',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Holiday • No Delivery 🌴',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.sp,
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final day = _days[index];
                final selectedJuice = _schedule[day];
                final isSelectable = !_sameEveryday || day == 'monday';

                return AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isSelectable ? 1.0 : 0.6,
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 10.h),
                    child: GlassCard(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 10.h),
                      borderRadius: AppRadius.md,
                      child: Row(
                        children: [
                          SizedBox(
                            width: 90.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _dayLabels[day]!,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textPrimaryColor,
                                  ),
                                ),
                                if (_sameEveryday && day != 'monday')
                                  Text(
                                    'Same as Mon',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10.sp,
                                      color: accentColor,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: selectedJuice != null &&
                                          selectedJuice.isNotEmpty
                                      ? accentColor.withValues(alpha: 0.4)
                                      : Colors.transparent,
                                  width: 0.8,
                                ),
                              ),
                              child: IgnorePointer(
                                ignoring: !isSelectable,
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedJuice != null &&
                                            selectedJuice.isNotEmpty
                                        ? selectedJuice
                                        : null,
                                    dropdownColor: isDark
                                        ? AppColors.glassElevated
                                        : Colors.white,
                                    hint: Text(
                                      'Select juice 🥤',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        color: AppColors.glassTextDim,
                                        fontSize: 13.sp,
                                      ),
                                    ),
                                    isExpanded: true,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      color: textPrimaryColor,
                                      fontSize: 13.sp,
                                    ),
                                    items: _getJuiceOptions(family)
                                        .map(
                                          (slug) => DropdownMenuItem(
                                            value: slug,
                                            child: Text(
                                              _getJuiceDisplay(family, slug),
                                              style: TextStyle(
                                                fontFamily: 'Inter',
                                                color: textPrimaryColor,
                                                fontSize: 13.sp,
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (v) => _onJuiceChanged(day, v),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // CTA Action Bar with glassmorphism glow
          GlassCard(
            padding: EdgeInsets.all(16.r),
            borderRadius: 0,
            borderWidth: 0,
            borderColor: Colors.transparent,
            backgroundColor:
                isDark ? AppColors.glassElevated : AppColors.glassElevatedLight,
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: 52.h,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _allFilled
                      ? () {
                          Navigator.pushNamed(
                            context,
                            '/subscription/summary',
                            arguments: widget.selection
                                .copyWith(daySchedule: _schedule),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        isDark ? Colors.white10 : Colors.black12,
                    elevation: 4,
                    shadowColor: accentColor.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Review Order ✨',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: _allFilled
                              ? Colors.white
                              : AppColors.glassTextDim,
                        ),
                      ),
                    ],
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
