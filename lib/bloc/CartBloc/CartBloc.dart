import 'package:bloc/bloc.dart';
import 'package:lush/getIt.dart';
import '../../CartRepository/cartRepository.dart';
import '../../views/models/user.dart';
import 'cartEvent.dart';
import 'cartState.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  late User? user;
  // final CartRepository cartRepo;
  final CartRepository carRepository = getIt.get();

  CartBloc() : super(CartEmpty()) {
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
