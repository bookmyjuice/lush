/// BookMyJuice Design System Colors
///
/// **Legacy names, Stitch values.** `BMJ_UX_REHAUL_PLAN.md` §2.1 maps every
/// existing `AppColors.*` constant onto the `vibrant_zest` palette, so no call
/// site has to change: the names stay, the values move. All values come from
/// [BMJTokens]; new code should read [BMJPalette] instead of hard-coding a
/// theme side here.
///
/// Light is the design target (plan amendment 2026-10-17). The dark constants
/// below keep the `DESIGN.md` surface tier.
library;

import 'package:flutter/material.dart';

import 'bmj_tokens.dart';

/// Brand and semantic color constants.
///
/// These are the raw color tokens. Use [AppTheme] light/dark [ThemeData]
/// for consistent application of colors across the UI.
class AppColors {
  AppColors._();

  // ── Brand Primary (Orange) — Stitch action colour ──

  /// `primary-container` — CTAs, selected chips, glow.
  static const Color primaryOrange = BMJTokens.orange;
  static const Color primaryOrangeDark = BMJTokens.orangeDeep;
  static const Color primaryOrangeLight = BMJTokens.orangeSoft;

  // ── Brand Primary (Green) — lime secondary ──

  /// Lime that is legible as text on the light surface.
  static const Color primaryGreen = BMJTokens.limeText;
  static const Color primaryGreenDark = BMJTokens.limeDeep;
  static const Color primaryGreenLight = BMJTokens.lime;
  static const Color primaryAccent = BMJTokens.tertiary;

  // ── Brand Gradients ──
  static const Color gradientStart = BMJTokens.amber;
  static const Color gradientEnd = BMJTokens.orange;

  // ── Brand Secondary (Teal / tertiary) ──
  static const Color secondaryTeal = BMJTokens.tertiary;
  static const Color secondaryTealDark = Color(0xFF2FB3AA);
  static const Color secondaryTealLight = Color(0xFF8FE6DF);

  // ── Semantic / Status ──
  static const Color success = BMJTokens.limeText;
  static const Color warning = BMJTokens.amber;
  static const Color error = BMJTokens.errorLight;
  static const Color info = Color(0xFF0EA5E9);

  // ── Neutrals (warm, light-first) ──
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = BMJTokens.lightSurfaceContainerLow;
  static const Color lightGrey = BMJTokens.lightSurfaceContainerHigh;
  static const Color grey = Color(0xFF78716C);
  static const Color darkGrey = Color(0xFF44403C);
  static const Color nearlyBlack = BMJTokens.lightOnSurface;

  // ── White Opacity Variants (for login screen) ──
  /// 54% opacity white.
  static const Color white54 = Color(0x8AFFFFFF);

  /// 70% opacity white.
  static const Color white70 = Color(0xB3FFFFFF);

  // ── Light Theme Surface (design target) ──
  static const Color lightBackground = BMJTokens.lightSurface;
  static const Color lightSurface = BMJTokens.lightSurfaceContainer;
  static const Color lightCard = BMJTokens.lightSurfaceContainerLow;
  static const Color lightDivider = BMJTokens.lightOutlineVariant;
  static const Color lightTextPrimary = BMJTokens.lightOnSurface;
  static const Color lightTextSecondary = BMJTokens.lightOnSurfaceVariant;
  static const Color lightTextDisabled = Color(0xFFA8A29E);

  // ── Dark Theme Surface (DESIGN.md tier) ──
  static const Color darkBackground = BMJTokens.darkSurfaceDeep;
  static const Color darkSurface = BMJTokens.darkSurface;
  static const Color darkCard = BMJTokens.darkSurfaceContainer;
  static const Color darkDivider = BMJTokens.darkSurfaceContainerHighest;
  static const Color darkTextPrimary = BMJTokens.darkOnSurface;
  static const Color darkTextSecondary = BMJTokens.darkOnSurfaceVariant;
  static const Color darkTextDisabled = BMJTokens.darkOutline;

  // ── Glassmorphism Tokens ──
  /// Deep background for dark glass screens (was #0A0F0D).
  static const Color glassBg = BMJTokens.darkSurfaceDeep;

  /// Elevated surface for glass cards (was #0F1613).
  static const Color glassElevated = BMJTokens.darkSurface;

  /// Glass surface overlay — 8 % white.
  static const Color glassSurface = BMJTokens.darkGlassFill;

  /// Stronger glass overlay — 14 % white.
  static const Color glassSurfaceStrong = BMJTokens.darkGlassFillStrong;

  /// Glass border — 10 % white hairline.
  static const Color glassBorder = BMJTokens.darkGlassBorder;

  /// Glass border subtle — 8 % white.
  static const Color glassBorderSubtle = BMJTokens.darkGlassFill;

  /// Glass text primary (`#F6DED3` — warm on-surface).
  static const Color glassText = BMJTokens.darkOnSurface;

  /// Glass text dim (`#E0C0B1` — on-surface-variant).
  static const Color glassTextDim = BMJTokens.darkOnSurfaceVariant;

  /// Glass accent — neon lime.
  static const Color glassAccent = BMJTokens.lime;

  /// Glass accent, deep — white-on-fill lime.
  static const Color glassAccentDark = BMJTokens.limeDeep;

  /// Glass accent orange (`#FFB690`).
  static const Color glassOrange = BMJTokens.orangeSoft;

  /// Glass accent pink.
  static const Color glassPink = Color(0xFFFF8FA3);

  /// Glass accent purple.
  static const Color glassPurple = Color(0xFFA78BFA);

  /// Glass glow — `rgba(249,115,22,0.45)`, never a black shadow.
  static const Color glassGlow = BMJTokens.glow;

  // ── Light Glassmorphism Tokens ──
  /// Light background for glass (warm off-white).
  static const Color glassBgLight = BMJTokens.lightSurface;

  /// Light elevated glass.
  static const Color glassElevatedLight = BMJTokens.lightSurfaceContainerHigh;

  /// Light glass overlay — 72 % white.
  static const Color glassSurfaceLight = BMJTokens.lightGlassFill;

  /// Light glass border — 8 % slate hairline.
  static const Color glassBorderLight = BMJTokens.lightGlassBorder;
}
