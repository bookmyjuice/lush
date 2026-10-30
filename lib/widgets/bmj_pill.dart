/// BMJ design system — status pill.
///
/// The pill is the only place the design system allows a tinted chip
/// (BMJ_UX_REHAUL_PLAN.md §3): 12 % fill, 32 % hairline, 11 px tracked label,
/// fully rounded. Status colours come from the palette, never from hard-coded
/// hex, so both themes stay readable.
library;

import 'package:flutter/material.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// Semantic tone of a [BMJPill].
enum BMJPillTone {
  /// Brand/orange — "Subscriber", "Popular".
  primary,

  /// Lime — "Delivered", "Saved ₹120".
  success,

  /// Teal — "Scheduled", informational notes.
  info,

  /// Neutral outline — "Pending", counts.
  neutral,

  /// Error — "Cancelled", "Payment failed".
  danger,
}

/// Small status chip.
class BMJPill extends StatelessWidget {
  /// Text inside the pill.
  final String label;

  /// Semantic colour.
  final BMJPillTone tone;

  /// Optional leading icon (kept at 12 px).
  final IconData? icon;

  /// Slightly tighter padding for dense lists.
  final bool dense;

  /// Optional tap handler; when set the pill becomes a button.
  final VoidCallback? onTap;

  const BMJPill({
    super.key,
    required this.label,
    this.tone = BMJPillTone.primary,
    this.icon,
    this.dense = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);

    final (Color fill, Color border, Color text) = switch (tone) {
      BMJPillTone.primary => (
          palette.primary,
          palette.primary,
          palette.primaryEmphasis,
        ),
      BMJPillTone.success => (
          palette.accent,
          palette.accent,
          palette.accentText,
        ),
      BMJPillTone.info => (
          BMJTokens.tertiary,
          BMJTokens.tertiary,
          palette.onSurface,
        ),
      BMJPillTone.neutral => (
          palette.onSurfaceVariant,
          palette.onSurfaceVariant,
          palette.onSurfaceVariant,
        ),
      BMJPillTone.danger => (palette.error, palette.error, palette.error),
    };

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null) ...<Widget>[
          Icon(icon, size: 12, color: text),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BMJType.badge.copyWith(color: text),
        ),
      ],
    );

    final body = Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? AppSpacing.sm : 10,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: fill.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: border.withValues(alpha: 0.32),
          width: BMJTokens.hairline,
        ),
      ),
      child: content,
    );

    if (onTap == null) {
      return Semantics(label: label, child: body);
    }

    return Semantics(
      button: true,
      label: label,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: body,
        ),
      ),
    );
  }
}
