import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart' as hex;
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';

import '../../bloc/CartBloc/cart_bloc.dart';
import '../../bloc/CartBloc/cart_event.dart';
import '../../bloc/CartBloc/cart_state.dart';
import '../../theme.dart';
import '../models/cart_item.dart';
import '../widgets/shimmer_cart_item.dart';
import '../../utils/haptic_feedback.dart';

/// Cart Screen - FR-CART-001 to FR-CART-004
/// - FR-CART-001: View cart items with quantity
/// - FR-CART-002: Increment/Decrement quantity
/// - FR-CART-003: Remove items from cart
/// - FR-CART-004: Show subtotal, tax, and total
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // Tax rate (5% GST)
  static const double _taxRate = 0.05;
  // Delivery fee (free above ₹500)
  static const double _deliveryFee = 50.0;
  static const double _freeDeliveryThreshold = 500.0;

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
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.r),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return const ShimmerCartItem();
                    },
                  ),
                ),
                _buildCheckoutSection(context, []),
              ],
            );
          } else if (state is CartLoaded) {
            final items = state.items;
            if (items.isEmpty) {
              return _buildEmptyCart(context);
            }
            return Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context.read<CartBloc>().add(LoadCart());
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.all(16.r),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final cartItem = items[index];
                        return _buildCartItemCard(context, cartItem);
                      },
                    ),
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
    // Calculate totals
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    
    // Tax calculation (5% GST)
    final tax = subtotal * _taxRate;
    
    // Delivery fee (free above ₹500)
    final deliveryFee = subtotal >= _freeDeliveryThreshold ? 0.0 : _deliveryFee;
    
    // Final total
    final total = subtotal + tax + deliveryFee;

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
          // Price Breakdown
          _buildPriceRow(
            context,
            label: 'Subtotal',
            amount: subtotal,
          ),
          SizedBox(height: 8.h),
          _buildPriceRow(
            context,
            label: 'Tax (5% GST)',
            amount: tax,
          ),
          SizedBox(height: 8.h),
          _buildPriceRow(
            context,
            label: 'Delivery Fee',
            amount: deliveryFee,
            isFree: deliveryFee == 0,
          ),
          if (subtotal < _freeDeliveryThreshold)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Text(
                'Add ₹${(_freeDeliveryThreshold - subtotal).toStringAsFixed(0)} more for FREE delivery',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.orange[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          Divider(height: 24.h, color: Colors.grey[300]),
          // Total Amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: LushTheme.darkerText,
                ),
              ),
              Text(
                '₹${total.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF8C42),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Checkout Button
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: items.isNotEmpty
                  ? () async {
                      final userRepository = getIt.get<UserRepository>();
                      final cartItems = items
                          .map((cartItem) => {
                                "itemPriceId": cartItem.selectedPrice?.id ?? '',
                                "quantity": cartItem.quantity,
                              })
                          .toList();
                      try {
                        final checkoutUrl =
                            await userRepository.getCartCheckoutUrl(cartItems);
                        if (checkoutUrl.isNotEmpty) {
                          Navigator.of(context)
                              .pushNamed('/checkout', arguments: checkoutUrl);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to get checkout URL'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Checkout error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF8C42),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Text(
                items.isNotEmpty
                    ? 'Proceed to Checkout'
                    : 'Add items to checkout',
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

  Widget _buildPriceRow(
    BuildContext context, {
    required String label,
    required double amount,
    bool isFree = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: LushTheme.lightText,
          ),
        ),
        isFree
            ? Text(
                'FREE',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              )
            : Text(
                '₹${amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: LushTheme.darkerText,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ],
    );
  }

  void _updateQuantity(BuildContext context, CartItem cartItem, int change) {
    // Add haptic feedback
    HapticFeedbackUtil.lightFeedback();
    
    final newQuantity = cartItem.quantity + change;

    if (newQuantity <= 0) {
      // Remove item if quantity becomes zero
      HapticFeedbackUtil.mediumFeedback();
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
