import 'package:bloc/bloc.dart';
import 'package:lush/getIt.dart';
import '../../CartRepository/cartRepository.dart';
import '../../views/models/user.dart';
import 'cartEvent.dart';
import 'cartState.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  late User? user;
  final CartRepository cartRepository = getIt.get();

  CartBloc() : super(CartEmpty()) {
    on<CartItemAdded>((event, emit) {
      if (state is CartNotEmpty) {
        final currentState = state as CartNotEmpty;
        emit(CartNotEmpty(juices: [...currentState.juices, event.juice]));
      } else {
        emit(CartNotEmpty(juices: [event.juice]));
      }
    });

    on<CartItemRemoved>((event, emit) {
      if (state is CartNotEmpty) {
        final currentState = state as CartNotEmpty;
        final updatedJuices = List.of(currentState.juices)..remove(event.juice);
        if (updatedJuices.isEmpty) {
          emit(CartEmpty());
        } else {
          emit(CartNotEmpty(juices: updatedJuices));
        }
      }
    });

    on<CartEmptied>((event, emit) => emit(CartEmpty()));
  }
}
