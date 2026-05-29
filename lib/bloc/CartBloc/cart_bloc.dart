import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';

import '../../CartRepository/cart_repository.dart';
import '../../views/models/cart_item.dart';
import '../../views/models/item.dart';
import '../../utils/analytics_service.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository cartRepository;

  CartBloc(this.cartRepository) : super(CartLoading()) {
    on<LoadCart>((event, emit) async {
      emit(CartLoading());
      try {
        final items = await cartRepository.getCartItems();
        emit(CartLoaded(items));
      } catch (e) {
        emit(CartError('Failed to load cart'));
      }
    });

    on<AddToCart>((event, emit) async {
      try {
        if (state is CartLoaded) {
          final currentItems = List<CartItem>.from((state as CartLoaded).items);
          final existingItemIndex = currentItems.indexWhere((item) =>
              item.item.id == event.item.item.id &&
              item.selectedPrice?.id == event.item.selectedPrice?.id);
          if (existingItemIndex != -1) {
            final existingItem = currentItems[existingItemIndex];
            currentItems[existingItemIndex] = existingItem.copyWith(
                quantity: existingItem.quantity + event.item.quantity);
          } else {
            currentItems.add(event.item);
          }
          await cartRepository.saveCartItems(currentItems);
          emit(CartLoaded(currentItems));
        } else {
          final items = await cartRepository.getCartItems();
          final existingItemIndex = items.indexWhere((item) =>
              item.item.id == event.item.item.id &&
              item.selectedPrice?.id == event.item.selectedPrice?.id);
          if (existingItemIndex != -1) {
            final existingItem = items[existingItemIndex];
            items[existingItemIndex] = existingItem.copyWith(
                quantity: existingItem.quantity + event.item.quantity);
          } else {
            items.add(event.item);
          }
          await cartRepository.saveCartItems(items);
          emit(CartLoaded(items));
        }
      } catch (e) {
        emit(CartError('Failed to add item to cart: $e'));
      }
    });

    on<RemoveFromCart>((event, emit) async {
      try {
        if (state is CartLoaded) {
          final currentItems = List<CartItem>.from((state as CartLoaded).items)
            ..remove(event.item);
          await cartRepository.saveCartItems(currentItems);
          emit(CartLoaded(currentItems));
        } else {
          final items = await cartRepository.getCartItems();
          items.remove(event.item);
          await cartRepository.saveCartItems(items);
          emit(CartLoaded(items));
        }
      } catch (e) {
        emit(CartError('Failed to remove item from cart: $e'));
      }
    });

    on<ClearCart>((event, emit) async {
      try {
        await cartRepository.clearCart();
        emit(const CartLoaded([]));
      } catch (e) {
        emit(CartError('Failed to clear cart: $e'));
      }
    });

    on<UpdateCartItem>((event, emit) async {
      try {
        if (state is CartLoaded) {
          final currentItems = List<CartItem>.from((state as CartLoaded).items);
          final index = currentItems.indexWhere((item) =>
              item.item.id == event.item.item.id &&
              item.selectedPrice?.id == event.item.selectedPrice?.id);
          if (index != -1) {
            currentItems[index] = event.item;
            await cartRepository.saveCartItems(currentItems);
            emit(CartLoaded(currentItems));
          } else {
            currentItems.add(event.item);
            await cartRepository.saveCartItems(currentItems);
            emit(CartLoaded(currentItems));
          }
        } else {
          final items = await cartRepository.getCartItems();
          final index = items.indexWhere((item) =>
              item.item.id == event.item.item.id &&
              item.selectedPrice?.id == event.item.selectedPrice?.id);
          if (index != -1) {
            items[index] = event.item;
          } else {
            items.add(event.item);
          }
          await cartRepository.saveCartItems(items);
          emit(CartLoaded(items));
        }
      } catch (e) {
        emit(CartError('Failed to update item in cart: $e'));
      }
    });

    on<PlaceOneTimeOrder>((event, emit) async {
      emit(CartLoading());
      try {
        await Future<void>.delayed(const Duration(seconds: 1));
        await AnalyticsService.logOrderPlaced(value: 0.0, itemCount: 0);
        emit(const OrderPlaced('order-placed'));
        await cartRepository.clearCart();
        emit(const CartLoaded([]));
      } catch (e) {
        emit(CartError('Failed to place order: $e'));
      }
    });

    on<ReorderItems>((event, emit) async {
      try {
        await AnalyticsService.logReorderTapped(event.orderId);
        final cartItems = <CartItem>[];
        for (final itemData in event.items) {
          final cartItem = CartItem(
            item: Item(
              id: itemData['itemId'] as String? ?? '',
              name: itemData['itemName'] as String? ?? 'Item',
              description: '',
              servingSize: '',
            ),
            quantity: (itemData['quantity'] as num?)?.toInt() ?? 1,
          );
          cartItems.add(cartItem);
        }
        await cartRepository.clearCart();
        await cartRepository.saveCartItems(cartItems);
        emit(CartLoaded(cartItems));
      } catch (e) {
        emit(CartError('Failed to reorder items: $e'));
      }
    });
  }
}