import 'package:flutter/material.dart';
import 'package:lush/theme/app_colors.dart';

/// Theme extensions providing convenient access to commonly used colors
/// from the AppColors design system.
extension ThemeExtensions on BuildContext {
  Color get lightGray => AppColors.offWhite;
  Color get primaryColor => AppColors.info;
  Color get backgroundColor => AppColors.lightBackground;
  Color get textColor => AppColors.lightTextPrimary;
  Color get lightTextColor => AppColors.lightTextSecondary;
}