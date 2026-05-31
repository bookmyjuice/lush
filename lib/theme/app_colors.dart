/// BookMyJuice Design System Colors
///
/// All color tokens from docs/DESIGN_SYSTEM.md mapped to Flutter constants.
/// Uses Material 3 ColorScheme seeds.
library;

import 'package:flutter/material.dart';

/// Brand and semantic color constants.
///
/// These are the raw color tokens. Use [AppTheme] light/dark [ThemeData]
/// for consistent application of colors across the UI.
class AppColors {
  AppColors._();

  // ── Brand Primary (Green) ──
  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color primaryGreenDark = Color(0xFF1B5E20);
  static const Color primaryGreenLight = Color(0xFF43A047);

  // ── Brand Gradients ──
  static const Color gradientStart = Color(0xFF1B5E20);
  static const Color gradientEnd = Color(0xFF43A047);

  // ── Brand Secondary ──
  static const Color primaryAccent = Color(0xFF66BB6A);
  static const Color secondaryTeal = Color(0xFF4ECDC4);
  static const Color secondaryTealDark = Color(0xFF45B7AF);
  static const Color secondaryTealLight = Color(0xFF7FD9D2);

  // ── Legacy (Orange — kept for backward compat) ──
  static const Color primaryOrange = Color(0xFF2E7D32);
  static const Color primaryOrangeDark = Color(0xFF1B5E20);
  static const Color primaryOrangeLight = Color(0xFF43A047);

  // ── Semantic / Status ──
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // ── Neutrals ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFFEFEFE);
  static const Color lightGrey = Color(0xFFF5F5F5);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color darkGrey = Color(0xFF424242);
  static const Color nearlyBlack = Color(0xFF213333);

  // ── White Opacity Variants (for login screen) ──
  /// 54% opacity white.
  static const Color white54 = Color(0x8AFFFFFF);

  /// 70% opacity white.
  static const Color white70 = Color(0xB3FFFFFF);

  // ── Light Theme Surface ──
  static const Color lightBackground = Color(0xFFFAFAFA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF213333);
  static const Color lightTextSecondary = Color(0xFF424242);
  static const Color lightTextDisabled = Color(0xFFBDBDBD);

  // ── Dark Theme Surface ──
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkCard = Color(0xFF1E1E1E);
  static const Color darkDivider = Color(0xFF2C2C2C);
  static const Color darkTextPrimary = Color(0xFFFEFEFE);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextDisabled = Color(0xFF808080);

  // ── Glassmorphism Tokens ──
  /// Deep background for dark glass screens (#0A0F0D).
  static const Color glassBg = Color(0xFF0A0F0D);

  /// Elevated surface for glass cards (#0F1613).
  static const Color glassElevated = Color(0xFF0F1613);

  /// Glass surface overlay — 6% white.
  static const Color glassSurface = Color(0x0FFFFFFF);

  /// Stronger glass overlay — 8% white.
  static const Color glassSurfaceStrong = Color(0x14FFFFFF);

  /// Glass border — 12% white.
  static const Color glassBorder = Color(0x1AFFFFFF);

  /// Glass border subtle — 8% white.
  static const Color glassBorderSubtle = Color(0x14FFFFFF);

  /// Glass text primary (#E8F5E9 — light green-white).
  static const Color glassText = Color(0xFFE8F5E9);

  /// Glass text dim (#9FB0A8 — muted green-grey).
  static const Color glassTextDim = Color(0xFF9FB0A8);

  /// Glass accent green (#22C55E — neon green).
  static const Color glassAccent = Color(0xFF22C55E);

  /// Glass accent green dark (#16A34A).
  static const Color glassAccentDark = Color(0xFF16A34A);

  /// Glass accent orange (#FB923C).
  static const Color glassOrange = Color(0xFFFB923C);

  /// Glass accent pink (#F472B6).
  static const Color glassPink = Color(0xFFF472B6);

  /// Glass accent purple (#A78BFA).
  static const Color glassPurple = Color(0xFFA78BFA);

  /// Glass glow shadow — neon green.
  static const Color glassGlow = Color(0x4022C55E);

  // ── Light Glassmorphism Tokens ──
  /// Light background for glass in light theme (#F0F5F2).
  static const Color glassBgLight = Color(0xFFF0F5F2);

  /// Light elevated glass (#EAF0EC).
  static const Color glassElevatedLight = Color(0xFFEAF0EC);

  /// Light glass overlay — 40% white.
  static const Color glassSurfaceLight = Color(0x66FFFFFF);

  /// Light glass border — 20% black.
  static const Color glassBorderLight = Color(0x33000000);
}
