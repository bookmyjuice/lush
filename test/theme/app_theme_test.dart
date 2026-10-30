/// Tests for [AppTheme] light and dark theme configurations.
///
/// Verifies that both themes are properly constructed and contain
/// expected token overrides from the design system.
library;

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/app_theme.dart';
import 'package:lush/theme/bmj_tokens.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  group('AppTheme light', () {
    late ThemeData theme;

    setUp(() {
      // GoogleFonts.poppinsTextTheme() triggers an async HTTP font download.
      // In TestWidgetsFlutterBinding all HTTP returns 400, causing an unhandled
      // async exception that kills the test zone. We wrap in runZonedGuarded to
      // suppress this — the theme is built synchronously and valid (just with
      // fallback fonts), so all property-assertions pass.
      runZonedGuarded(() {
        theme = AppTheme.light;
      }, (Object error, StackTrace stack) {
        // Suppress GoogleFonts async font-loading errors
      });
    });

    test('is Material 3', () => expect(theme.useMaterial3, isTrue));
    test('has light brightness', () => expect(theme.brightness, Brightness.light));
    test('has non-null color scheme', () => expect(theme.colorScheme, isNotNull));
    test('has primary color defined', () => expect(theme.colorScheme.primary, isNotNull));
    test('has non-null text theme', () => expect(theme.textTheme, isNotNull));
    test('has non-null app bar theme', () => expect(theme.appBarTheme, isNotNull));
    test('has non-null card theme', () => expect(theme.cardTheme, isNotNull));
    test('has non-null input decoration theme', () => expect(theme.inputDecorationTheme, isNotNull));
    test('has non-null navigation bar theme', () => expect(theme.navigationBarTheme, isNotNull));
    test('has non-null snack bar theme', () => expect(theme.snackBarTheme, isNotNull));
    test('has non-null elevated button theme', () => expect(theme.elevatedButtonTheme, isNotNull));
    test('has non-null outlined button theme', () => expect(theme.outlinedButtonTheme, isNotNull));
    test('has non-null text button theme', () => expect(theme.textButtonTheme, isNotNull));
  });

  group('AppTheme dark', () {
    late ThemeData theme;

    setUp(() {
      theme = AppTheme.dark;
    });

    test('is Material 3', () => expect(theme.useMaterial3, isTrue));
    test('has dark brightness', () => expect(theme.brightness, Brightness.dark));
    test('has non-null color scheme', () => expect(theme.colorScheme, isNotNull));
    test('has primary color defined', () => expect(theme.colorScheme.primary, isNotNull));
    test('has non-null text theme', () => expect(theme.textTheme, isNotNull));
    test('has non-null app bar theme', () => expect(theme.appBarTheme, isNotNull));
    test('has non-null card theme', () => expect(theme.cardTheme, isNotNull));
    test('has non-null input decoration theme', () => expect(theme.inputDecorationTheme, isNotNull));
    test('has non-null navigation bar theme', () => expect(theme.navigationBarTheme, isNotNull));
    test('has non-null snack bar theme', () => expect(theme.snackBarTheme, isNotNull));
    test('has non-null elevated button theme', () => expect(theme.elevatedButtonTheme, isNotNull));
    test('has non-null outlined button theme', () => expect(theme.outlinedButtonTheme, isNotNull));
    test('has non-null text button theme', () => expect(theme.textButtonTheme, isNotNull));
  });
  group('Design tokens (vibrant_zest)', () {
    test('brand orange is #F97316', () {
      expect(BMJTokens.orange, const Color(0xFFF97316));
    });

    test('lime accent is #4AE176', () {
      expect(BMJTokens.lime, const Color(0xFF4AE176));
    });

    test('glass blur, sheet blur and hairline match the mocks', () {
      expect(BMJTokens.blurGlass, 16);
      expect(BMJTokens.blurSheet, 24);
      expect(BMJTokens.hairline, 1);
    });

    test('minimum touch target is 48 dp', () {
      expect(BMJTokens.minTouchTarget, greaterThanOrEqualTo(48));
    });

    test('light palette maps brand orange to primary', () {
      expect(BMJPalette.light.primary, BMJTokens.orange);
      expect(BMJPalette.light.onPrimary, Colors.white);
      expect(BMJPalette.light.isDark, isFalse);
    });

    test('dark palette keeps the same primary and flips isDark', () {
      expect(BMJPalette.dark.primary, BMJTokens.orange);
      expect(BMJPalette.dark.isDark, isTrue);
    });

    test('light and dark surfaces differ', () {
      expect(BMJPalette.light.surface, isNot(BMJPalette.dark.surface));
    });

    test('brightness resolves to the matching palette', () {
      expect(BMJPalette.fromBrightness(Brightness.light), BMJPalette.light);
      expect(BMJPalette.fromBrightness(Brightness.dark), BMJPalette.dark);
    });

    test('display slots use Plus Jakarta Sans', () {
      final theme = AppTextStyles.textTheme;
      expect(theme.displayLarge?.fontFamily, AppTextStyles.displayFontFamily);
      expect(theme.headlineSmall?.fontFamily, AppTextStyles.displayFontFamily);
      expect(theme.titleLarge?.fontFamily, AppTextStyles.displayFontFamily);
    });

    test('body and label slots use Inter', () {
      final theme = AppTextStyles.textTheme;
      expect(theme.bodyMedium?.fontFamily, AppTextStyles.bodyFontFamily);
      expect(theme.labelLarge?.fontFamily, AppTextStyles.bodyFontFamily);
    });

    test('numeric styles use tabular figures', () {
      expect(
        BMJType.statNum.fontFeatures,
        contains(const ui.FontFeature.tabularFigures()),
      );
      expect(
        BMJType.price.fontFeatures,
        contains(const ui.FontFeature.tabularFigures()),
      );
    });

    test('no slot falls back to Roboto', () {
      final theme = AppTextStyles.textTheme;
      final families = <String?>[
        theme.displayLarge?.fontFamily,
        theme.displayMedium?.fontFamily,
        theme.displaySmall?.fontFamily,
        theme.headlineLarge?.fontFamily,
        theme.headlineMedium?.fontFamily,
        theme.headlineSmall?.fontFamily,
        theme.titleLarge?.fontFamily,
        theme.titleMedium?.fontFamily,
        theme.titleSmall?.fontFamily,
        theme.bodyLarge?.fontFamily,
        theme.bodyMedium?.fontFamily,
        theme.bodySmall?.fontFamily,
        theme.labelLarge?.fontFamily,
        theme.labelMedium?.fontFamily,
        theme.labelSmall?.fontFamily,
      ];

      expect(families, isNot(contains('Roboto')));
      expect(families.where((f) => f == null), isEmpty);
    });
  });

}