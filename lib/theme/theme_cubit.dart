/// BookMyJuice Theme Management
///
/// BLoC/Cubit for managing light/dark/system theme preference.
/// Persists preference using [SharedPreferences].
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Theme mode selection state.
enum AppThemeMode {
  /// Follow system setting
  system,

  /// Always light
  light,

  /// Always dark
  dark,
}

/// The current theme state.
class ThemeState {
  /// The selected theme mode.
  final AppThemeMode themeMode;

  /// Creates a [ThemeState].
  const ThemeState({
    this.themeMode = AppThemeMode.system,
  });

  /// Create a copy with updated fields.
  ThemeState copyWith({
    AppThemeMode? themeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }

  /// Resolve the [ThemeMode] from the current [AppThemeMode].
  ThemeMode get resolvedThemeMode {
    switch (themeMode) {
      case AppThemeMode.system:
        return ThemeMode.system;
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// Get light theme from [AppTheme].
  static ThemeData get lightTheme => AppTheme.light;

  /// Get dark theme from [AppTheme].
  static ThemeData get darkTheme => AppTheme.dark;
}

/// Cubit for managing app theme state.
///
/// Persists the [AppThemeMode] to [SharedPreferences] and
/// restores it on app restart.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  static const String _prefsKey = 'app_theme_mode';

  /// Load the persisted theme preference.
  Future<void> loadPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stored = prefs.getString(_prefsKey);
      if (stored != null) {
        final mode = AppThemeMode.values.firstWhere(
          (m) => m.name == stored,
          orElse: () => AppThemeMode.system,
        );
        emit(state.copyWith(themeMode: mode));
      }
    } catch (_) {
      // Default to system if load fails
      emit(state.copyWith(themeMode: AppThemeMode.system));
    }
  }

  /// Set light theme.
  Future<void> setLightTheme() async {
    emit(state.copyWith(themeMode: AppThemeMode.light));
    await _persist(AppThemeMode.light);
  }

  /// Set dark theme.
  Future<void> setDarkTheme() async {
    emit(state.copyWith(themeMode: AppThemeMode.dark));
    await _persist(AppThemeMode.dark);
  }

  /// Set theme to follow system.
  Future<void> setSystemTheme() async {
    emit(state.copyWith(themeMode: AppThemeMode.system));
    await _persist(AppThemeMode.system);
  }

  /// Persist the [mode] to SharedPreferences.
  Future<void> _persist(AppThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (_) {
      // Silently fail persistence — not critical
    }
  }
}
