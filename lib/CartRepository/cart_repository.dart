import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../views/models/cart_item.dart';
import '../views/models/item.dart';

class CartRepository {
  static const String _cartKey = 'cart_items';
  late List<Item> items;

  CartRepository();

  // Helper method to check if two items are the same
  bool _isSameItem(Item item1, Item item2) {
    return item1.id == item2.id && item1.type == item2.type;
  }

  // Helper method to check if two cart items are the same (including selected price)
  bool _isSameCartItem(CartItem cartItem1, CartItem cartItem2) {
    return _isSameItem(cartItem1.item, cartItem2.item) &&
        cartItem1.selectedPrice?.id == cartItem2.selectedPrice?.id;
  }

  // Get cart items from local storage
  Future<List<CartItem>> getCartItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartKey);

      if (cartJson == null) {
        return [];
      }

      final List<dynamic> cartList = json.decode(cartJson) as List<dynamic>;
      final items = <CartItem>[];

      // Safely parse each item, skipping any that cause errors
      for (final item in cartList) {
        try {
          if (item is Map<String, dynamic>) {
            items.add(_cartItemFromJson(item));
          }
        } catch (e) {
          print('Error parsing cart item: $e');
          // Skip this item and continue with the next one
        }
      }

      return items;
    } catch (e) {
      print('Error loading cart items: $e');
      return [];
    }
  }

  // Save cart items to local storage
  Future<void> saveCartItems(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson =
          json.encode(items.map((item) => _cartItemToJson(item)).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      print('Error saving cart items: $e');
    }
  }

  // Clear cart
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      print('Error clearing cart: $e');
    }
  }

  // Get total item count
  Future<int> getTotalItemCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  // Get total price
  Future<double> getTotalPrice() async {
    final items = await getCartItems();
    return items.fold<double>(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Check if item exists in cart
  Future<bool> containsItem(Item item) async {
    final items = await getCartItems();
    return items.any((cartItem) => _isSameItem(cartItem.item, item));
  }

  // Get quantity of specific item
  Future<int> getItemQuantity(Item item) async {
    final items = await getCartItems();
    try {
      final cartItem =
          items.firstWhere((cartItem) => _isSameItem(cartItem.item, item));
      return cartItem.quantity;
    } catch (e) {
      return 0;
    }
  }

  // Add item to cart (NEW - Critical for functionality)
  Future<void> addItemToCart(CartItem newItem) async {
    try {
      final items = await getCartItems();
      
      // Check if item already exists (same product + same price/size)
      final existingIndex = items.indexWhere((item) =>
        _isSameCartItem(item, newItem)
      );
      
      if (existingIndex >= 0) {
        // Item exists - increment quantity
        final existingItem = items[existingIndex];
        items[existingIndex] = CartItem(
          item: existingItem.item,
          quantity: existingItem.quantity + newItem.quantity,
          selectedSize: existingItem.selectedSize,
          customizations: existingItem.customizations,
          selectedPrice: existingItem.selectedPrice,
        );
        print('Item exists in cart, quantity updated to: ${items[existingIndex].quantity}');
      } else {
        // New item - add to cart
        items.add(newItem);
        print('New item added to cart: ${newItem.item.name}');
      }
      
      await saveCartItems(items);
      print('Cart saved with ${items.length} items');
    } catch (e) {
      print('Error adding item to cart: $e');
      rethrow;
    }
  }

  // Update cart item quantity (NEW)
  Future<void> updateCartItemQuantity(CartItem updatedItem) async {
    try {
      final items = await getCartItems();
      
      final existingIndex = items.indexWhere((item) =>
        _isSameCartItem(item, updatedItem)
      );
      
      if (existingIndex >= 0) {
        final existingItem = items[existingIndex];
        if (updatedItem.quantity <= 0) {
          // Remove item if quantity is 0 or less
          items.removeAt(existingIndex);
        } else {
          // Update quantity - create new CartItem since quantity is final
          items[existingIndex] = CartItem(
            item: existingItem.item,
            quantity: updatedItem.quantity,
            selectedSize: existingItem.selectedSize,
            customizations: existingItem.customizations,
            selectedPrice: existingItem.selectedPrice,
          );
        }
        
        await saveCartItems(items);
      }
    } catch (e) {
      print('Error updating cart item quantity: $e');
      rethrow;
    }
  }

  // Remove item from cart (NEW)
  Future<void> removeCartItem(CartItem itemToRemove) async {
    try {
      final items = await getCartItems();
      
      items.removeWhere((item) =>
        _isSameCartItem(item, itemToRemove)
      );
      
      await saveCartItems(items);
    } catch (e) {
      print('Error removing item from cart: $e');
      rethrow;
    }
  }

  // Helper methods for JSON serialization
  Map<String, dynamic> _cartItemToJson(CartItem item) {
    return {
      'item': item.item.toJson(),
      'quantity': item.quantity,
      'selectedSize': item.selectedSize,
      'customizations': item.customizations,
      'selectedPrice': item.selectedPrice?.toJson(),
    };
  }

  CartItem _cartItemFromJson(Map<String, dynamic> json) {
    try {
      // Validate required fields
      if (json['item'] == null) {
        throw Exception('Cart item missing required field: item');
      }

      // Parse item with error handling
      Item item;
      try {
        item = Item.fromJson(json['item'] as Map<String, dynamic>);
      } catch (e) {
        print('Error parsing item in cart: $e');
        // Create a minimal valid item to prevent crashes
        item = Item(
          id: json['item']['id'] as String ?? 'unknown',
          name: json['item']['name'] as String ?? 'Unknown Item',
          description: 'Error loading item details',
          servingSize: json['item']['servingSize'] as String ?? 'Not Defined' ,
        );
      }

      // Parse selected price with error handling
      ItemPrice? selectedPrice;
      if (json['selectedPrice'] != null) {
        try {
          selectedPrice = ItemPrice.fromJson(json['selectedPrice'] as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing selected price in cart: $e');
          // Create a minimal valid price to prevent crashes
          selectedPrice = ItemPrice(
            id: json['selectedPrice']['id'] as String ?? 'unknown',
            name: json['selectedPrice']['name'] as String ?? 'Regular',
            price: json['selectedPrice']['price'] is num
                ? (json['selectedPrice']['price'] as num).toDouble()
                : 0.0,
          );
        }
      }

      // Parse customizations with error handling
      Map<String, dynamic>? customizations;
      if (json['customizations'] != null) {
        try {
          customizations = Map<String, dynamic>.from(json['customizations'] as Map<String, dynamic>);
        } catch (e) {
          print('Error parsing customizations in cart: $e');
          customizations = null;
        }
      }

      return CartItem(
        item: item,
        quantity: json['quantity'] as int ?? 1,
        selectedSize:
            json['selectedSize'] as  String ?? 'Not Defined',
        customizations: customizations,
        selectedPrice: selectedPrice,
      );
    } catch (e) {
      print('Error creating cart item from JSON: $e');
      // Return a minimal valid cart item to prevent crashes
      return CartItem(
        item: Item(
            id: 'error',
            name: 'Error Item',
            description: 'There was an error loading this item',
            servingSize: "Not Defined"),
        quantity: 1,
      );
    }
  }
}
