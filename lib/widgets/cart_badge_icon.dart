/// Cart icon with badge count - a bare accent glyph, the way the reference draws
/// it (no chip, no fill, no border).
///
/// Thin composition: [BMJBadge] owns the count bubble, the design system owns
/// the colours, and this widget only knows about the cart BLoC.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_state.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/bmj_tokens.dart';
import 'package:lush/widgets/bmj_badge.dart';

class CartBadgeIcon extends StatelessWidget {
  final double iconSize;
  final VoidCallback? onTap;

  const CartBadgeIcon({
    super.key,
    this.iconSize = 26,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final palette = BMJPalette.of(context);

    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final itemCount = state is CartLoaded
            ? state.items
                .fold<num>(0, (sum, item) => sum + item.quantity)
                .toInt()
            : 0;

        return Semantics(
          button: true,
          label: 'Cart, $itemCount ${itemCount == 1 ? 'item' : 'items'}',
          child: ExcludeSemantics(
            child: BMJBadge(
              count: itemCount,
              child: GestureDetector(
                onTap: onTap ?? () => Navigator.of(context).pushNamed('/cart'),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  constraints:
                      const BoxConstraints(minWidth: 40, minHeight: 40),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: Colors.transparent,
                      width: BMJTokens.hairline,
                    ),
                  ),
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: iconSize,
                    color: palette.primaryEmphasis,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
