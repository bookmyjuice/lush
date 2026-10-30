/// BMJ design system — the one top glass header.
///
/// Replaces the per-screen `AppBar` with the Stitch header
/// (BMJ_UX_REHAUL_PLAN.md §3). There is exactly **one** header in the system,
/// used by every screen: an orange display-weight centred title (or the
/// "BookMyJuice" wordmark when no title is given), an optional leading back
/// button, and the cart badge on the right. Frosted glass, no per-screen
/// variants.
///
/// [cartAction] replaces the default `CartBadgeIcon`, which is handy in
/// widget tests and on screens without a `CartBloc` in scope.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';
import 'package:lush/widgets/cart_badge_icon.dart';

/// Stitch app header.
class BMJGlassHeader extends StatelessWidget {
  /// Screen title. When `null` the "BookMyJuice" wordmark is shown.
  final String? title;

  /// Optional leading widget — usually a back button.
  final Widget? leading;

  /// Shows the cart badge on the trailing edge.
  final bool showCart;

  /// Replaces the default [CartBadgeIcon].
  final Widget? cartAction;

  /// Forwarded to the default [CartBadgeIcon].
  final VoidCallback? onCartTap;

  /// Frosted background + hairline. Defaults to `true` so the header always
  /// floats above content the way Stitch's `bg-surface/80 backdrop-blur-md`
  /// bar does.
  final bool elevated;

  /// Optional row below the title row (search field, filter chips…).
  final Widget? bottom;

  /// Horizontal padding; 16 keeps the header aligned with page content.
  final EdgeInsetsGeometry padding;

  /// Width reserved on both sides of the centred title so it stays optically
  /// centred whether or not a back button / cart badge is present.
  static const double _actionSlot = 48;

  const BMJGlassHeader({
    super.key,
    this.title,
    this.leading,
    this.showCart = true,
    this.cartAction,
    this.onCartTap,
    this.elevated = true,
    this.bottom,
    this.padding = const EdgeInsets.fromLTRB(
      BMJTokens.pageMargin,
      AppSpacing.xs,
      BMJTokens.pageMargin,
      AppSpacing.xs,
    ),
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final wordmark = title ?? 'BookMyJuice';

    final Widget? trailing =
        showCart ? cartAction ?? CartBadgeIcon(onTap: onCartTap) : cartAction;

    Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: elevated ? palette.glassFill : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: elevated ? palette.glassBorder : Colors.transparent,
            width: BMJTokens.hairline,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              SizedBox(
                width: _actionSlot,
                child: leading == null
                    ? null
                    : Align(alignment: Alignment.centerLeft, child: leading),
              ),
              Expanded(
                child: Semantics(
                  header: true,
                  // `display-md` is 28/34 800: "BookMyJuice" sits in the same
                  // rhythm as Stitch's header, and a longer page title scales
                  // down instead of ellipsising — one header voice, always
                  // fully readable.
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      wordmark,
                      maxLines: 1,
                      softWrap: false,
                      style: BMJType.wordmark.copyWith(
                        color: palette.primaryEmphasis,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: _actionSlot,
                child: trailing == null
                    ? null
                    : Align(alignment: Alignment.centerRight, child: trailing),
              ),
            ],
          ),
          if (bottom != null) ...<Widget>[
            const SizedBox(height: BMJTokens.spaceSm),
            bottom!,
          ],
        ],
      ),
    );

    if (elevated) {
      content = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: BMJTokens.blurGlass,
            sigmaY: BMJTokens.blurGlass,
          ),
          child: content,
        ),
      );
    }

    return SafeArea(bottom: false, child: content);
  }
}
