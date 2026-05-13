/// Backward-compatible LushTheme shim.
///
/// This file provides the legacy [LushTheme] API surface that existing
/// widgets reference. All values delegate to the new [AppColors] tokens
/// from the ThemeData-based design system (lib/theme/app_colors.dart).
///
/// NEW WIDGETS SHOULD USE [AppColors] AND [AppTheme] DIRECTLY.
///
/// See docs/DESIGN_SYSTEM_FLUTTER_INTEGRATION.md for the token-to-code map.

import 'package:flutter/material.dart';
import 'theme/app_colors.dart';

/// Legacy theme constants used by existing views.
///
/// DEPRECATED: New code should use [AppColors] and [AppTheme] instead.
class LushTheme {
  LushTheme._();

  // ── Colors ──

  /// Primary brand orange.
  static const Color orangeAccent = AppColors.primaryOrange;

  /// Background color (light theme).
  static const Color background = AppColors.lightBackground;

  /// White.
  static const Color white = AppColors.white;

  /// Off-white / nearly white.
  static const Color nearlyWhite = AppColors.offWhite;

  /// Primary text color (dark).
  static const Color darkerText = AppColors.lightTextPrimary;

  /// Secondary text color.
  static const Color lightText = AppColors.lightTextSecondary;

  /// Neutral grey.
  static const Color grey = AppColors.grey;

  /// App bar color (primary orange).
  static const Color appbarColor = AppColors.primaryOrange;

  /// Blue accent (info blue).
  static const Color nearlyBlue = AppColors.info;

  /// Dark blue accent (teal dark).
  static const Color nearlyDarkBlue = AppColors.secondaryTealDark;

  // ── Typography ──

  /// Legacy font family name.
  /// Used by old widgets that hardcode fontFamily.
  /// Prefer ThemeData text theme for new widgets.
  static const String fontName = 'Poppins';

  // ── Legacy Text Styles (minimal set for backward compat) ──

  /// Body1 style (used in a few commented-out references).
  static const TextStyle body1 = TextStyle(
    fontFamily: fontName,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: darkerText,
  );
}
