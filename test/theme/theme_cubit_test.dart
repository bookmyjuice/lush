/// Tests for [ThemeCubit].
///
/// Verifies theme mode switching and preference persistence.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late ThemeCubit cubit;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    cubit = ThemeCubit();
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state has system theme mode', () {
    expect(cubit.state.themeMode, AppThemeMode.system);
  });

  test('resolvedThemeMode defaults to system', () {
    expect(cubit.state.resolvedThemeMode, ThemeMode.system);
  });

  test('setLightTheme updates to light mode', () async {
    await cubit.setLightTheme();
    expect(cubit.state.themeMode, AppThemeMode.light);
  });

  test('setDarkTheme updates to dark mode', () async {
    await cubit.setDarkTheme();
    expect(cubit.state.themeMode, AppThemeMode.dark);
  });

  test('setSystemTheme updates to system mode', () async {
    await cubit.setDarkTheme();
    expect(cubit.state.themeMode, AppThemeMode.dark);

    await cubit.setSystemTheme();
    expect(cubit.state.themeMode, AppThemeMode.system);
  });

  test('loadPreference restores persisted theme', () async {
    SharedPreferences.setMockInitialValues({
      'app_theme_mode': 'dark',
    });
    await cubit.loadPreference();
    expect(cubit.state.themeMode, AppThemeMode.dark);
  });

  test('loadPreference defaults to system when no stored value', () async {
    SharedPreferences.setMockInitialValues({});
    await cubit.loadPreference();
    expect(cubit.state.themeMode, AppThemeMode.system);
  });

  test('loadPreference defaults to system on invalid stored value', () async {
    SharedPreferences.setMockInitialValues({
      'app_theme_mode': 'invalid_mode',
    });
    await cubit.loadPreference();
    expect(cubit.state.themeMode, AppThemeMode.system);
  });

  test('persists light theme after setLightTheme', () async {
    await cubit.setLightTheme();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_theme_mode'), 'light');
  });

  test('persists dark theme after setDarkTheme', () async {
    await cubit.setDarkTheme();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_theme_mode'), 'dark');
  });

  test('persists system theme after setSystemTheme', () async {
    await cubit.setSystemTheme();
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('app_theme_mode'), 'system');
  });

  test('state transitions: system -> light -> dark -> system', () async {
    expect(cubit.state.themeMode, AppThemeMode.system);
    expect(cubit.state.resolvedThemeMode, ThemeMode.system);

    await cubit.setLightTheme();
    expect(cubit.state.themeMode, AppThemeMode.light);
    expect(cubit.state.resolvedThemeMode, ThemeMode.light);

    await cubit.setDarkTheme();
    expect(cubit.state.themeMode, AppThemeMode.dark);
    expect(cubit.state.resolvedThemeMode, ThemeMode.dark);

    await cubit.setSystemTheme();
    expect(cubit.state.themeMode, AppThemeMode.system);
    expect(cubit.state.resolvedThemeMode, ThemeMode.system);
  });
}
