import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/models/Item.dart';
import '../views/models/CartItem.dart';

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

      final List<dynamic> cartList = json.decode(cartJson);
      final items = <CartItem>[];

      // Safely parse each item, skipping any that cause errors
      for (var item in cartList) {
        try {
          items.add(_cartItemFromJson(item));
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
        item = Item.fromJson(json['item']);
      } catch (e) {
        print('Error parsing item in cart: $e');
        // Create a minimal valid item to prevent crashes
        item = Item(
          id: json['item']['id'] ?? 'unknown',
          name: json['item']['name'] ?? 'Unknown Item',
          description: 'Error loading item details',
        );
      }

      // Parse selected price with error handling
      ItemPrice? selectedPrice;
      if (json['selectedPrice'] != null) {
        try {
          selectedPrice = ItemPrice.fromJson(json['selectedPrice']);
        } catch (e) {
          print('Error parsing selected price in cart: $e');
          // Create a minimal valid price to prevent crashes
          selectedPrice = ItemPrice(
            id: json['selectedPrice']['id'] ?? 'unknown',
            name: json['selectedPrice']['name'] ?? 'Regular',
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
          customizations = Map<String, dynamic>.from(json['customizations']);
        } catch (e) {
          print('Error parsing customizations in cart: $e');
          customizations = null;
        }
      }

      return CartItem(
        item: item,
        quantity: json['quantity'] is int ? json['quantity'] : 1,
        selectedSize:
            json['selectedSize'] is String ? json['selectedSize'] : null,
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
        ),
        quantity: 1,
      );
    }
  }
}
