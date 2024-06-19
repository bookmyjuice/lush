import 'package:bloc/bloc.dart';
import '../CartRepository/cartRepository.dart';
import '../events/cart_event.dart';
import '../models/User.dart';
import '../states/cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  late User? user;
  final CartRepository cartRepo;

  CartBloc({required this.cartRepo}) : super(CartEmpty()) {
    on<CartItemAdded>((event, emit) =>
        emit(CartNotEmpty(juices: [...state.juices]).addJuice(event.juice)));
    on<CartItemAdded>((event, emit) {
      state.juices.length > 1
          ? emit(CartNotEmpty(juices: state.juices).addJuice(event.juice))
          : emit(CartEmpty());
    });
    on<CartEmptied>((event, emit) => emit(CartEmpty()));
  }
}
