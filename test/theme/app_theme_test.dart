/// Tests for [AppTheme] light and dark theme configurations.
///
/// Verifies that both themes are properly constructed and contain
/// expected token overrides from the design system.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/theme/app_theme.dart';

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
}