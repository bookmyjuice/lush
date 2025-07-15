import 'package:get_it/get_it.dart';
import 'package:lush/CartRepository/cartRepository.dart';
import 'package:lush/UserRepository/userRepository.dart';
import 'package:lush/services/ItemService.dart';
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
