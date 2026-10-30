/// BookMyJuice Design System Typography — Stitch `vibrant_zest`
///
/// Type scale from `BMJ_UX_REHAUL_PLAN.md` §2.2.
///
/// Two families, one theme:
/// - **Plus Jakarta Sans** ([displayFontFamily]) for every display, headline and
///   title slot. [fontFamily] is kept as an alias so the ~64 existing
///   `fontFamily: AppTextStyles.fontFamily` call sites become Plus Jakarta Sans
///   without an edit.
/// - **Inter** ([bodyFontFamily]) for body and label slots — better at 12–16 px
///   than a display face.
///
/// Both families ship as variable TTFs under `assets/fonts/` (declared in
/// `pubspec.yaml`), so nothing is fetched at runtime and every weight renders
/// identically on device and in tests.
library;

import 'package:flutter/material.dart';

/// Factory for the BMJ [TextTheme] following the Stitch type scale.
///
/// | Slot | Size/Line | Weight | Use |
/// |------|-----------|--------|-----|
/// | displayLarge | 40/48 | 800 | desktop display-lg |
/// | displayMedium | 34/42 | 800 | — |
/// | displaySmall | 30/38 | 800 | — |
/// | headlineLarge | 32/40 | 800 | "Good morning, Aarav" |
/// | headlineMedium | 28/34 | 800 | section headers |
/// | headlineSmall | 24/30 | 700 | sheet titles |
/// | titleLarge | 22/28 | 700 | screen titles |
/// | titleMedium | 20/26 | 700 | card titles |
/// | titleSmall | 18/24 | 600 | list titles |
/// | bodyLarge | 16/24 | 400 | paragraphs |
/// | bodyMedium | 14/20 | 400 | body text |
/// | bodySmall | 12/16 | 400 | helper text |
/// | labelLarge | 14/20 | 700 | buttons |
/// | labelMedium | 12/16 | 700 | chips |
/// | labelSmall | 11/14 | 700 | overline / captions |
class AppTextStyles {
  AppTextStyles._();

  /// Display/headline/title family — Stitch display font.
  static const String displayFontFamily = 'Plus Jakarta Sans';

  /// Body/label family.
  static const String bodyFontFamily = 'Inter';

  /// Legacy alias: the family the rest of `lib/` refers to.
  static const String fontFamily = displayFontFamily;

  /// Builds one slot.
  ///
  /// The weight is passed twice on purpose: [TextStyle.fontWeight] is what
  /// Material's own metrics and matching read, while
  /// [TextStyle.fontVariations] pins the `wght` axis of the bundled *variable*
  /// font, so an 800 headline is truly 800 instead of a synthesised bold 400.
  ///
  /// [em] is letter spacing in em (negative tightens display sizes, positive
  /// tracks captions), converted to logical pixels against [size].
  static TextStyle _slot({
    required String family,
    required double size,
    required double line,
    required int weight,
    double em = 0,
    List<FontFeature>? features,
  }) {
    return TextStyle(
      fontFamily: family,
      fontSize: size,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      height: line / size,
      letterSpacing: em == 0 ? null : _round2(size * em),
      fontFeatures: features,
      fontVariations: <FontVariation>[FontVariation('wght', weight.toDouble())],
    );
  }

  /// Display/headline/title slot on [displayFontFamily].
  static TextStyle _display({
    required double size,
    required double line,
    required int weight,
    double em = 0,
  }) =>
      _slot(
        family: displayFontFamily,
        size: size,
        line: line,
        weight: weight,
        em: em,
      );

  /// Body/label slot on [bodyFontFamily].
  static TextStyle _body({
    required double size,
    required double line,
    required int weight,
    double em = 0,
  }) =>
      _slot(
        family: bodyFontFamily,
        size: size,
        line: line,
        weight: weight,
        em: em,
      );

  /// 0.01 px precision — stops float noise from reaching the rasteriser.
  static double _round2(double value) => (value * 100).roundToDouble() / 100;

  /// Creates the complete BMJ [TextTheme].
  ///
  /// Direct [TextStyle.fontFamily] assignment is used rather than
  /// `GoogleFonts.*TextTheme` to avoid async font loading, network access in
  /// tests and extra rebuilds. Every slot Material reads is defined — the old
  /// theme left `bodySmall`, `labelMedium` and `titleSmall` unset, which made
  /// Material fall back to Roboto mid-screen.
  static TextTheme get textTheme => TextTheme(
        displayLarge: _display(size: 40, line: 48, weight: 800, em: -0.02),
        displayMedium: _display(size: 34, line: 42, weight: 800, em: -0.02),
        displaySmall: _display(size: 30, line: 38, weight: 800, em: -0.02),
        headlineLarge: _display(size: 32, line: 40, weight: 800, em: -0.02),
        headlineMedium: _display(size: 28, line: 34, weight: 800, em: -0.02),
        headlineSmall: _display(size: 24, line: 30, weight: 700, em: -0.02),
        titleLarge: _display(size: 22, line: 28, weight: 700, em: -0.02),
        titleMedium: _display(size: 20, line: 26, weight: 700),
        titleSmall: _display(size: 18, line: 24, weight: 600, em: -0.02),
        bodyLarge: _body(size: 16, line: 24, weight: 400),
        bodyMedium: _body(size: 14, line: 20, weight: 400),
        bodySmall: _body(size: 12, line: 16, weight: 400),
        labelLarge: _body(size: 14, line: 20, weight: 700),
        labelMedium: _body(size: 12, line: 16, weight: 700, em: 0.02),
        labelSmall: _body(size: 11, line: 14, weight: 700, em: 0.05),
      );
}

/// Styles Stitch uses that Material's [TextTheme] has no slot for.
///
/// `statNum` and `price` set `tabularFigures` so digits do not dance when a
/// countdown, cart total or macro value changes.
class BMJType {
  BMJType._();

  /// Stitch `stat-num` — 22/26, 800, −0.02 em, tabular.
  ///
  /// Read straight off the reference Tailwind config: every number Stitch
  /// emphasises (Home stat tiles, the plan card's bottle count, cart line
  /// prices) is this one slot. It was 32/36 before the measured pass, which
  /// made a grocery number shout as loud as a page title.
  static final TextStyle statNum = AppTextStyles._slot(
    family: AppTextStyles.displayFontFamily,
    size: 22,
    line: 26,
    weight: 800,
    em: -0.02,
    features: const <FontFeature>[FontFeature.tabularFigures()],
  );

  /// Money — 24 px, 800, tabular (₹ totals, plan price).
  static final TextStyle price = AppTextStyles._slot(
    family: AppTextStyles.displayFontFamily,
    size: 24,
    line: 28,
    weight: 800,
    em: -0.02,
    features: const <FontFeature>[FontFeature.tabularFigures()],
  );

  /// Home greeting name — Stitch renders `font-display-md text-[22px]` (700)
  /// for the customer's name on the greeting block, one step under the
  /// wordmark. (It was 24/30 800 before the visual alignment pass.)
  static final TextStyle heroGreeting = AppTextStyles._slot(
    family: AppTextStyles.displayFontFamily,
    size: 22,
    line: 28,
    weight: 700,
    em: -0.02,
  );

  /// Brand wordmark / page title in the header — Stitch `text-[28px] font-extrabold`
  /// tracked tight (`tracking-[-0.05em]`). Used by [BMJGlassHeader] for both the
  /// "BookMyJuice" wordmark and every page title, so all screens share one
  /// header voice.
  static final TextStyle wordmark = AppTextStyles._slot(
    family: AppTextStyles.displayFontFamily,
    size: 36,
    line: 42,
    weight: 800,
    em: -0.04,
  );

  /// Product-tile name — Stitch `font-title-lg text-[16px] leading-tight`.
  ///
  /// `title-lg` is weight **600** in the reference scale (not 700): at 16 px on
  /// a 173 dp tile, 700 made the name compete with the section header above it.
  static final TextStyle cardTitle = AppTextStyles._slot(
    family: AppTextStyles.displayFontFamily,
    size: 16,
    line: 20,
    weight: 600,
    em: 0.01,
  );

  /// Pill/badge label — 11 px, 700, tracked.
  static final TextStyle badge = AppTextStyles._slot(
    family: AppTextStyles.bodyFontFamily,
    size: 11,
    line: 14,
    weight: 700,
    em: 0.05,
  );
}
