import 'package:flutter/material.dart';
import 'package:lush/utils/font_utils.dart';

/// Utility class to ensure consistent English text rendering
class TextUtils {
  /// Creates a Text widget with guaranteed English font rendering
  static Widget englishText(
    String text, {
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    double? textScaleFactor,
    String? semanticsLabel,
  }) {
    return Text(
      text,
      style: style ?? FontUtils.bodyText(),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      textScaler:
          textScaleFactor != null ? TextScaler.linear(textScaleFactor) : null,
      semanticsLabel: semanticsLabel,
      locale: const Locale('en', 'US'),
    );
  }

  /// Creates a heading text widget with guaranteed English font rendering
  static Widget headingText(
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
  }) {
    return englishText(
      text,
      style: FontUtils.heading1(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  /// Creates a body text widget with guaranteed English font rendering
  static Widget bodyText(
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return englishText(
      text,
      style: FontUtils.bodyText(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Creates a button text widget with guaranteed English font rendering
  static Widget buttonText(
    String text, {
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    TextAlign? textAlign,
  }) {
    return englishText(
      text,
      style: FontUtils.buttonText(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
    );
  }

  /// Creates a caption text widget with guaranteed English font rendering
  static Widget captionText(
    String text, {
    double? fontSize,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
  }) {
    return englishText(
      text,
      style: FontUtils.captionText(
        fontSize: fontSize,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
    );
  }

  /// Sanitizes text to ensure it contains only English characters
  static String sanitizeText(String text) {
    // Remove any non-ASCII characters and replace with appropriate alternatives
    return text
        .replaceAll(RegExp(r'[^\x00-\x7F]'), '') // Remove non-ASCII characters
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
        .trim();
  }

  /// Validates if text contains only English characters
  static bool isEnglishText(String text) {
    return RegExp(r'^[a-zA-Z0-9\s\.,!?;:()"' + "'" + r'\\-]+$').hasMatch(text);
  }
}
