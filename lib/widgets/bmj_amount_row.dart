/// BMJ design system — money row.
///
/// Every price breakdown in the app (cart summary, checkout, invoice, plan
/// renewal) uses this row so amounts line up in a tabular column and the total
/// is the only 24 px figure on screen (BMJ_UX_REHAUL_PLAN.md §3).
library;

import 'package:flutter/material.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';

/// `label ............ amount` row.
class BMJAmountRow extends StatelessWidget {
  /// Left-hand description.
  final String label;

  /// Right-hand amount, already formatted (e.g. `'₹249'`).
  final String amount;

  /// Optional struck-through pre-discount amount.
  final String? originalAmount;

  /// Small note under the label, e.g. `'Applied: FIRST50'`.
  final String? note;

  /// Renders the row as the grand total: 24 px tabular price, bolder label and
  /// a top divider.
  final bool isTotal;

  /// Colours the amount — lime for savings, error for dues.
  final Color? amountColor;

  /// Replaces [amount] (e.g. a `BMJPill`); [amount] is still read by a11y.
  final Widget? trailing;

  /// Optional leading icon.
  final IconData? icon;

  const BMJAmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.originalAmount,
    this.note,
    this.isTotal = false,
    this.amountColor,
    this.trailing,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);
    final labelStyle = isTotal
        ? AppTextStyles.textTheme.titleSmall?.copyWith(color: palette.onSurface)
        : AppTextStyles.textTheme.bodyMedium?.copyWith(
            color: palette.onSurfaceVariant,
          );
    final amountStyle = (isTotal
            ? BMJType.price
            : (AppTextStyles.textTheme.titleSmall ?? const TextStyle()))
        .copyWith(
      color: palette.onSurface,
      fontFeatures:
          isTotal ? null : const <FontFeature>[FontFeature.tabularFigures()],
    );

    final row = Padding(
      padding: EdgeInsets.symmetric(vertical: isTotal ? AppSpacing.md : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: palette.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(label, style: labelStyle),
                if (note != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      note!,
                      style: AppTextStyles.textTheme.bodySmall?.copyWith(
                        color: palette.onSurfaceVariant,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          if (trailing != null)
            trailing!
          else ...<Widget>[
            if (originalAmount != null) ...<Widget>[
              Text(
                originalAmount!,
                style: AppTextStyles.textTheme.bodySmall?.copyWith(
                  color: palette.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(amount, style: amountStyle.copyWith(color: amountColor)),
          ],
        ],
      ),
    );

    return Semantics(
      label: note == null ? '$label, $amount' : '$label, $amount, $note',
      child: ExcludeSemantics(
        child: isTotal
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Divider(
                    height: BMJTokens.hairline,
                    thickness: BMJTokens.hairline,
                    color: palette.outlineVariant,
                  ),
                  row,
                ],
              )
            : row,
      ),
    );
  }
}
