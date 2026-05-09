/// BookMyJuice Design System Typography
///
/// Type scale from docs/DESIGN_SYSTEM.md mapped to Flutter [TextTheme].
/// Uses Google Fonts Roboto as the primary font.
library;

import 'package:flutter/material.dart';

/// Factory for BMJ [TextTheme] following the design system type scale.
///
/// | Style | Size | Weight | Use Case |
/// |-------|------|--------|----------|
/// | Display Large | 57px | 400 | Hero sections |
/// | Display Medium | 45px | 400 | Major headings |
/// | Headline Large | 32px | 600 | Screen titles |
/// | Headline Medium | 28px | 600 | Section headers |
/// | Title Large | 22px | 500 | Card titles |
/// | Title Medium | 16px | 500 | Subtitles |
/// | Body Large | 16px | 400 | Paragraphs |
/// | Body Medium | 14px | 400 | Body text |
/// | Label Large | 14px | 500 | Buttons |
/// | Label Small | 11px | 500 | Captions |
class AppTextStyles {
  AppTextStyles._();

  /// The font family used across the BMJ design system.
  static const String fontFamily = 'Roboto';

  /// Creates the complete BMJ [TextTheme] with Roboto font family applied.
  ///
  /// Uses direct [TextStyle.fontFamily] assignment rather than
  /// [GoogleFonts.robotoTextTheme] wrapping to avoid:
  /// - Async font loading at construction time
  /// - Network dependency during tests
  /// - Unnecessary widget rebuilds
  ///
  /// In production, Roboto is loaded by the Google Fonts Flutter package
  /// when the app starts (see main.dart).
  static TextTheme get textTheme {
    return const TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 57,
        fontWeight: FontWeight.w400,
        height: 64 / 57,
        letterSpacing: -0.25,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 52 / 45,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 40 / 32,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 36 / 28,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 28 / 22,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
        letterSpacing: 0.15,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
        letterSpacing: 0.25,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        letterSpacing: 0.1,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 16 / 11,
        letterSpacing: 0.5,
      ),
    );
  }
}
