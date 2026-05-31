/// Cart icon with badge count - glassmorphism style.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_state.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';

class CartBadgeIcon extends StatelessWidget {
  final double iconSize;
  final VoidCallback? onTap;

  const CartBadgeIcon({
    super.key,
    this.iconSize = 20,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final itemCount = state is CartLoaded ? state.items.fold<num>(0, (sum, item) => sum + item.quantity).toInt() : 0;
        return GestureDetector(
          onTap: onTap ?? () => Navigator.of(context).pushNamed('/cart'),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.glassSurface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: AppColors.glassBorderSubtle,
                    width: 0.5,
                  ),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  size: iconSize,
                  color: AppColors.glassText,
                ),
              ),
              if (itemCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.glassAccent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.glassAccent.withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Text(
                      '$itemCount',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}