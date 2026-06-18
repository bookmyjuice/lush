import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../services/cart_service.dart';
import '../services/secure_storage_service.dart';
import '../views/models/cart_item.dart';
import '../views/models/item.dart';
import 'package:lush/utils/app_logger.dart';

/// Repository for cart data storage and backend synchronization.
///
/// **Architecture (offline-first):**
/// 1. All reads come from local SharedPreferences cache (instant, works offline)
/// 2. All writes go to local cache first (instant UI update), then fire-and-forget to backend
/// 3. On app load/refresh, attempts to fetch from backend and merge if user is authenticated
/// 4. Guest users (no JWT) use local-only storage
class CartRepository {
  static const String _cartKey = 'cart_items';
  late List<Item> items;

  final SecureStorageService _secureStorage = SecureStorageService();
  CartService? _cartService;

  CartRepository();

  /// Lazily initialize CartService (only if user has a token).
  CartService get _backend {
    _cartService ??= CartService();
    return _cartService!;
  }

  /// Check if user is authenticated (has JWT token in secure storage).
  Future<bool> _isAuthenticated() async {
    final token = await _secureStorage.getAuthToken();
    return token != null && token.isNotEmpty;
  }

  // =========================================================================
  // Local (offline) operations — always work, no network required
  // =========================================================================

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
          appLogger.e('Error parsing cart item', error: e);
          // Skip this item and continue with the next one
        }
      }

      return items;
    } catch (e) {
      appLogger.e('Error loading cart items', error: e);
      return [];
    }
  }

  // Save cart items to local storage
  Future<void> saveCartItems(List<CartItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson =
          json.encode(items.map(_cartItemToJson).toList());
      await prefs.setString(_cartKey, cartJson);
    } catch (e) {
      appLogger.e('Error saving cart items', error: e);
    }
  }

  // Clear cart locally
  Future<void> clearCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cartKey);
    } catch (e) {
      appLogger.e('Error clearing cart', error: e);
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
        _isSameCartItem(item, newItem),
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
        appLogger.d('Item exists in cart, quantity updated to: ${items[existingIndex].quantity}');
      } else {
        // New item - add to cart
        items.add(newItem);
        appLogger.d('New item added to cart: ${newItem.item.name}');
      }

      await saveCartItems(items);
      appLogger.d('Cart saved with ${items.length} items');

      // Background sync to backend (fire-and-forget)
      _pushItemToBackend(newItem, items);
    } catch (e) {
      appLogger.e('Error adding item to cart', error: e);
      rethrow;
    }
  }

  // Update cart item quantity (NEW)
  Future<void> updateCartItemQuantity(CartItem updatedItem) async {
    try {
      final items = await getCartItems();

      final existingIndex = items.indexWhere((item) =>
        _isSameCartItem(item, updatedItem),
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

      // Background sync to backend
      _pushAllItemsToBackend(items);
    } catch (e) {
      appLogger.e('Error updating cart item quantity', error: e);
      rethrow;
    }
  }

  // Remove item from cart (NEW)
  Future<void> removeCartItem(CartItem itemToRemove) async {
    try {
      final items = await getCartItems();

      items.removeWhere((item) =>
        _isSameCartItem(item, itemToRemove),
      );

      await saveCartItems(items);

      // Background sync to backend
      _pushItemRemovalToBackend(itemToRemove);
    } catch (e) {
      appLogger.e('Error removing item from cart', error: e);
      rethrow;
    }
  }

  // =========================================================================
  // Backend synchronization (fire-and-forget, best-effort)
  // =========================================================================

  /// Sync local cart with backend cart.
  /// Called on app start / login to ensure local cart matches server state.
  /// Strategy:
  ///   1. If user is not authenticated, skip (local-only)
  ///   2. Fetch backend cart
  ///   3. If local cart is empty and backend has items, pull backend → local
  ///   4. If local has items and backend is empty, push local → backend
  ///   5. If both have items, merge (add backend items not in local)
  /// Returns the merged cart items.
  Future<List<CartItem>> syncWithBackend() async {
    if (!await _isAuthenticated()) {
      appLogger.d('CartRepository: User not authenticated, skipping backend sync');
      return getCartItems();
    }

    try {
      final localItems = await getCartItems();
      final backendCart = await _backend.getCart();

      // Parse backend items
      final backendItemsRaw = backendCart['items'] as List<dynamic>? ?? [];
      final backendItems = backendItemsRaw.map((item) {
        final map = item as Map<String, dynamic>;
        return CartItem(
          item: Item(
            id: map['priceId'] as String? ?? '',
            name: map['name'] as String? ?? 'Item',
            description: '',
            servingSize: '',
          ),
          quantity: (map['quantity'] as num?)?.toInt() ?? 1,
          selectedPrice: ItemPrice(
            id: map['priceId'] as String?,
            price: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
            name: map['name'] as String?,
          ),
        );
      }).toList();

      if (localItems.isEmpty && backendItems.isNotEmpty) {
        // Pull backend → local
        await saveCartItems(backendItems);
        appLogger.d('CartRepository: Pulled ${backendItems.length} items from backend');
        return backendItems;
      } else if (localItems.isNotEmpty && backendItems.isEmpty) {
        // Push local → backend
        await _pushAllItemsToBackend(localItems);
        appLogger.d('CartRepository: Pushed ${localItems.length} items to backend');
        return localItems;
      } else if (localItems.isNotEmpty && backendItems.isNotEmpty) {
        // Merge: keep local items, add any backend-only items
        for (final backendItem in backendItems) {
          final exists = localItems.any((local) =>
            local.selectedPrice?.id == backendItem.selectedPrice?.id,
          );
          if (!exists) {
            localItems.add(backendItem);
          }
        }
        await saveCartItems(localItems);
        await _pushAllItemsToBackend(localItems);
        appLogger.d('CartRepository: Merged ${backendItems.length} backend items into local');
        return localItems;
      }

      return localItems;
    } catch (e) {
      // Backend unreachable — silently fall back to local
      appLogger.w('CartRepository: Backend sync failed, using local cart: $e');
      return getCartItems();
    }
  }

  /// Push a single item to the backend (fire-and-forget).
  Future<void> _pushItemToBackend(CartItem newItem, List<CartItem> allItems) async {
    if (!await _isAuthenticated()) return;
    try {
      final priceId = newItem.selectedPrice?.id ?? newItem.item.id;
      if (priceId == null || priceId.isEmpty || priceId == 'unknown') return;

      await _backend.addItem(priceId, quantity: newItem.quantity);
      appLogger.d('CartRepository: Pushed item $priceId to backend');
    } catch (e) {
      if (e is CartTypeConflictException) {
        appLogger.w('CartRepository: Type conflict pushing to backend: $e');
      } else {
        appLogger.w('CartRepository: Failed to push item to backend: $e');
      }
    }
  }

  /// Push all local items to backend (fire-and-forget).
  Future<void> _pushAllItemsToBackend(List<CartItem> allItems) async {
    if (!await _isAuthenticated()) return;

    try {
      // Clear backend cart first
      await _backend.clearCart();

      // Add each item
      for (final item in allItems) {
        final priceId = item.selectedPrice?.id ?? item.item.id;
        if (priceId == null || priceId.isEmpty || priceId == 'unknown') continue;
        await _backend.addItem(priceId, quantity: item.quantity);
      }
      appLogger.d('CartRepository: Pushed ${allItems.length} items to backend');
    } catch (e) {
      if (e is CartTypeConflictException) {
        appLogger.w('CartRepository: Type conflict pushing all items: $e');
      } else {
        appLogger.w('CartRepository: Failed to push all items to backend: $e');
      }
    }
  }

  /// Remove item from backend (fire-and-forget).
  Future<void> _pushItemRemovalToBackend(CartItem item) async {
    if (!await _isAuthenticated()) return;
    try {
      final priceId = item.selectedPrice?.id ?? item.item.id;
      if (priceId == null || priceId.isEmpty || priceId == 'unknown') return;

      await _backend.removeItem(priceId);
      appLogger.d('CartRepository: Removed item $priceId from backend');
    } catch (e) {
      appLogger.w('CartRepository: Failed to remove item from backend: $e');
    }
  }

  /// Clear cart on both local and backend.
  Future<void> clearCartSync() async {
    await clearCart();
    if (await _isAuthenticated()) {
      try {
        await _backend.clearCart();
        appLogger.d('CartRepository: Cleared backend cart');
      } catch (e) {
        appLogger.w('CartRepository: Failed to clear backend cart: $e');
      }
    }
  }

  /// Merge local (guest) cart items into the authenticated user's backend cart.
  /// Call this after login/signup to persist guest cart items.
  /// Returns the merged cart items.
  Future<List<CartItem>> mergeGuestCartToBackend() async {
    if (!await _isAuthenticated()) {
      appLogger.d('CartRepository: Not authenticated, skipping guest cart merge');
      return getCartItems();
    }

    final localItems = await getCartItems();
    if (localItems.isEmpty) {
      appLogger.d('CartRepository: No guest items to merge');
      return [];
    }

    try {
      // Push all local items to backend
      await _pushAllItemsToBackend(localItems);
      appLogger.d('CartRepository: Merged ${localItems.length} guest items to backend');
      return localItems;
    } catch (e) {
      appLogger.w('CartRepository: Failed to merge guest cart: $e');
      return localItems;
    }
  }

  // =========================================================================
  // JSON Serialization helpers
  // =========================================================================

  // Helper methods for JSON serialization
  Map<String, dynamic> _cartItemToJson(CartItem item) {
    return {
      'item': item.item.toDisplayJson(),
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
        appLogger.e('Error parsing item in cart', error: e);
      // Create a minimal valid item to prevent crashes
        item = Item(
          id: (json['item']['id'] as String?) ?? 'unknown',
          name: (json['item']['name'] as String?) ?? 'Unknown Item',
          description: 'Error loading item details',
          servingSize: (json['item']['servingSize'] as String?) ?? 'Not Defined',
        );
      }

      // Parse selected price with error handling
      ItemPrice? selectedPrice;
      if (json['selectedPrice'] != null) {
        try {
          selectedPrice = ItemPrice.fromJson(json['selectedPrice'] as Map<String, dynamic>);
        } catch (e) {
          appLogger.e('Error parsing selected price in cart', error: e);
          // Create a minimal valid price to prevent crashes
          selectedPrice = ItemPrice(
            id: (json['selectedPrice']['id'] as String?) ?? 'unknown',
            name: (json['selectedPrice']['name'] as String?) ?? 'Regular',
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
          appLogger.e('Error parsing customizations in cart', error: e);
          customizations = null;
        }
      }

      return CartItem(
        item: item,
        quantity: (json['quantity'] as int?) ?? 1,
        selectedSize:
            (json['selectedSize'] as String?) ?? 'Not Defined',
        customizations: customizations,
        selectedPrice: selectedPrice,
      );
    } catch (e) {
      appLogger.e('Error creating cart item from JSON', error: e);
      // Return a minimal valid cart item to prevent crashes
      return CartItem(
        item: Item(
            id: 'error',
            name: 'Error Item',
            description: 'There was an error loading this item',
            servingSize: 'Not Defined',),
      );
    }
  }
}