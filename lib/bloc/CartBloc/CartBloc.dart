import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/CartBloc/cartEvent.dart';

import '../../CartRepository/cartRepository.dart';
import '../../views/models/CartItem.dart';
import 'cartState.dart';

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

          // Check if the same item with the same price is already in the cart
          final existingItemIndex = currentItems.indexWhere((item) =>
              item.item.id == event.item.item.id &&
              item.selectedPrice?.id == event.item.selectedPrice?.id);

          if (existingItemIndex != -1) {
            // Update quantity of existing item
            final existingItem = currentItems[existingItemIndex];
            currentItems[existingItemIndex] = existingItem.copyWith(
                quantity: existingItem.quantity + event.item.quantity);
          } else {
            // Add new item
            currentItems.add(event.item);
          }

          await cartRepository.saveCartItems(currentItems);
          emit(CartLoaded(currentItems));
        } else {
          // If state is not CartLoaded, load cart first then add item
          final items = await cartRepository.getCartItems();

          // Check if the same item with the same price is already in the cart
          final existingItemIndex = items.indexWhere((item) =>
              item.item.id == event.item.item.id &&
              item.selectedPrice?.id == event.item.selectedPrice?.id);

          if (existingItemIndex != -1) {
            // Update quantity of existing item
            final existingItem = items[existingItemIndex];
            items[existingItemIndex] = existingItem.copyWith(
                quantity: existingItem.quantity + event.item.quantity);
          } else {
            // Add new item
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
          // If state is not CartLoaded, load cart first then remove item
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

          // Find the index of the item to update
          final index = currentItems.indexWhere((item) =>
              item.item.id == event.item.item.id &&
              item.selectedPrice?.id == event.item.selectedPrice?.id);

          if (index != -1) {
            // Replace the item at the found index
            currentItems[index] = event.item;
            await cartRepository.saveCartItems(currentItems);
            emit(CartLoaded(currentItems));
          } else {
            // If item not found, add it
            currentItems.add(event.item);
            await cartRepository.saveCartItems(currentItems);
            emit(CartLoaded(currentItems));
          }
        } else {
          // If state is not CartLoaded, load cart first then update item
          final items = await cartRepository.getCartItems();

          // Find the index of the item to update
          final index = items.indexWhere((item) =>
              item.item.id == event.item.item.id &&
              item.selectedPrice?.id == event.item.selectedPrice?.id);

          if (index != -1) {
            // Replace the item at the found index
            items[index] = event.item;
          } else {
            // If item not found, add it
            items.add(event.item);
          }

          await cartRepository.saveCartItems(items);
          emit(CartLoaded(items));
        }
      } catch (e) {
        emit(CartError('Failed to update item in cart: $e'));
      }
    });
  }
}
