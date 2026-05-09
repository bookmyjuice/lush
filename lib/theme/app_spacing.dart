/// BookMyJuice Design System Spacing
///
/// Spacing scale from docs/DESIGN_SYSTEM.md.
/// Base unit is 4dp.
library;

/// Spacing constants for consistent layout across the app.
///
/// ```dart
/// SizedBox(height: AppSpacing.md)   // 16dp vertical gap
/// EdgeInsets.all(AppSpacing.md)     // 16dp padding on all sides
/// ```
class AppSpacing {
  AppSpacing._();

  /// 4dp — Tight spacing (icon-text gap)
  static const double xs = 4.0;

  /// 8dp — Small spacing (list items)
  static const double sm = 8.0;

  /// 16dp — Default spacing (padding)
  static const double md = 16.0;

  /// 24dp — Section spacing
  static const double lg = 24.0;

  /// 32dp — Large section gaps
  static const double xl = 32.0;

  /// 48dp — Major divisions
  static const double xxl = 48.0;

  /// 64dp — Screen margins
  static const double xxxl = 64.0;
}
