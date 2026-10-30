/// BookMyJuice Design Tokens — Stitch `vibrant_zest` contract
///
/// Source of truth for every colour, radius, blur and motion value in the app.
/// Values are transcribed from `BMJ_UX_REHAUL_PLAN.md` §2 (`DESIGN.md`), with
/// the plan's **theme amendment** applied (2026-10-17): the product is
/// **light-first**, so every "dark glass" reading is re-read as its light-glass
/// equivalent (white 70–85 % surfaces, `#0F172A` text, orange/lime accents)
/// while the dark values from `DESIGN.md` stay available for the dark theme.
///
/// Rules baked in here (do not re-derive them at call sites):
/// - [orange] (`#F97316`) is **the** action colour: CTAs, selected chips, glow.
/// - [orangeSoft] (`#FFB690`) is emphasis text on dark, never a fill on light.
/// - [lime] (`#4AE176`) is savings/success/subscription ticks; on light use
///   [limeText] (`#067A3E`) when it carries text.
/// - A glow is `rgba(249,115,22,0.45)` — **never** a black drop shadow.
/// - Glass: blur 16 (sheets 24), fill 8 % white on dark / 70–85 % white on
///   light, border a 1 px hairline at 10 %.
library;

import 'package:flutter/material.dart';

import 'app_spacing.dart';

/// Raw Stitch tokens. Prefer [BMJPalette.of] inside widgets so the value
/// follows the active [ThemeData.brightness].
class BMJTokens {
  BMJTokens._();

  // ── Brand ──

  /// `primary-container` — the action colour.
  static const Color orange = Color(0xFFF97316);

  /// `primary` — headline emphasis; orange text on dark surfaces.
  static const Color orangeSoft = Color(0xFFFFB690);

  /// Pressed/visited orange and orange text on light surfaces (AA on white).
  static const Color orangeDeep = Color(0xFFC2410C);

  /// Mid orange — hover/pressed fill.
  static const Color orangeMid = Color(0xFFEA580C);

  /// `secondary` — savings, success, subscription ticks.
  static const Color lime = Color(0xFF4AE176);

  /// Deep lime for fills that carry white text.
  static const Color limeDeep = Color(0xFF00B954);

  /// Lime that is legible as text on a light surface.
  static const Color limeText = Color(0xFF067A3E);

  /// `tertiary` — informational badges.
  static const Color tertiary = Color(0xFF5DD9D0);

  /// Amber accent (rating stars, "cold pressed" tags).
  static const Color amber = Color(0xFFFFBC49);

  /// Destructive.
  static const Color errorLight = Color(0xFFDC2626);
  static const Color errorDark = Color(0xFFFFB4AB);

  /// `zest-glow` — rgba(249,115,22,0.45).
  static const Color glow = Color(0x73F97316);

  /// Ink that sits on a brand gradient or a solid primary fill.
  ///
  /// This is the token for "white", so screens never write `Colors.white`
  /// directly: a raw white text/icon disappears the moment the surface behind
  /// it is not saturated, which is exactly the light-theme bug the migration
  /// removed. Use [BMJPalette.surfaceContainer] for a white *surface*.
  static const Color inkOnBrand = Color(0xFFFFFFFF);

  // ── Light surfaces (design target) ──
  static const Color lightSurface = Color(0xFFFFF8F1);
  static const Color lightSurfaceDeep = Color(0xFFFDF1E5);
  static const Color lightSurfaceContainerLow = Color(0xFFFFFDFB);
  static const Color lightSurfaceContainer = Color(0xFFFFFFFF);
  static const Color lightSurfaceContainerHigh = Color(0xFFF7EDE3);
  static const Color lightSurfaceContainerHighest = Color(0xFFF1E4D7);
  static const Color lightOnSurface = Color(0xFF0F172A);
  static const Color lightOnSurfaceVariant = Color(0xFF57534E);
  static const Color lightOutline = Color(0xFFD6C3B4);
  static const Color lightOutlineVariant = Color(0xFFEADFD4);

  // ── Dark surfaces (DESIGN.md verbatim) ──
  static const Color darkSurface = Color(0xFF1C110B);
  static const Color darkSurfaceDeep = Color(0xFF0F1412);
  static const Color darkSurfaceContainerLow = Color(0xFF251913);
  static const Color darkSurfaceContainer = Color(0xFF291D16);
  static const Color darkSurfaceContainerHigh = Color(0xFF352720);
  static const Color darkSurfaceContainerHighest = Color(0xFF40322A);
  static const Color darkOnSurface = Color(0xFFF6DED3);
  static const Color darkOnSurfaceVariant = Color(0xFFE0C0B1);
  static const Color darkOutline = Color(0xFFA78B7D);
  static const Color darkOutlineVariant = Color(0xFF584237);

  // ── Glass ──

  /// Dark glass fill — 8 % white.
  static const Color darkGlassFill = Color(0x14FFFFFF);

  /// Dark glass fill, strong — 14 % white.
  static const Color darkGlassFillStrong = Color(0x24FFFFFF);

  /// Dark glass hairline — 10 % white.
  static const Color darkGlassBorder = Color(0x1AFFFFFF);

  /// Light glass fill — 72 % white over the warm surface.
  static const Color lightGlassFill = Color(0xB8FFFFFF);

  /// Light glass fill, strong — 88 % white.
  static const Color lightGlassFillStrong = Color(0xE0FFFFFF);

  /// Light glass hairline — 8 % slate.
  static const Color lightGlassBorder = Color(0x140F172A);

  // ── Space & shape ──

  static const double spaceXs = AppSpacing.xs;
  static const double spaceSm = AppSpacing.sm;
  static const double spaceMd = AppSpacing.md;
  static const double spaceLg = AppSpacing.lg;
  static const double spaceXl = AppSpacing.xl;

  /// Page margin (16) and gutter (12).
  static const double pageMargin = 16;
  static const double gutter = 12;

  /// Content max width for large/tablet windows.
  static const double contentMaxWidth = 430;

  /// 8 px inputs & chips.
  static const double radiusInput = 8;

  /// 16 px cards.
  static const double radiusCard = 16;

  /// 24 px sheets.
  static const double radiusSheet = 24;

  /// Fully rounded pills (nav, toggles, badges).
  static const double radiusPill = 999;

  /// Minimum touch target — 48 × 48 dp everywhere.
  static const double minTouchTarget = 48;

  // ── Depth ──

  /// Card/header blur.
  static const double blurGlass = 16;

  /// Sheet blur.
  static const double blurSheet = 24;

  /// Hairline width.
  static const double hairline = 1;

  /// Glow blur / spread.
  static const double glowBlur = 20;
  static const double glowSpread = 1;

  // ── Motion ──

  /// 200 ms easeOut for selection/segment changes.
  static const Duration motionFast = Duration(milliseconds: 200);
  static const Duration motionBase = Duration(milliseconds: 300);
  static const Curve motionCurve = Curves.easeOut;
}

/// Brightness-resolved view over [BMJTokens].
///
/// ```dart
/// final palette = BMJPalette.of(context);
/// Container(color: palette.surfaceContainer);
/// ```
@immutable
class BMJPalette {
  const BMJPalette({
    required this.isDark,
    required this.surface,
    required this.surfaceDeep,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.glassFill,
    required this.glassFillStrong,
    required this.glassBorder,
    required this.primary,
    required this.primaryEmphasis,
    required this.onPrimary,
    required this.accent,
    required this.accentText,
    required this.error,
  });

  /// Whether the dark token set is active.
  final bool isDark;

  final Color surface;
  final Color surfaceDeep;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final Color glassFill;
  final Color glassFillStrong;
  final Color glassBorder;

  /// The action colour (`#F97316` in both themes).
  final Color primary;

  /// Emphasis orange — `#C2410C` on light (AA text), `#FFB690` on dark.
  final Color primaryEmphasis;

  /// Foreground on [primary].
  final Color onPrimary;

  /// Lime fill (`#4AE176`).
  final Color accent;

  /// Lime that is legible as text on [surface].
  final Color accentText;

  final Color error;

  /// Light-first token set — the design target.
  static const BMJPalette light = BMJPalette(
    isDark: false,
    surface: BMJTokens.lightSurface,
    surfaceDeep: BMJTokens.lightSurfaceDeep,
    surfaceContainerLow: BMJTokens.lightSurfaceContainerLow,
    surfaceContainer: BMJTokens.lightSurfaceContainer,
    surfaceContainerHigh: BMJTokens.lightSurfaceContainerHigh,
    surfaceContainerHighest: BMJTokens.lightSurfaceContainerHighest,
    onSurface: BMJTokens.lightOnSurface,
    onSurfaceVariant: BMJTokens.lightOnSurfaceVariant,
    outline: BMJTokens.lightOutline,
    outlineVariant: BMJTokens.lightOutlineVariant,
    glassFill: BMJTokens.lightGlassFill,
    glassFillStrong: BMJTokens.lightGlassFillStrong,
    glassBorder: BMJTokens.lightGlassBorder,
    primary: BMJTokens.orange,
    primaryEmphasis: BMJTokens.orangeDeep,
    onPrimary: Colors.white,
    accent: BMJTokens.lime,
    accentText: BMJTokens.limeText,
    error: BMJTokens.errorLight,
  );

  /// `DESIGN.md` dark token set.
  static const BMJPalette dark = BMJPalette(
    isDark: true,
    surface: BMJTokens.darkSurface,
    surfaceDeep: BMJTokens.darkSurfaceDeep,
    surfaceContainerLow: BMJTokens.darkSurfaceContainerLow,
    surfaceContainer: BMJTokens.darkSurfaceContainer,
    surfaceContainerHigh: BMJTokens.darkSurfaceContainerHigh,
    surfaceContainerHighest: BMJTokens.darkSurfaceContainerHighest,
    onSurface: BMJTokens.darkOnSurface,
    onSurfaceVariant: BMJTokens.darkOnSurfaceVariant,
    outline: BMJTokens.darkOutline,
    outlineVariant: BMJTokens.darkOutlineVariant,
    glassFill: BMJTokens.darkGlassFill,
    glassFillStrong: BMJTokens.darkGlassFillStrong,
    glassBorder: BMJTokens.darkGlassBorder,
    primary: BMJTokens.orange,
    primaryEmphasis: BMJTokens.orangeSoft,
    onPrimary: Colors.white,
    accent: BMJTokens.lime,
    accentText: BMJTokens.lime,
    error: BMJTokens.errorDark,
  );

  /// Resolve the token set for the active theme.
  static BMJPalette of(BuildContext context) =>
      fromBrightness(Theme.of(context).brightness);

  /// Resolve the token set for an explicit [brightness].
  static BMJPalette fromBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;
}
