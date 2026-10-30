/// BMJ design system — count badge.
///
/// Wraps any icon in a [Stack] and pins a brand-coloured count to its top-right
/// corner (cart, bell). Kept in one place so the cart, notifications and the
/// bottom nav can never drift apart (BMJ_UX_REHAUL_PLAN.md §3).
library;

import 'package:flutter/material.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// Count / dot badge overlaid on [child].
class BMJBadge extends StatelessWidget {
  /// The icon (or any widget) the badge decorates.
  final Widget child;

  /// Number shown in the badge; values above [maxCount] render as `'99+'`.
  final int count;

  /// Renders a 8 px dot without a number — for "unseen" states.
  final bool dot;

  /// Hides the badge when [count] is 0. Defaults to `true`.
  final bool hideWhenZero;

  /// Cap before the label becomes `'99+'`.
  final int maxCount;

  /// Badge fill; defaults to [BMJPalette.primary].
  final Color? color;

  /// Badge text colour; defaults to [BMJPalette.onPrimary].
  final Color? textColor;

  /// Screen-reader description; defaults to `'<count> items'`.
  final String? semanticLabel;

  const BMJBadge({
    super.key,
    required this.child,
    required this.count,
    this.dot = false,
    this.hideWhenZero = true,
    this.maxCount = 99,
    this.color,
    this.textColor,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final visible = dot || count > 0 || !hideWhenZero;

    return Semantics(
      label: visible
          ? semanticLabel ??
              (dot ? 'New activity' : '$count ${count == 1 ? 'item' : 'items'}')
          : null,
      child: ExcludeSemantics(
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            child,
            if (visible)
              Positioned(
                right: -6,
                top: -6,
                child: _BadgeBody(
                  label:
                      dot ? null : (count > maxCount ? '$maxCount+' : '$count'),
                  fill: color ?? palette.primary,
                  foreground: textColor ?? palette.onPrimary,
                  ringColor: palette.surface,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BadgeBody extends StatelessWidget {
  final String? label;
  final Color fill;
  final Color foreground;
  final Color ringColor;

  const _BadgeBody({
    required this.label,
    required this.fill,
    required this.foreground,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDot = label == null;

    return Container(
      constraints: BoxConstraints(
        minWidth: isDot ? 8 : 18,
        minHeight: isDot ? 8 : 18,
      ),
      padding: isDot
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: ringColor,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      child: isDot
          ? null
          : Text(
              label!,
              style: BMJType.badge.copyWith(
                color: foreground,
                fontSize: 10,
                letterSpacing: 0,
              ),
            ),
    );
  }
}

/// Soft "NEW" tag for menu cards.
///
/// Different from [BMJPill]: it is a corner ribbon rather than a status chip,
/// so it stays a separate widget.
class BMJNewTag extends StatelessWidget {
  const BMJNewTag({super.key});

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: palette.accent,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'NEW',
        style: BMJType.badge.copyWith(color: palette.accentText),
      ),
    );
  }
}
