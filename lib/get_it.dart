import 'package:get_it/get_it.dart';
import 'package:lush/CartRepository/cart_repository.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/services/item_service.dart';
// Keep for backward compatibility

final getIt = GetIt.instance;

void registerRepositories() {
  getIt.registerLazySingleton<CartRepository>(
    () => CartRepository(),
  );
  getIt.registerLazySingleton<UserRepository>(
    () => UserRepository(),
  );
  getIt.registerLazySingleton<ItemService>(() => ItemService());
}
