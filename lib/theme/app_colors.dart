/// BookMyJuice Design System Colors
///
/// All color tokens from docs/DESIGN_SYSTEM.md mapped to Flutter constants.
/// Uses Material 3 ColorScheme seeds.
library;

import 'package:flutter/material.dart';

/// Brand and semantic color constants.
///
/// These are the raw color tokens. Use [AppTheme] light/dark [ThemeData]
/// for consistent application of colors across the UI.
class AppColors {
  AppColors._();

  // ── Brand Primary (Orange) ──
  static const Color primaryOrange = Color(0xFFFF8C42);
  static const Color primaryOrangeDark = Color(0xFFE67E3A);
  static const Color primaryOrangeLight = Color(0xFFFFA96A);

  // ── Brand Secondary (Teal) ──
  static const Color secondaryTeal = Color(0xFF4ECDC4);
  static const Color secondaryTealDark = Color(0xFF45B7AF);
  static const Color secondaryTealLight = Color(0xFF7FD9D2);

  // ── Semantic / Status ──
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ── Neutrals ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFEFEFE);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  static const Color nearlyBlack = Color(0xFF213333);

  // ── Light Theme Surface ──
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF213333);
  static const Color lightTextSecondary = Color(0xFF424242);
  static const Color lightTextDisabled = Color(0xFFBDBDBD);

  // ── Dark Theme Surface ──
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFEFEFE);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextDisabled = Color(0xFF808080);
}
