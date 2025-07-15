import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Utility class for consistent font usage across the app
class FontUtils {
  // Define primary font families to use
  static const String primaryFontFamily = 'Roboto';
  static const String secondaryFontFamily = 'OpenSans';

  /// Get a consistent text style for headings
  static TextStyle heading1({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        color: color ?? Colors.black,
        fontSize: fontSize ?? 24,
        fontWeight: fontWeight ?? FontWeight.bold,
        fontFamily: primaryFontFamily,
      ),
    );
  }

  /// Get a consistent text style for body text
  static TextStyle bodyText({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        color: color ?? Colors.black,
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? FontWeight.normal,
        fontFamily: primaryFontFamily,
      ),
    );
  }

  /// Get a consistent text style for buttons
  static TextStyle buttonText({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        color: color ?? Colors.white,
        fontSize: fontSize ?? 16,
        fontWeight: fontWeight ?? FontWeight.w600,
        fontFamily: primaryFontFamily,
      ),
    );
  }

  /// Get a consistent text style for hints
  static TextStyle hintText({
    Color? color,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        color: color ?? Colors.grey,
        fontSize: fontSize ?? 14,
        fontFamily: primaryFontFamily,
      ),
    );
  }

  /// Get a consistent text style for captions
  static TextStyle captionText({
    Color? color,
    double? fontSize,
  }) {
    return GoogleFonts.roboto(
      textStyle: TextStyle(
        color: color ?? Colors.grey,
        fontSize: fontSize ?? 12,
        fontFamily: primaryFontFamily,
      ),
    );
  }
}
