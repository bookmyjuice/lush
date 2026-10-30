/// BMJ design system — the one CTA.
///
/// Stitch `vibrant_zest` defines a single action colour ([BMJTokens.orange])
/// and three weights of it (BMJ_UX_REHAUL_PLAN.md §3):
///
/// | Variant | Fill | Border | Label |
/// | :--- | :--- | :--- | :--- |
/// | [BMJButtonVariant.primary] | `#F97316` + 24 px aura | none | white |
/// | [BMJButtonVariant.ghost] | 8 % orange | 1 px `#F97316` | orange |
/// | [BMJButtonVariant.danger] | 8 % error | 1 px error | error |
///
/// Height is 52 (the plan's floor is 48), and the ripple comes from [Material]
/// so the glow is never a black drop shadow.
library;

import 'package:flutter/material.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// Weight of [BMJGlassButton].
enum BMJButtonVariant {
  /// Solid orange, white label, orange aura — the primary action.
  primary,

  /// Hairline orange outline on glass — secondary actions.
  ghost,

  /// Hairline error outline — destructive confirmation only.
  danger,

  /// Neutral surface with a hairline and ink label — a secondary action that
  /// must not compete with the primary one. The reference draws "Pause" and
  /// "Cancel" this way: quiet blocks, light text, no colour shouting on a card
  /// that already has an orange primary.
  neutral,
}

/// Stitch CTA button.
class BMJGlassButton extends StatelessWidget {
  /// Button text. Always required so a11y labels exist.
  final String label;

  /// `null` renders the disabled state.
  final VoidCallback? onPressed;

  /// Visual weight.
  final BMJButtonVariant variant;

  /// Shows a spinner and blocks taps while work is in flight.
  final bool isLoading;

  /// Optional leading icon.
  final IconData? icon;

  /// Stretch to the parent width (default on mobile CTAs).
  final bool expand;

  /// Height — 52 by default, never below [BMJTokens.minTouchTarget].
  final double height;

  /// Compresses to the Stitch in-card action: 36 dp tall, 8 dp radius, hairline
  /// ghost fill, 14 px label. Used for actions that live *inside* a card
  /// (Home "Manage delivery", subscription "Pause"/"Cancel") where Stitch
  /// renders `h-9 rounded-lg` rather than a page CTA.
  ///
  /// Page-level CTAs stay at 52 dp — the 36 dp variant is only for a button
  /// that is already enclosed by a tappable surface.
  final bool dense;

  /// Overrides the semantics label (defaults to [label]).
  final String? semanticLabel;

  const BMJGlassButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BMJButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.height = 52,
    this.dense = false,
    this.semanticLabel,
  });

  /// Compact inline button (e.g. "See all") that still meets 48 dp.
  const BMJGlassButton.compact({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BMJButtonVariant.ghost,
    this.isLoading = false,
    this.icon,
    this.semanticLabel,
  })  : expand = false,
        height = BMJTokens.minTouchTarget,
        dense = false;

  /// Stitch in-card action — 36 dp tall, 8 dp radius.
  const BMJGlassButton.inCard({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = BMJButtonVariant.ghost,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.semanticLabel,
  })  : height = _inCardHeight,
        dense = true;

  /// Stitch `h-9` — the in-card action height.
  static const double _inCardHeight = 36;

  bool get _enabled => onPressed != null && !isLoading;

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final borderRadius = BorderRadius.circular(
      dense ? AppRadius.sm : AppRadius.card,
    );

    final (Color fill, Color border, Color foreground, bool aura) =
        switch (variant) {
      BMJButtonVariant.primary => (
          _enabled ? palette.primary : palette.outlineVariant,
          Colors.transparent,
          _enabled
              ? palette.onPrimary
              : palette.onSurfaceVariant.withValues(alpha: 0.75),
          _enabled,
        ),
      BMJButtonVariant.ghost => (
          _enabled
              ? palette.primary.withValues(alpha: 0.08)
              : palette.surfaceContainerHigh.withValues(alpha: 0.6),
          _enabled ? palette.primary : palette.outline.withValues(alpha: 0.6),
          _enabled ? palette.primaryEmphasis : palette.onSurfaceVariant,
          false,
        ),
      BMJButtonVariant.danger => (
          _enabled
              ? palette.surfaceContainerHigh
              : palette.surfaceContainerHigh.withValues(alpha: 0.6),
          _enabled
              ? palette.error.withValues(alpha: 0.28)
              : palette.outline.withValues(alpha: 0.6),
          _enabled ? palette.error : palette.onSurfaceVariant,
          false,
        ),
      BMJButtonVariant.neutral => (
          palette.surfaceContainerHigh,
          palette.outlineVariant,
          _enabled ? palette.onSurface : palette.onSurfaceVariant,
          false,
        ),
    };

    final labelStyle =
        AppTextStyles.textTheme.labelLarge?.copyWith(color: foreground);

    final row = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          )
        else if (icon != null)
          Icon(icon, size: dense ? 16 : 20, color: foreground),
        if (isLoading || icon != null)
          SizedBox(width: dense ? AppSpacing.xs + 2 : BMJTokens.spaceSm),
        // Flexible so a long label ellipsises instead of overflowing the Row
        // on narrow phones (the Text already sets maxLines/ellipsis).
        Flexible(
          child: Text(
            label,
            style: labelStyle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: semanticLabel ?? label,
      child: ExcludeSemantics(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: aura
                ? <BoxShadow>[
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.45),
                      blurRadius: 28,
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: fill,
            shape: RoundedRectangleBorder(
              borderRadius: borderRadius,
              side: BorderSide(
                color: border,
                width: border == Colors.transparent ? 0 : BMJTokens.hairline,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _enabled ? onPressed : null,
              splashColor: foreground.withValues(alpha: 0.12),
              child: Container(
                // Page CTAs keep the 48 dp floor. The in-card action is the one
                // documented exception: Stitch renders it at `h-9` (36 dp)
                // inside an already-tappable card, so shrinking it is what the
                // reference actually does.
                height: dense
                    ? height
                    : (height < BMJTokens.minTouchTarget
                        ? BMJTokens.minTouchTarget
                        : height),
                padding: EdgeInsets.symmetric(
                  horizontal: dense ? AppSpacing.sm + 4 : BMJTokens.spaceMd,
                  vertical: dense ? 0 : BMJTokens.spaceSm,
                ),
                alignment: Alignment.center,
                child: row,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
