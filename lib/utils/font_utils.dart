import 'package:flutter/material.dart';
import 'package:lush/theme/app_text_styles.dart';

/// Utility class for consistent font usage across the app.
///
/// Kept as a thin façade over the design-system type ramp so the existing call
/// sites (login, profile, checkout, onboarding…) inherit Stitch `vibrant_zest`
/// typography without a line-by-line rewrite. `GoogleFonts.roboto` is gone: it
/// downloaded fonts at runtime and silently forced Roboto, which is the single
/// biggest reason screens never matched the Stitch mocks.
class FontUtils {
  /// Display family — headings and buttons.
  static const String primaryFontFamily = AppTextStyles.displayFontFamily;

  /// Body family.
  static const String secondaryFontFamily = AppTextStyles.bodyFontFamily;

  /// Applies caller overrides on top of a design-system slot.
  ///
  /// A `null` [color] leaves the colour unset so the text inherits the ambient
  /// `DefaultTextStyle`; that makes dark mode work for call sites that never
  /// passed a colour (they used to hard-code `Colors.black`).
  static TextStyle _apply(
    TextStyle base, {
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? height,
  }) {
    return base.copyWith(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
    );
  }

  /// Heading — 22/28, 700, Plus Jakarta Sans.
  static TextStyle heading1({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return _apply(
      AppTextStyles.textTheme.titleLarge!,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Body — 14/20, 400, Inter.
  static TextStyle bodyText({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return _apply(
      AppTextStyles.textTheme.bodyMedium!,
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Button label — 14/20, 700, Inter (white by default, as CTA labels are
  /// always drawn on the orange fill).
  static TextStyle buttonText({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return _apply(
      AppTextStyles.textTheme.labelLarge!,
      color: color ?? Colors.white,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }

  /// Input hint — 14/20, 400, Inter, muted.
  static TextStyle hintText({
    Color? color,
    double? fontSize,
  }) {
    return _apply(
      AppTextStyles.textTheme.bodyMedium!,
      color: color,
      fontSize: fontSize,
    );
  }

  /// Caption — 12/16, 400, Inter, muted.
  static TextStyle captionText({
    Color? color,
    double? fontSize,
  }) {
    return _apply(
      AppTextStyles.textTheme.bodySmall!,
      color: color,
      fontSize: fontSize,
    );
  }
}
