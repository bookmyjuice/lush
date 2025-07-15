import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart' as hex;
import '../../bloc/CartBloc/CartBloc.dart';
import '../../bloc/CartBloc/cartEvent.dart';
import '../../bloc/CartBloc/cartState.dart';
import '../../theme.dart';
import '../models/CartItem.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: LushTheme.darkerText,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: LushTheme.darkerText),
        actions: [
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              if (state is CartLoaded && state.items.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear Cart',
                  onPressed: () {
                    _showClearCartDialog(context);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return _buildEmptyCart(context);
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final cartItem = items[index];
                      return _buildCartItemCard(context, cartItem);
                    },
                  ),
                ),
                _buildCheckoutSection(context, items),
              ],
            );
          } else if (state is CartError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Error loading cart',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<CartBloc>().add(LoadCart());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Try Again'),
                        ),
                        SizedBox(width: 16.w),
                        ElevatedButton(
                          onPressed: () {
                            // Clear cart and try again
                            final cartBloc = context.read<CartBloc>();
                            cartBloc.add(ClearCart());
                            Future.delayed(const Duration(milliseconds: 500),
                                () {
                              cartBloc.add(LoadCart());
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Reset Cart'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80.r,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: LushTheme.darkerText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add some delicious juices to get started',
            style: TextStyle(
              fontSize: 14.sp,
              color: LushTheme.lightText,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/menu');
            },
            icon: const Icon(Icons.local_drink),
            label: const Text('Browse Juices'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem cartItem) {
    final item = cartItem.item;
    final selectedPrice = cartItem.selectedPrice;

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                gradient: item.startColor != null && item.endColor != null
                    ? LinearGradient(
                        colors: [
                          hex.HexColor(item.startColor!),
                          hex.HexColor(item.endColor!),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: item.imagePath != null && item.imagePath!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.asset(
                        item.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.local_drink,
                            size: 40.r,
                            color: Colors.white,
                          );
                        },
                      ),
                    )
                  : Icon(
                      Icons.local_drink,
                      size: 40.r,
                      color: Colors.white,
                    ),
            ),

            SizedBox(width: 16.w),

            // Item details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? item.titleTxt ?? 'Juice',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: LushTheme.darkerText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  if (selectedPrice != null)
                    Text(
                      selectedPrice.name ?? 'Regular',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.orange[700],
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Text(
                    selectedPrice?.description ?? item.description ?? '',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: LushTheme.lightText,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity controls
                      Row(
                        children: [
                          _buildQuantityButton(
                            context,
                            Icons.remove,
                            () => _updateQuantity(context, cartItem, -1),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${cartItem.quantity}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          _buildQuantityButton(
                            context,
                            Icons.add,
                            () => _updateQuantity(context, cartItem, 1),
                          ),
                        ],
                      ),

                      // Price
                      Text(
                        '₹${cartItem.totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: LushTheme.darkerText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Container(
      width: 28.r,
      height: 28.r,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16.r),
        onPressed: onPressed,
        color: LushTheme.darkerText,
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, List<CartItem> items) {
    final totalAmount = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(51),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: LushTheme.darkerText,
                ),
              ),
              Text(
                '₹${totalAmount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: LushTheme.darkerText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to checkout
                Navigator.of(context).pushNamed('/checkout');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuantity(BuildContext context, CartItem cartItem, int change) {
    final newQuantity = cartItem.quantity + change;

    if (newQuantity <= 0) {
      // Remove item if quantity becomes zero
      context.read<CartBloc>().add(RemoveFromCart(cartItem));
    } else {
      // Update quantity
      final updatedItem = cartItem.copyWith(quantity: newQuantity);
      context.read<CartBloc>().add(UpdateCartItem(updatedItem));
    }
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
            'Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<CartBloc>().add(ClearCart());
              Navigator.of(context).pop();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
