/// BMJ design system — empty state.
///
/// Used by Cart, Orders, Notifications and Referrals so the "nothing here yet"
/// moment looks identical everywhere (BMJ_UX_REHAUL_PLAN.md §3). Never renders
/// a black shadow: the halo is the brand glow.
library;

import 'package:flutter/material.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// Centred empty / zero-data placeholder.
class BMJEmptyState extends StatelessWidget {
  /// Glyph shown inside the halo.
  final IconData icon;

  /// Short headline, e.g. `'Your cart is empty'`.
  final String title;

  /// One or two lines of guidance.
  final String? message;

  /// Primary recovery action — usually a `BMJGlassButton`.
  final Widget? action;

  /// Tighter vertical rhythm for use inside a sheet or a small pane.
  final bool compact;

  const BMJEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final haloSize = compact ? 64.0 : 88.0;

    return Semantics(
      container: true,
      label: message == null ? title : '$title. $message',
      child: ExcludeSemantics(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: compact ? AppSpacing.lg : AppSpacing.xxl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: haloSize,
                height: haloSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: palette.glassFill,
                  border: Border.all(
                    color: palette.glassBorder,
                    width: BMJTokens.hairline,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: palette.primary.withValues(alpha: 0.18),
                      blurRadius: BMJTokens.glowBlur,
                      spreadRadius: BMJTokens.glowSpread,
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  size: compact ? 28 : 36,
                  color: palette.primaryEmphasis,
                ),
              ),
              SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  color: palette.onSurface,
                ),
              ),
              if (message != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
              ],
              if (action != null) ...<Widget>[
                const SizedBox(height: AppSpacing.lg),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Square icon tile used at the start of list rows.
///
/// Kept next to [BMJEmptyState] because both are "icon on glass" primitives
/// and should share the radius and tint.
class BMJIconTile extends StatelessWidget {
  /// Glyph.
  final IconData icon;

  /// Tile edge length.
  final double size;

  /// Glyph colour; defaults to [BMJPalette.primaryEmphasis].
  final Color? color;

  /// Tile fill; defaults to a 14 % brand tint.
  final Color? background;

  const BMJIconTile({
    super.key,
    required this.icon,
    this.size = 44,
    this.color,
    this.background,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final foreground = color ?? palette.primaryEmphasis;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? palette.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Icon(icon, size: size * 0.5, color: foreground),
    );
  }
}
