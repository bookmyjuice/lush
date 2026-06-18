import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/models/subscription_selection.dart';
import 'package:lush/widgets/glass_card.dart';

class SubscriptionSummaryScreen extends StatefulWidget {
  final SubscriptionSelection selection;
  const SubscriptionSummaryScreen({super.key, required this.selection});

  @override
  State<SubscriptionSummaryScreen> createState() =>
      _SubscriptionSummaryScreenState();
}

class _SubscriptionSummaryScreenState extends State<SubscriptionSummaryScreen> {
  bool _isSubmitting = false;

  static const _dayLabels = {
    'monday': 'Monday',
    'tuesday': 'Tuesday',
    'wednesday': 'Wednesday',
    'thursday': 'Thursday',
    'friday': 'Friday',
    'saturday': 'Saturday',
  };

  static const _juiceDisplayNames = {
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
  Widget build(BuildContext context) {
    final price = widget.selection.priceInRupees;
    final bottleCount = widget.selection.period == 'weekly' ? 6 : 24;
    final isDark =
        context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final bgColor = isDark ? AppColors.glassBg : AppColors.glassBgLight;
    final textPrimaryColor =
        isDark ? AppColors.glassText : AppColors.lightTextPrimary;
    final textSecondaryColor =
        isDark ? AppColors.glassTextDim : AppColors.lightTextSecondary;
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
          'Order Summary 📝',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plan Card
            _buildSectionCard(
              title: 'Your Plan 🥤',
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.selection.family.toUpperCase()} • ${widget.selection.size}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: textPrimaryColor,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                              color: accentColor.withValues(alpha: 0.3),
                              width: 0.5),
                        ),
                        child: Text(
                          widget.selection.period.toUpperCase(),
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    '₹${price.toStringAsFixed(0)} / ${widget.selection.period}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: accentColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '📦 $bottleCount bottles total per ${widget.selection.period}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      color: textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Weekly Schedule Card
            _buildSectionCard(
              title: 'Weekly Schedule 📅',
              isDark: isDark,
              child: Column(
                children: [
                  ..._dayLabels.entries.map((e) {
                    final day = e.key;
                    final juiceSlug = widget.selection.daySchedule[day] ?? '';
                    final displayName =
                        _juiceDisplayNames[widget.selection.family]
                                ?[juiceSlug] ??
                            juiceSlug;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100.w,
                            child: Text(
                              e.value,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: textPrimaryColor,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline,
                                    size: 14, color: AppColors.glassAccent),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    displayName.isNotEmpty
                                        ? displayName
                                        : 'Not Selected',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13.sp,
                                      fontWeight: displayName.isNotEmpty
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                      color: displayName.isNotEmpty
                                          ? textPrimaryColor
                                          : Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: EdgeInsets.only(top: 4.h),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100.w,
                          child: Text(
                            'Sunday',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.beach_access,
                                size: 14, color: Colors.grey),
                            SizedBox(width: 6.w),
                            Text(
                              'Holiday • No Delivery 🌴',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.sp,
                                color: Colors.grey,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Price Breakdown Card
            _buildSectionCard(
              title: 'Price Breakdown 💎',
              isDark: isDark,
              child: Column(
                children: [
                  _buildPriceRow('Plan Price', price, isDark: isDark),
                  _buildPriceRow('Delivery Fee', 0,
                      isFree: true, isDark: isDark),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Divider(
                      color: isDark
                          ? AppColors.glassBorderSubtle
                          : AppColors.glassBorderLight,
                      height: 1,
                    ),
                  ),
                  _buildPriceRow('Grand Total', price,
                      isTotal: true, isDark: isDark),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : () {
                        setState(() => _isSubmitting = true);
                        context.read<SubscriptionBloc>().add(
                              CreateSubscriptionFromSelection(
                                  selection: widget.selection),
                            );
                      },
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
                child: _isSubmitting
                    ? SizedBox(
                        width: 22.r,
                        height: 22.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Start Subscription ✨',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            BlocListener<SubscriptionBloc, SubscriptionState>(
              listener: (context, state) {
                if (state is SubscriptionCreatedSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.glassAccent,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/dashboard', (_) => false);
                }
                if (state is SubscriptionError) {
                  setState(() => _isSubmitting = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              child: const SizedBox.shrink(),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
    required bool isDark,
  }) {
    return GlassCard(
      padding: EdgeInsets.all(18.r),
      borderRadius: AppRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.glassAccent : AppColors.primaryOrange,
            ),
          ),
          SizedBox(height: 14.h),
          child,
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    String label,
    double amount, {
    bool isFree = false,
    bool isTotal = false,
    required bool isDark,
  }) {
    final textPrimaryColor =
        isDark ? AppColors.glassText : AppColors.lightTextPrimary;
    final textSecondaryColor =
        isDark ? AppColors.glassTextDim : AppColors.lightTextSecondary;
    final accentColor =
        isDark ? AppColors.glassAccent : AppColors.primaryOrange;

    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: isTotal ? 'Poppins' : 'Inter',
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? textPrimaryColor : textSecondaryColor,
            ),
          ),
          isFree
              ? Text(
                  'FREE',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.glassAccent,
                  ),
                )
              : Text(
                  '₹${amount.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: isTotal ? 19.sp : 14.sp,
                    fontWeight: FontWeight.bold,
                    color: isTotal ? accentColor : textPrimaryColor,
                  ),
                ),
        ],
      ),
    );
  }
}
