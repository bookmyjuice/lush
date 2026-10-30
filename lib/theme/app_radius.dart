/// BookMyJuice Design System Border Radius
///
/// Consistent corner rounding tokens used throughout the app.
library;

/// Design system border radius constants.
class AppRadius {
  AppRadius._();

  /// 8dp — Small radius (chips, snackbars, small elements).
  static const double sm = 8.0;

  /// 12dp — Medium radius (buttons, inputs, cards).
  static const double md = 12.0;

  /// 16dp — Large radius (bottom sheets, large cards).
  static const double lg = 16.0;

  /// 24dp — Extra large radius (glass cards, modals, hero cards).
  static const double xl = 24.0;

  /// 32dp — 2XL radius (bottom nav inner, large containers).
  static const double xxl = 32.0;

  /// 48dp — Circular/pill radius.
  static const double circular = 48.0;

  // ── Stitch `vibrant_zest` semantic aliases (BMJ_UX_REHAUL_PLAN.md §2.3) ──
  // Same numbers as the scale above, named for what they round.
  //
  // `card` is 12 and not 16: every Stitch surface (Home subscription card,
  // product tiles, PDP info card, subscription cards) is `rounded-xl` (12 CSS
  // px), so one number rounds every card in the system. The few Stitch
  // surfaces that really are `rounded-2xl` (the cart's pinned summary block)
  // pass `AppRadius.lg` explicitly.

  /// 8dp — inputs and chips.
  static const double input = sm;

  /// 12dp — cards, product tiles, list tiles and CTAs (`rounded-xl`).
  static const double card = md;

  /// 16dp — sheets, dialogs, pinned summary panels (`rounded-2xl`).
  static const double sheet = lg;

  /// 12dp — the radius every card shares (alias of [card], reads better at
  /// call sites that talk about tiles).
  static const double tile = md;

  /// Fully rounded pill — nav bar, toggles, badges.
  static const double pill = 999.0;
}
