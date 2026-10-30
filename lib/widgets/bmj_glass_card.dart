/// BMJ design system — glass surface.
///
/// The single card primitive for the Stitch `vibrant_zest` system
/// (BMJ_UX_REHAUL_PLAN.md §3). It is a thin composition over the values the
/// theme already owns, so a token change restyles every card at once.
///
/// Defaults (plan §2.3 / §3):
/// - blur 16, 8 px card padding is *not* baked in — pass the padding the screen
///   needs, the default matches the page rhythm (16);
/// - radius 12, 1 px hairline from [BMJPalette.glassBorder];
/// - fill from [BMJPalette.glassFill] (72 % white on the light surface,
///   8 % white on dark) so the same widget is correct in both themes;
/// - [glow] draws the orange aura `rgba(249,115,22,0.45)`. A black drop shadow
///   is never used — that is the whole point of the glass system.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// A frosted card with an optional orange aura and an optional ripple.
class BMJGlassCard extends StatelessWidget {
  /// Card content.
  final Widget child;

  /// Inner padding. Set to [EdgeInsets.zero] for edge-to-edge media.
  final EdgeInsetsGeometry padding;

  /// Outer margin, handy inside a `ListView`.
  final EdgeInsetsGeometry? margin;

  /// Corner radius — 12 by default ([AppRadius.card]).
  final double radius;

  /// Backdrop blur sigma. Pass 0 to skip the [BackdropFilter] entirely (cheap
  /// cards on long lists).
  final double blur;

  /// Draws the Stitch aura. Never a black shadow.
  final bool glow;

  /// Overrides the aura colour; defaults to [BMJTokens.glow].
  final Color? glowColor;

  /// Fill override — e.g. a lime-tinted "savings" card.
  final Color? color;

  /// Hairline override.
  final Color? borderColor;

  /// Tap handler. Adds an ink ripple and `button` semantics.
  final VoidCallback? onTap;

  /// Accessibility label for the whole card when [onTap] is set.
  final String? semanticLabel;

  final double? width;
  final double? height;

  /// Clips content that should not paint over the rounded corners.
  final bool clipContent;

  const BMJGlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(BMJTokens.spaceMd),
    this.margin,
    this.radius = AppRadius.card,
    this.blur = BMJTokens.blurGlass,
    this.glow = false,
    this.glowColor,
    this.color,
    this.borderColor,
    this.onTap,
    this.semanticLabel,
    this.width,
    this.height,
    this.clipContent = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final borderRadius = BorderRadius.circular(radius);

    final shadows = glow
        ? <BoxShadow>[
            BoxShadow(
              color: glowColor ?? BMJTokens.glow,
              blurRadius: BMJTokens.glowBlur,
              spreadRadius: BMJTokens.glowSpread,
            ),
          ]
        : null;

    Widget surface = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? palette.glassFill,
        borderRadius: borderRadius,
        border: Border.all(
          color: borderColor ?? palette.glassBorder,
          width: BMJTokens.hairline,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );

    if (blur > 0) {
      surface = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: surface,
      );
    }

    if (clipContent) {
      surface = ClipRRect(borderRadius: borderRadius, child: surface);
    }

    Widget card = DecoratedBox(
      decoration: BoxDecoration(borderRadius: borderRadius, boxShadow: shadows),
      child: surface,
    );

    if (onTap != null) {
      card = Semantics(
        button: true,
        label: semanticLabel,
        child: Stack(
          children: <Widget>[
            card,
            // The ripple is painted by this transparent Material, which sits
            // above the card fill so the splash stays visible on glass.
            Positioned.fill(
              child: Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: borderRadius,
                  splashColor: palette.primary.withValues(alpha: 0.12),
                  highlightColor: palette.primary.withValues(alpha: 0.06),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return margin == null ? card : Container(margin: margin, child: card);
  }
}
