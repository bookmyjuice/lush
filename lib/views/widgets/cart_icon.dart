import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../bloc/CartBloc/cart_bloc.dart';
import '../../bloc/CartBloc/cart_state.dart';
import '../../theme.dart';

class CartIcon extends StatelessWidget {
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? badgeColor;
  final Color? backgroundColor;
  final double? size;

  const CartIcon({
    super.key,
    this.onTap,
    this.iconColor,
    this.badgeColor,
    this.backgroundColor,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, cartState) {
        int itemCount = 0;
        if (cartState is CartLoaded) {
          itemCount =
              cartState.items.fold(0, (sum, item) => sum + item.quantity);
        }

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: backgroundColor ?? LushTheme.nearlyBlue.withAlpha(20),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Stack(
              children: [
                Icon(
                  Icons.shopping_cart_outlined,
                  size: size ?? 24.sp,
                  color: iconColor ?? LushTheme.nearlyBlue,
                ),
                if (itemCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      constraints: BoxConstraints(minWidth: 16.r),
                      height: 16.r,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: badgeColor ?? Colors.red,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Center(
                        child: Text(
                          itemCount > 99 ? '99+' : itemCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
