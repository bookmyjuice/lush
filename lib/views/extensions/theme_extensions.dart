import 'package:flutter/material.dart';
import '../../theme.dart';

extension ThemeExtensions on BuildContext {
  Color get lightGray => LushTheme.nearlyWhite;
  Color get primaryColor => LushTheme.nearlyBlue;
  Color get backgroundColor => LushTheme.background;
  Color get textColor => LushTheme.darkerText;
  Color get lightTextColor => LushTheme.lightText;
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}