/// Shared product size picker.
///
/// One implementation for the Menu grid, Home quick-add and the PDP: a
/// [BMJGlassSheet] listing the *real* catalog prices for a [CatalogItem], with
/// the cheapest option preselected. Unpriced options are shown but cannot be
/// chosen, so a cart line always carries a price the backend can bill.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart'
    hide AddToCart;
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';
import 'package:lush/utils/price_utils.dart';
import 'package:lush/views/models/cart_item.dart';
import 'package:lush/views/models/item.dart';
import 'package:lush/widgets/bmj_glass_button.dart';
import 'package:lush/widgets/bmj_glass_sheet.dart';
import 'package:lush/widgets/bmj_pill.dart';

/// Opens the shared size picker for [item].
///
/// Returns once the sheet is dismissed. Adding to the cart is handled inside
/// the sheet (same `AddToCart` event the screens used before).
Future<void> showSizeSelectionSheet(BuildContext context, CatalogItem item) {
  return BMJGlassSheet.show<void>(
    context: context,
    title: 'Choose a size',
    builder: (sheetContext) => SizeSelectionSheet(item: item),
  );
}

/// Size list + "Add to cart" footer for one catalog item.
class SizeSelectionSheet extends StatefulWidget {
  /// The catalog item whose [CatalogItem.prices] are offered.
  final CatalogItem item;

  /// Preselects this option instead of the cheapest one.
  final ItemPrice? initialPrice;

  const SizeSelectionSheet({super.key, required this.item, this.initialPrice});

  @override
  State<SizeSelectionSheet> createState() => _SizeSelectionSheetState();
}

class _SizeSelectionSheetState extends State<SizeSelectionSheet> {
  ItemPrice? _selected;

  @override
  void initState() {
    super.initState();
    final List<ItemPrice> prices = widget.item.prices;
    if (widget.initialPrice != null && prices.contains(widget.initialPrice)) {
      _selected = widget.initialPrice;
    } else {
      _selected = cheapestPricedOption(prices);
    }
  }

  bool _isPriced(ItemPrice price) {
    final double? value = price.price;
    return value != null && value > 0;
  }

  void _addToCart() {
    final ItemPrice? selected = _selected;
    if (selected == null) return;

    context.read<CartBloc>().add(
          AddToCart(
            CartItem(item: widget.item.item, selectedPrice: selected),
          ),
        );

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          '${widget.item.name} (${selected.name ?? selected.id}) added to cart',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);
    final List<ItemPrice> prices = widget.item.prices;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          widget.item.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTextStyles.textTheme.headlineSmall?.copyWith(
            color: palette.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${widget.item.category} · ${widget.item.calories} cal',
          style: AppTextStyles.textTheme.bodySmall?.copyWith(
            color: palette.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (prices.isEmpty)
          Text(
            'No sizes are configured for this juice yet.',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          )
        else
          ...prices.map((ItemPrice price) => _option(palette, price)),
        const SizedBox(height: AppSpacing.md),
        BMJGlassButton(
          label: _selected == null
              ? 'Add to cart'
              : 'Add to cart · ${formatRupees(_selected!.price)}',
          icon: Icons.add_shopping_cart,
          onPressed: _selected == null ? null : _addToCart,
        ),
      ],
    );
  }

  Widget _option(BMJPalette palette, ItemPrice price) {
    final bool priced = _isPriced(price);
    final bool isSelected = _selected?.id == price.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Semantics(
        button: priced,
        selected: isSelected,
        label: '${price.name ?? 'Size'}, ${formatRupees(price.price)}',
        child: ExcludeSemantics(
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: priced ? () => setState(() => _selected = price) : null,
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm + 2,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? palette.primary.withValues(alpha: 0.10)
                      : palette.glassFill,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected
                        ? palette.primary.withValues(alpha: 0.45)
                        : palette.glassBorder,
                  ),
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        price.name ?? 'Standard',
                        style: AppTextStyles.textTheme.titleSmall?.copyWith(
                          color:
                              priced ? palette.onSurface : palette.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isSelected)
                      const Padding(
                        padding: EdgeInsets.only(right: AppSpacing.sm),
                        child: BMJPill(
                          label: 'Selected',
                          dense: true,
                        ),
                      ),
                    Text(
                      formatRupees(price.price),
                      style: AppTextStyles.textTheme.titleMedium?.copyWith(
                        color: isSelected
                            ? palette.primaryEmphasis
                            : palette.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
