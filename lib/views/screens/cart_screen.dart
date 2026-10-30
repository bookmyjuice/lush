import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hexcolor/hexcolor.dart' as hex;
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';
import 'package:lush/utils/price_utils.dart';
import 'package:lush/widgets/bmj_amount_row.dart';
import 'package:lush/widgets/bmj_empty_state.dart';
import 'package:lush/widgets/bmj_glass_button.dart';
import 'package:lush/widgets/bmj_glass_card.dart';
import 'package:lush/widgets/bmj_glass_header.dart';
import 'package:lush/widgets/bmj_pill.dart';
import '../../bloc/CartBloc/cart_bloc.dart';

import '../../bloc/CartBloc/cart_event.dart';
import '../../bloc/CartBloc/cart_state.dart';
import '../models/cart_item.dart';
import '../widgets/shimmer_cart_item.dart';
import '../../utils/haptic_feedback.dart';

/// Cart Screen - FR-CART-001 to FR-CART-004
/// - FR-CART-001: View cart items with quantity
/// - FR-CART-002: Increment/Decrement quantity
/// - FR-CART-003: Remove items from cart
/// - FR-CART-004: Show subtotal
/// - FR-DEL-008: Delivery address selection before checkout
/// Pricing (tax, grand total) is managed entirely in Chargebee.
/// The mobile app never calculates prices locally.
/// Delivery slot selection uses time-window based scheduling.
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  // Delivery selection state
  Map<String, dynamic>? _selectedAddress;

  @override
  void initState() {
    super.initState();
    _loadDefaultAddress();
  }

  Future<void> _loadDefaultAddress() async {
    try {
      final userRepo = getIt.get<UserRepository>();
      final result = await userRepo.getUserAddresses();
      if (result['status'] == 'success') {
        final data = result['data'];
        if (data is List && data.isNotEmpty) {
          // Find the default address, fall back to first address
          final defaultAddr = data.cast<Map<String, dynamic>>().firstWhere(
                (addr) => addr['default'] == true || addr['isDefault'] == true,
                orElse: () => data.first as Map<String, dynamic>,
              );
          if (mounted) {
            setState(() {
              _selectedAddress = defaultAddr;
            });
          }
        }
      }
    } catch (e) {
      // Silently fail - user can still manually select address
    }
  }

  Future<void> _navigateToAddressSelection() async {
    final result = await Navigator.pushNamed(
      context,
      '/address-selection',
    );
    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _selectedAddress = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);

    return Scaffold(
      backgroundColor: palette.surface,
      body: Column(
        children: <Widget>[
          BMJGlassHeader(
            title: 'Your Cart',
            leading: Semantics(
              button: true,
              label: 'Back',
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: palette.onSurface,
                tooltip: 'Back',
              ),
            ),
          ),
          Expanded(child: _buildBody(context)),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
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
                    await Future<void>.delayed(
                      const Duration(milliseconds: 500),
                    );
                  },
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      BMJTokens.pageMargin,
                      BMJTokens.spaceSm,
                      BMJTokens.pageMargin,
                      BMJTokens.spaceMd,
                    ),
                    children: <Widget>[
                      _buildItemsHeader(context, items),
                      const SizedBox(height: AppSpacing.sm),
                      for (final CartItem cartItem in items)
                        _buildCartItemCard(context, cartItem),
                    ],
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
                    color: AppColors.error,
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
                          backgroundColor: AppColors.info,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text('Try Again'),
                      ),
                      SizedBox(width: 16.w),
                      ElevatedButton(
                        onPressed: () {
                          final cartBloc = context.read<CartBloc>();
                          cartBloc.add(ClearCart());
                          Future<void>.delayed(
                              const Duration(milliseconds: 500), () {
                            cartBloc.add(LoadCart());
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: AppColors.white,
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
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: BMJEmptyState(
        icon: Icons.shopping_cart_outlined,
        title: 'Your cart is empty',
        message: 'Add some cold-pressed juices to get started.',
        action: BMJGlassButton(
          label: 'Browse juices',
          expand: false,
          icon: Icons.local_drink,
          onPressed: () => Navigator.of(context).pushReplacementNamed('/menu'),
        ),
      ),
    );
  }

  /// Stitch "Items (n)" header; clear-all remains available from here.
  Widget _buildItemsHeader(BuildContext context, List<CartItem> items) {
    final palette = BMJPalette.of(context);

    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            'Items (${items.length})',
            // Stitch section header is `font-headline-md` — 20/26, 700.
            style: AppTextStyles.textTheme.titleMedium?.copyWith(
              color: palette.onSurface,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: () => _showClearCartDialog(context),
          icon: Icon(
            Icons.delete_outline,
            size: 18,
            color: palette.onSurfaceVariant,
          ),
          label: Text(
            'Clear',
            style: AppTextStyles.textTheme.labelLarge?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xs,
            ),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildCartItemCard(BuildContext context, CartItem cartItem) {
    final palette = BMJPalette.of(context);
    final item = cartItem.item;
    final selectedPrice = cartItem.selectedPrice;

    final Gradient? gradient = item.startColor != null && item.endColor != null
        ? LinearGradient(
            colors: [
              hex.HexColor(item.startColor!),
              hex.HexColor(item.endColor!),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    return BMJGlassCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      padding: const EdgeInsets.all(AppSpacing.sm + 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: item.imagePath != null && item.imagePath!.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    child: Image.asset(
                      item.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.local_drink,
                        size: 32,
                        color: palette.onPrimary,
                      ),
                    ),
                  )
                : Icon(
                    Icons.local_drink,
                    size: 32,
                    color: palette.onPrimary,
                  ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        item.name ?? item.titleTxt ?? 'Juice',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        // The item name carries the row, the way the reference
                        // draws it — a small caption next to a big photo left the
                        // card looking like a receipt line.
                        style: AppTextStyles.textTheme.titleMedium?.copyWith(
                          color: palette.onSurface,
                        ),
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: 'Remove ${item.name ?? 'item'} from the cart',
                      child: InkWell(
                        onTap: () {
                          HapticFeedbackUtil.mediumFeedback();
                          context
                              .read<CartBloc>()
                              .add(RemoveFromCart(cartItem));
                        },
                        customBorder: const CircleBorder(),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: palette.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (selectedPrice != null) ...<Widget>[
                  BMJPill(
                    label: selectedPrice.name ?? 'Regular',
                    tone: BMJPillTone.neutral,
                    dense: true,
                  ),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(
                  selectedPrice?.description ?? item.description ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: <Widget>[
                    Text(
                      formatRupees(cartItem.totalPrice),
                      // Price bottom-left, stepper bottom-right: the reference's
                      // row silhouette, and the biggest number in the card.
                      style: BMJType.statNum.copyWith(
                        fontSize: 28,
                        height: 1.1,
                        color: palette.primaryEmphasis,
                      ),
                    ),
                    const Spacer(),
                    _buildQuantityStepper(context, cartItem),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Stitch "- n +" pill.
  Widget _buildQuantityStepper(BuildContext context, CartItem cartItem) {
    final palette = BMJPalette.of(context);

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: palette.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildQuantityButton(
            context,
            Icons.remove_rounded,
            'Decrease quantity',
            () => _updateQuantity(context, cartItem, -1),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${cartItem.quantity}',
              textAlign: TextAlign.center,
              style: AppTextStyles.textTheme.titleSmall?.copyWith(
                color: palette.onSurface,
              ),
            ),
          ),
          _buildQuantityButton(
            context,
            Icons.add_rounded,
            'Increase quantity',
            () => _updateQuantity(context, cartItem, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton(
    BuildContext context,
    IconData icon,
    String semanticLabel,
    VoidCallback onPressed,
  ) {
    final palette = BMJPalette.of(context);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 32,
            height: 32,
            child: Icon(icon, size: 16, color: palette.onSurface),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckoutSection(BuildContext context, List<CartItem> items) {
    final palette = BMJPalette.of(context);

    // Subtotal reflects locally-cached Chargebee price data. Final pricing
    // (tax, delivery, grand total) is calculated by Chargebee and shown on the
    // Hosted Page — the app never invents those numbers.
    final double subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final int bottleCount = items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.surface,
        border: Border(
          top: BorderSide(color: palette.glassBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            BMJTokens.pageMargin,
            BMJTokens.spaceSm,
            BMJTokens.pageMargin,
            BMJTokens.spaceMd,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Delivery address (FR-DEL-008)
              BMJGlassCard(
                onTap: _navigateToAddressSelection,
                semanticLabel: 'Change delivery address',
                child: Row(
                  children: [
                    Icon(
                      _selectedAddress != null
                          ? Icons.check_circle
                          : Icons.location_on_outlined,
                      size: 20,
                      color: _selectedAddress != null
                          ? palette.accentText
                          : palette.primary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedAddress != null
                                ? 'Deliver to: ${_selectedAddress!['addressLine1'] ?? ''}'
                                : 'Select delivery address',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.textTheme.titleSmall?.copyWith(
                              color: palette.onSurface,
                            ),
                          ),
                          if (_selectedAddress != null)
                            Text(
                              '${_selectedAddress!['city'] ?? ''}, ${_selectedAddress!['state'] ?? ''} - ${_selectedAddress!['pincode'] ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.textTheme.bodySmall
                                  ?.copyWith(color: palette.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: palette.onSurfaceVariant),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              // Stitch "Order Summary": only the locally-known subtotal is a
              // number; tax/delivery/total stay "At checkout" because Chargebee
              // is the single source of truth for them. Stitch docks this block
              // as a `rounded-2xl` panel, so it takes the one sheet radius.
              BMJGlassCard(
                radius: AppRadius.sheet,
                // Stitch docks the summary as a `rounded-2xl p-lg` panel: 24 dp
                // of padding, one step above the 16 dp cards around it, which is
                // what makes the totals block feel like the page's conclusion.
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Order Summary',
                      // Stitch section header is `font-headline-md` — 20/26, 700.
                      style: AppTextStyles.textTheme.titleMedium?.copyWith(
                        color: palette.onSurface,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    BMJAmountRow(
                      label: 'Subtotal',
                      amount: formatRupees(subtotal),
                      note:
                          '$bottleCount ${bottleCount == 1 ? 'bottle' : 'bottles'}',
                    ),
                    const BMJAmountRow(
                      label: 'Taxes & delivery',
                      amount: 'At checkout',
                      note: 'Calculated securely by Chargebee',
                    ),
                    // Structure without a number: savings are computed by Chargebee
                    // on the hosted checkout, so the row exists with the
                    // unknown-value marker rather than an invented amount. The
                    // reference's green savings row is reproduced; only its figure
                    // is honestly absent.
                    BMJAmountRow(
                      label: 'Subscription savings',
                      amount: kPriceFallback,
                      note: 'Applied on the Chargebee checkout',
                      icon: Icons.eco_outlined,
                      amountColor: palette.accentText,
                    ),
                    // The panel has to end on its loudest element, the way the
                    // reference ends on a big orange total. We hold no final figure
                    // (Chargebee owns it), so the closing row takes the emphasis
                    // instead of trailing off in grey words.
                    BMJAmountRow(
                      label: 'Total',
                      amount: 'At checkout',
                      isTotal: true,
                      amountColor: palette.primaryEmphasis,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.local_offer_outlined,
                          size: 16,
                          color: palette.onSurfaceVariant,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Promo codes and final taxes are applied on the '
                            'secure Chargebee checkout.',
                            style: AppTextStyles.textTheme.bodySmall?.copyWith(
                              color: palette.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              BMJGlassButton(
                label: items.isNotEmpty
                    ? 'Proceed to checkout'
                    : 'Add items to checkout',
                icon: Icons.arrow_forward_rounded,
                onPressed:
                    items.isEmpty ? null : () => _startCheckout(context, items),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Creates the Chargebee cart checkout session.
  ///
  /// Payload and error handling are unchanged on purpose: `price_id` comes from
  /// the selected `ItemPrice` and a 409 `CART_TYPE_CONFLICT` still asks the
  /// customer to split subscription and one-time items.
  Future<void> _startCheckout(
    BuildContext context,
    List<CartItem> items,
  ) async {
    if (_selectedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a delivery address')),
      );
      return;
    }

    final userRepository = getIt.get<UserRepository>();
    final cartItems = items
        .map(
          (cartItem) => {
            'price_id': cartItem.selectedPrice?.id ?? '',
            'quantity': cartItem.quantity,
          },
        )
        .toList();
    try {
      final checkoutUrl = await userRepository.getCartCheckoutUrl(cartItems);
      if (!mounted) return;
      if (checkoutUrl.isNotEmpty) {
        Navigator.of(context).pushNamed('/checkout', arguments: checkoutUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get checkout URL')),
        );
      }
    } catch (e) {
      final errorMsg = e.toString();
      if (errorMsg.contains('409') || errorMsg.contains('CART_TYPE_CONFLICT')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Mixed cart items detected. '
              'Please checkout subscription and one-time items separately.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout error: $e')),
        );
      }
    }
  }

  void _updateQuantity(BuildContext context, CartItem cartItem, int change) {
    HapticFeedbackUtil.lightFeedback();

    final newQuantity = cartItem.quantity + change;

    if (newQuantity <= 0) {
      HapticFeedbackUtil.mediumFeedback();
      context.read<CartBloc>().add(RemoveFromCart(cartItem));
    } else {
      final updatedItem = cartItem.copyWith(quantity: newQuantity);
      context.read<CartBloc>().add(UpdateCartItem(updatedItem));
    }
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog<bool?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
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
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
