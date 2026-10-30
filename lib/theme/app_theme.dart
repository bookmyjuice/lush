/// BookMyJuice Design System Theme — Stitch `vibrant_zest`
///
/// Material 3 [ThemeData] for both brightnesses, built from [BMJPalette] so a
/// token edit is the only edit needed. Colour, type, space and shape values live
/// in `bmj_tokens.dart` / `app_text_styles.dart` / `app_radius.dart`
/// (BMJ_UX_REHAUL_PLAN.md §2).
///
/// Rules enforced here instead of at every call site:
/// - the CTA fill is [BMJTokens.orange] with a white label and an orange
///   *glow* ([BMJTokens.glow]) — never a black drop shadow;
/// - inputs 8 px, cards 16 px, sheets 24 px, pills fully rounded;
/// - every Material text slot is populated by [AppTextStyles.textTheme], so no
///   widget silently falls back to Roboto mid-screen.
library;

import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'app_text_styles.dart';
import 'bmj_tokens.dart';

export 'app_radius.dart';

/// Deep ink for the light teal accent fills (tertiary containers).
const Color _tealInk = Color(0xFF00312E);

/// Factory for the BMJ light and dark [ThemeData].
///
/// Light is the design target (the product is light-first); dark reuses the
/// same construction over `DESIGN.md`'s dark surfaces.
class AppTheme {
  AppTheme._();

  /// BMJ light theme — the design target.
  static ThemeData get light => _build(BMJPalette.light);

  /// BMJ dark theme — same system, `DESIGN.md` dark surfaces.
  static ThemeData get dark => _build(BMJPalette.dark);

  /// Resolve the theme for an explicit [Brightness].
  static ThemeData of(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  // ── ColorScheme ──

  /// Brand-exact [ColorScheme].
  ///
  /// The seed only fills roles Stitch does not define; every role the UI reads
  /// is overridden below. `surfaceTint`/`shadow` are transparent so Material's
  /// M3 elevation overlay never tints (or greys) a glass surface.
  static ColorScheme _scheme(BMJPalette p) {
    final seed = ColorScheme.fromSeed(
      seedColor: BMJTokens.orange,
      brightness: p.isDark ? Brightness.dark : Brightness.light,
    );

    // A tint of [accent] over the page surface, so containers stay on-palette
    // instead of drifting into the seed's tonal ramps.
    Color tint(Color accent, double alpha) =>
        Color.alphaBlend(accent.withValues(alpha: alpha), p.surface);

    return seed.copyWith(
      primary: p.primary,
      onPrimary: p.onPrimary,
      primaryContainer: tint(p.primary, 0.16),
      onPrimaryContainer: p.primaryEmphasis,
      secondary: p.accent,
      onSecondary: BMJTokens.darkSurface,
      secondaryContainer: tint(p.accent, 0.18),
      onSecondaryContainer: p.accentText,
      tertiary: BMJTokens.tertiary,
      onTertiary: _tealInk,
      tertiaryContainer: tint(BMJTokens.tertiary, 0.18),
      onTertiaryContainer: _tealInk,
      error: p.error,
      onError: p.isDark ? BMJTokens.darkSurface : Colors.white,
      errorContainer: tint(p.error, 0.14),
      onErrorContainer: p.error,
      surface: p.surface,
      onSurface: p.onSurface,
      onSurfaceVariant: p.onSurfaceVariant,
      surfaceContainerLowest: p.surface,
      surfaceContainerLow: p.surfaceContainerLow,
      surfaceContainer: p.surfaceContainer,
      surfaceContainerHigh: p.surfaceContainerHigh,
      surfaceContainerHighest: p.surfaceContainerHighest,
      outline: p.outline,
      outlineVariant: p.outlineVariant,
      inverseSurface: p.isDark ? BMJTokens.lightSurface : BMJTokens.darkSurface,
      onInverseSurface:
          p.isDark ? BMJTokens.lightOnSurface : BMJTokens.darkOnSurface,
      inversePrimary: BMJTokens.orangeSoft,
      surfaceTint: Colors.transparent,
      shadow: Colors.transparent,
      scrim: const Color(0x66000000),
    );
  }

  // ── ThemeData ──

  static ThemeData _build(BMJPalette p) {
    final scheme = _scheme(p);
    final base = AppTextStyles.textTheme;
    final text = base.apply(
      bodyColor: p.onSurface,
      displayColor: p.onSurface,
    );

    final ctaShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.lg),
    );

    // One shared hairline field outline — `border` and `enabledBorder` are the
    // same 1 px `outlineVariant` stroke at the 8 px input radius.
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: BorderSide(color: p.outlineVariant),
    );

    // CTA: orange fill, white label, orange glow, 16 px radius, 52 px tall.
    final cta = ElevatedButton.styleFrom(
      backgroundColor: p.primary,
      foregroundColor: p.onPrimary,
      disabledBackgroundColor: p.outlineVariant,
      disabledForegroundColor: p.onSurfaceVariant,
      iconColor: p.onPrimary,
      elevation: 0,
      shadowColor: BMJTokens.glow,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(0, 52),
      shape: ctaShape,
      textStyle: base.labelLarge,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.isDark ? Brightness.dark : Brightness.light,
      colorScheme: scheme,
      textTheme: text,
      primaryTextTheme: text.apply(bodyColor: p.onPrimary),
      scaffoldBackgroundColor: p.surface,
      canvasColor: p.surface,
      dividerColor: p.outlineVariant,
      hintColor: p.onSurfaceVariant,
      iconTheme: IconThemeData(color: p.onSurfaceVariant, size: 24),

      // ── App Bar: flat, no tint, display face title ──
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: p.onSurface,
        iconTheme: IconThemeData(color: p.onSurface, size: 24),
        titleTextStyle: base.titleLarge?.copyWith(color: p.onSurface),
      ),

      // ── Buttons ──
      elevatedButtonTheme: ElevatedButtonThemeData(style: cta),
      filledButtonTheme: FilledButtonThemeData(style: cta),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.primaryEmphasis,
          backgroundColor: p.glassFill,
          side: BorderSide(color: p.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 52),
          shape: ctaShape,
          textStyle: base.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.primaryEmphasis,
          minimumSize: const Size(0, BMJTokens.minTouchTarget),
          textStyle: base.labelLarge,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: p.onSurfaceVariant,
          minimumSize: const Size(
            BMJTokens.minTouchTarget,
            BMJTokens.minTouchTarget,
          ),
        ),
      ),
      // ── Inputs: 8 px radius, hairline outline, 2 px orange focus ──
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.isDark ? p.glassFill : p.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: fieldBorder,
        enabledBorder: fieldBorder,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          borderSide: BorderSide(color: p.error, width: 2),
        ),
        labelStyle: base.bodyMedium?.copyWith(color: p.onSurfaceVariant),
        floatingLabelStyle: base.bodyMedium?.copyWith(
          color: p.primaryEmphasis,
          fontWeight: FontWeight.w600,
        ),
        hintStyle: base.bodyMedium?.copyWith(color: p.onSurfaceVariant),
        helperStyle: base.bodySmall?.copyWith(color: p.onSurfaceVariant),
        errorStyle: base.bodySmall?.copyWith(color: p.error),
        prefixIconColor: p.onSurfaceVariant,
        suffixIconColor: p.onSurfaceVariant,
      ),

      // ── Card: 16 px, hairline, no black shadow ──
      cardTheme: CardThemeData(
        elevation: 0,
        color: p.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: p.outlineVariant),
        ),
      ),

      // ── Divider ──
      dividerTheme: DividerThemeData(
        color: p.outlineVariant,
        thickness: BMJTokens.hairline,
        space: 1,
      ),

      // ── Navigation bar: glass, orange selection ──
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.glassFillStrong,
        surfaceTintColor: Colors.transparent,
        indicatorColor: p.primary.withValues(alpha: 0.18),
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return base.labelSmall?.copyWith(
            color: selected ? p.primaryEmphasis : p.onSurfaceVariant,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? p.primary : p.onSurfaceVariant,
            size: 24,
          );
        }),
      ),

      // ── Snackbar: dark toast on light, light toast on dark ──
      snackBarTheme: SnackBarThemeData(
        backgroundColor:
            p.isDark ? p.surfaceContainerHighest : BMJTokens.darkSurface,
        contentTextStyle: base.bodyMedium?.copyWith(
          color: p.isDark ? BMJTokens.darkOnSurface : BMJTokens.lightSurface,
        ),
        actionTextColor: BMJTokens.orangeSoft,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),

      // ── Chip: 8 px, hairline, label face ──
      chipTheme: ChipThemeData(
        backgroundColor: p.surfaceContainerHigh,
        selectedColor: p.primary.withValues(alpha: 0.16),
        disabledColor: p.surfaceContainerHigh.withValues(alpha: 0.6),
        labelStyle: base.labelMedium?.copyWith(color: p.onSurface),
        secondaryLabelStyle: base.labelMedium?.copyWith(
          color: p.primaryEmphasis,
        ),
        side: BorderSide(color: p.outlineVariant),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ── Sheets: 24 px top radius ──
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surfaceContainer,
        modalBackgroundColor: p.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: BMJTokens.darkSurface.withValues(alpha: 0.55),
        elevation: 0,
        dragHandleColor: p.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(BMJTokens.radiusSheet),
          ),
        ),
      ),

      // ── Dialog ──
      dialogTheme: DialogThemeData(
        backgroundColor: p.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BMJTokens.radiusSheet),
        ),
        titleTextStyle: base.titleMedium?.copyWith(color: p.onSurface),
        contentTextStyle: base.bodyMedium?.copyWith(color: p.onSurfaceVariant),
      ),

      // ── Progress ──
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: p.primary,
        linearTrackColor: p.outlineVariant,
        circularTrackColor: p.outlineVariant,
      ),

      // ── Selection ──
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.primary,
        selectionColor: p.primary.withValues(alpha: 0.24),
        selectionHandleColor: p.primary,
      ),

      // ── Tabs ──
      tabBarTheme: TabBarThemeData(
        labelColor: p.primaryEmphasis,
        unselectedLabelColor: p.onSurfaceVariant,
        indicatorColor: p.primary,
        dividerColor: Colors.transparent,
        labelStyle: base.labelLarge,
        unselectedLabelStyle: base.labelLarge,
      ),
    );
  }
}
