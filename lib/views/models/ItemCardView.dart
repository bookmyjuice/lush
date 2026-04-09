import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart' as hex;
import '../../theme.dart';
import '../../bloc/CartBloc/CartBloc.dart';
import '../../bloc/CartBloc/cartEvent.dart';
import '../widgets/size_selection_modal.dart';
import '../models/Item.dart';
import '../models/CartItem.dart';

class ItemCardView extends StatelessWidget {
  final Item item;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const ItemCardView({
    super.key,
    required this.item,
    this.animationController,
    this.animation,
  });

  void _addToCart(BuildContext context) {
    try {
      // Convert to cart-compatible item with prices
      final cartItem = createCartCompatibleItem();

      print('Opening size selection modal for ${item.name ?? item.titleTxt}');
      print('Item has ${cartItem.itemPrices?.length ?? 0} price options');

      if (cartItem.itemPrices == null || cartItem.itemPrices!.isEmpty) {
        // If no prices are available, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No size/price options available for ${cartItem.name ?? 'this item'}',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SizeSelectionModal(
          item: cartItem,
          onPriceSelected: (selectedPrice) {
            try {
              print(
                  'Selected price: ${selectedPrice.name} - ₹${selectedPrice.price}');

              // Add to cart with the selected price
              context.read<CartBloc>().add(
                    AddToCart(
                      CartItem(
                        item: cartItem,
                        selectedPrice: selectedPrice,
                        quantity: 1,
                      ),
                    ),
                  );

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      '${item.name ?? item.titleTxt} (${selectedPrice.name}) added to cart!'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: hex.HexColor(item.endColor ?? '#FF9800'),
                  action: SnackBarAction(
                    label: 'VIEW CART',
                    textColor: Colors.white,
                    onPressed: () {
                      // Use a delayed future to ensure we're not using a disposed context
                      Future.delayed(Duration.zero, () {
                        // Get the navigator from the current context
                        final navigator = Navigator.of(
                          ScaffoldMessenger.of(context).context,
                          rootNavigator: true,
                        );
                        navigator.pushNamed('/cart');
                      });
                    },
                  ),
                ),
              );
            } catch (e) {
              print('Error adding item to cart: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Error adding item to cart: $e',
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        ),
      );
    } catch (e) {
      print('Error opening size selection modal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error selecting size: $e',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // Create a cart-compatible item with item prices
  Item createCartCompatibleItem() {
    // If item already has prices, use them
    if (item.itemPrices != null && item.itemPrices!.isNotEmpty) {
      return item;
    }

    // Otherwise, create default item prices for different sizes
    final basePrice = item.price ?? 9.99;
    final itemPrices = [
      ItemPrice(
        id: '${item.id}_small',
        name: 'Small (100ml)',
        description: 'Perfect for a quick refreshment',
        price: basePrice,
        currencyCode: 'INR',
      ),
      ItemPrice(
        id: '${item.id}_medium',
        name: 'Medium (250ml)',
        description: 'Our most popular size',
        price: basePrice * 2,
        currencyCode: 'INR',
      ),
      ItemPrice(
        id: '${item.id}_large',
        name: 'Large (500ml)',
        description: 'Great value for sharing',
        price: basePrice * 3.5,
        currencyCode: 'INR',
      ),
    ];

    // Create a new Item with all the properties
    return Item(
      id: item.id,
      name: item.name ?? item.titleTxt,
      description: item.description ?? 'Fresh ${item.name ?? item.titleTxt}',
      metaData: item.metaData ??
          {
            'startColor': item.startColor,
            'endColor': item.endColor,
            'calories': (item.kacl ?? 0).toString(),
          },
      servingSize: item.servingSize,
      imagePath: item.imagePath,
      titleTxt: item.titleTxt,
      startColor: item.startColor,
      endColor: item.endColor,
      meals: item.meals,
      kacl: item.kacl,
      price: item.price,
      rating: item.rating,
      itemPrices: itemPrices,
      type: item.type ?? 'CHARGE', // One-time purchase
      status: item.status ?? 'ACTIVE',
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Responsive width calculation
                final double cardWidth = constraints.maxWidth;
                final double cardHeight = constraints.maxHeight;

                return Container(
                  width: cardWidth,
                  height: cardHeight,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
                  child: Stack(
                    clipBehavior: Clip.none, // Allow image to overflow
                    children: <Widget>[
                      // Card background
                      Padding(
                        padding: const EdgeInsets.only(
                            top: 33, left: 1, right: 1, bottom: 1),
                        child: Container(
                          decoration: BoxDecoration(
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: hex.HexColor(item.endColor ?? '#FF9800')
                                    .withOpacity(0.4),
                                offset: const Offset(1.0, 3.0),
                                blurRadius: 6.0,
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: <Color>[
                                hex.HexColor(item.startColor ?? '#FFCC80'),
                                hex.HexColor(item.endColor ?? '#FF9800'),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomRight: Radius.circular(12.0),
                              bottomLeft: Radius.circular(12.0),
                              topLeft: Radius.circular(12.0),
                              topRight: Radius.circular(60.0),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                top: 44, left: 8, right: 8, bottom: 8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                // Item name with ellipsis for overflow
                                Text(
                                  item.name ?? item.titleTxt ?? 'Item',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: LushTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 0.2,
                                    color: LushTheme.white,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                // Item type badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "Size: ${item.servingSize}",
                                    style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 4),

                                // Calories info (if available)
                                // if (item.kacl != null)
                                //   Text(
                                //     'Calories: ${item.kacl ?? 0}',
                                //     style: const TextStyle(
                                //       fontFamily: LushTheme.fontName,
                                //       fontWeight: FontWeight.w500,
                                //       fontSize: 10,
                                //       letterSpacing: 0.2,
                                //       color: LushTheme.white,
                                //     ),
                                //   ),

                                // const SizedBox(height: 4),

                                // Price display
                                Text(
                                  'MRP: ₹${(item.itemPrices?.isNotEmpty ?? false) ? (item.itemPrices![0].price?.toStringAsFixed(0) ?? '0') : (item.price?.toStringAsFixed(0) ?? '0')}',
                                  style: const TextStyle(
                                    fontFamily: LushTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),

                                // const SizedBox(height: 29),

                                // Add to cart button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _addToCart(context),
                                    icon: const Icon(
                                      Icons.add_shopping_cart,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Select',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: hex.HexColor(
                                              item.endColor ?? '#FF9800')
                                          .withOpacity(0.8),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 2),
                                      minimumSize: const Size(0, 28),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Image background circle
                      Positioned(
                        top: -5,
                        left: -5,
                        child: Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Product image
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 74,
                          height: 74,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 2,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Builder(
                            builder: (context) {
                              try {
                                if (item.imagePath == null ||
                                    item.imagePath!.isEmpty) {
                                  return Center(
                                    child: Icon(
                                      Icons.local_drink_outlined,
                                      size: 36,
                                      color: hex.HexColor(
                                          item.endColor ?? '#FF9800'),
                                    ),
                                  );
                                }
                                // Check if it's a network image or asset image
                                if (item.imagePath!.startsWith('http')) {
                                  return Image.network(
                                    item.imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.local_drink_outlined,
                                          size: 36,
                                          color: hex.HexColor(
                                              item.endColor ?? '#FF9800'),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return Image.asset(
                                    item.imagePath!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Center(
                                        child: Icon(
                                          Icons.local_drink_outlined,
                                          size: 36,
                                          color: hex.HexColor(
                                              item.endColor ?? '#FF9800'),
                                        ),
                                      );
                                    },
                                  );
                                }
                              } catch (e) {
                                return Center(
                                  child: Icon(
                                    Icons.local_drink_outlined,
                                    size: 36,
                                    color: hex.HexColor(
                                        item.endColor ?? '#FF9800'),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
