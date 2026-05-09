import 'package:flutter/material.dart';
import '../../theme.dart';
import '../models/item.dart';

class SizeSelectionModal extends StatefulWidget {
  final Item item;
  final Function(ItemPrice selectedPrice) onPriceSelected;

  const SizeSelectionModal({
    super.key,
    required this.item,
    required this.onPriceSelected,
  });

  @override
  State<SizeSelectionModal> createState() => _SizeSelectionModalState();
}

class _SizeSelectionModalState extends State<SizeSelectionModal> {
  ItemPrice? selectedPrice;

  @override
  void initState() {
    super.initState();
    // Pre-select the first price option if available
    final prices = widget.item.itemPrices ?? [];
    if (prices.isNotEmpty) {
      selectedPrice = prices.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prices = widget.item.itemPrices ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: LushTheme.darkerText,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.item.description ?? 'Choose your size/variety',
                    style: const TextStyle(
                      fontSize: 14,
                      color: LushTheme.lightText,
                    ),
                  ),
                ],
              ),
            ),

            // Price/Size options
            if (prices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.orange,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No size options available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: LushTheme.darkerText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This item doesn\'t have any size or price options configured.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: LushTheme.lightText,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: prices.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final price = prices[index];
                    final isSelected = selectedPrice == price;

                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedPrice = price;
                        });
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.orange.withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected
                              ? Border.all(color: Colors.orange, width: 1)
                              : null,
                        ),
                        child: Row(
                          children: [
                            // Radio button
                            Radio<ItemPrice>(
                              value: price,
                              groupValue: selectedPrice,
                              activeColor: Colors.orange,
                              onChanged: (ItemPrice? value) {
                                setState(() {
                                  selectedPrice = value;
                                });
                              },
                            ),

                            // Size info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    price.name ?? price.description ?? 'Option',
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      fontSize: 16,
                                      color: isSelected
                                          ? Colors.orange
                                          : LushTheme.darkerText,
                                    ),
                                  ),
                                  if (price.description != null)
                                    Text(
                                      price.description!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: LushTheme.lightText,
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Price
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.orange
                                    : Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '₹${price.price?.toStringAsFixed(0) ?? '-'}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : LushTheme.darkerText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Add to Cart Button with quantity selector
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Price summary
                  if (selectedPrice != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Selected: ${selectedPrice!.name}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: LushTheme.darkerText,
                            ),
                          ),
                          Text(
                            '₹${selectedPrice!.price?.toStringAsFixed(0) ?? '-'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: prices.isEmpty || selectedPrice == null
                          ? null
                          : () {
                              try {
                                widget.onPriceSelected(selectedPrice!);
                                Navigator.pop(context);

                                // Show confirmation snackbar
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${widget.item.name} (${selectedPrice!.name}) added to cart!',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    action: SnackBarAction(
                                      label: 'VIEW CART',
                                      textColor: Colors.white,
                                      onPressed: () {
                                        // Use a delayed future to ensure we're not using a disposed context
                                        Future.delayed(Duration.zero, () {
                                          // Get the navigator from the current context
                                          final navigator = Navigator.of(
                                            ScaffoldMessenger.of(context)
                                                .context,
                                            rootNavigator: true,
                                          );
                                          navigator.pushNamed('/cart');
                                        });
                                      },
                                    ),
                                  ),
                                );
                              } catch (e) {
                                // Log error but don't show print in production
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Error adding to cart: $e',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedPrice != null
                            ? Colors.orange
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.shopping_cart_checkout),
                          const SizedBox(width: 8),
                          Text(
                            prices.isEmpty
                                ? 'No options available'
                                : selectedPrice != null
                                    ? 'Add to Cart - ₹${selectedPrice!.price?.toStringAsFixed(0) ?? '-'}'
                                    : 'Select an option',
                            style: TextStyle(
                              color: selectedPrice != null
                                  ? Colors.white
                                  : Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
