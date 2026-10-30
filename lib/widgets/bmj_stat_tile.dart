/// BMJ design system — numeric stat.
///
/// The building block for the Home macro strip and the PDP nutrition row
/// (BMJ_UX_REHAUL_PLAN.md §3): a tabular, weight-pinned value above a small
/// tracked label. It is deliberately chrome-free — wrap it in a
/// `BMJGlassCard` (or the existing `StatsStrip`) when it needs a surface.
library;

import 'package:flutter/material.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// A single stat: value + label, optional icon and suffix.
class BMJStatTile extends StatelessWidget {
  /// The emphasised number/text, e.g. `'120'`.
  final String value;

  /// Unit or descriptor rendered after [value] in the label colour.
  final String? valueSuffix;

  /// Small tracked caption, e.g. `'CALORIES'`.
  final String label;

  /// Optional leading icon.
  final IconData? icon;

  /// Icon/value colour; defaults to [BMJPalette.primaryEmphasis].
  final Color? accent;

  /// Value override for a denser row.
  final TextStyle? valueStyle;

  /// Label override.
  final TextStyle? labelStyle;

  /// Icon colour; defaults to [accent]. Set separately when the value should read
  /// neutral and the glyph should carry the colour (the reference's Home tiles
  /// draw a coloured icon over a bright, neutral number).
  final Color? iconColor;

  /// Label lines. The reference lets a long delivery/billing value wrap onto a
  /// second line inside its stat box rather than shrinking it.
  final int valueMaxLines;

  /// Text alignment inside the tile.
  final CrossAxisAlignment alignment;

  /// Stacks the glyph above the value instead of inlining it to the left.
  ///
  /// Stitch's Home stat tile is `flex flex-col items-center … justify-center`
  /// (glyph, then `stat-num`, then the caption), while the PDP nutrition row
  /// keeps the glyph inline. Same widget, two arrangements — not two widgets.
  final bool stacked;

  /// Upper-cases [label]. Stitch uppercases the PDP nutrition labels
  /// (`uppercase` on `Calories` / `Vitamin C`) but leaves the Home stat labels
  /// in sentence/title case.
  final bool uppercase;

  const BMJStatTile({
    super.key,
    required this.value,
    required this.label,
    this.valueSuffix,
    this.icon,
    this.accent,
    this.iconColor,
    this.valueStyle,
    this.labelStyle,
    this.alignment = CrossAxisAlignment.start,
    this.valueMaxLines = 1,
    this.stacked = false,
    this.uppercase = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final accentColor = accent ?? palette.primaryEmphasis;
    final glyphColor = iconColor ?? accentColor;
    final TextStyle valueText = valueStyle ?? BMJType.statNum;
    final TextStyle? captionText = labelStyle ??
        AppTextStyles.textTheme.labelSmall?.copyWith(
          color: palette.onSurfaceVariant,
        );

    // Stitch renders the stacked glyph at 20 px (`text-[20px]` symbol) with a
    // 4 dp gap (`mb-1`); the inline nutrition glyph is the 16 px row icon.
    final double iconSize = stacked ? 20 : 16;

    final Widget valueRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (icon != null && !stacked) ...<Widget>[
          Icon(icon, size: iconSize, color: glyphColor),
          const SizedBox(width: AppSpacing.xs),
        ],
        Text(
          value,
          maxLines: valueMaxLines,
          overflow: TextOverflow.ellipsis,
          style: valueText.copyWith(color: accentColor),
        ),
        if (valueSuffix != null) ...<Widget>[
          const SizedBox(width: 2),
          Text(
            valueSuffix!,
            style: AppTextStyles.textTheme.labelSmall?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );

    return Semantics(
      label:
          valueSuffix == null ? '$value $label' : '$value $valueSuffix $label',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: alignment,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (stacked && icon != null) ...<Widget>[
              Icon(icon, size: iconSize, color: glyphColor),
              const SizedBox(height: AppSpacing.xs),
            ],
            valueRow,
            const SizedBox(height: 2),
            Text(
              uppercase ? label.toUpperCase() : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: alignment == CrossAxisAlignment.center
                  ? TextAlign.center
                  : TextAlign.start,
              style: captionText,
            ),
          ],
        ),
      ),
    );
  }
}
