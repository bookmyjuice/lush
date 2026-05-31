import 'package:get_it/get_it.dart';
import 'package:lush/CartRepository/cart_repository.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/services/bottle_service.dart';
import 'package:lush/services/item_service.dart';
import 'package:lush/services/subscription_service.dart';

final getIt = GetIt.instance;

void registerRepositories() {
  // Allow reassignment between test runs (prevents "already registered" crash)
  getIt.allowReassignment = true;

  if (!getIt.isRegistered<CartRepository>()) {
    getIt.registerLazySingleton<CartRepository>(
      CartRepository.new,
    );
  }
  if (!getIt.isRegistered<UserRepository>()) {
    getIt.registerLazySingleton<UserRepository>(
      UserRepository.new,
    );
  }
  if (!getIt.isRegistered<ItemService>()) {
    getIt.registerLazySingleton<ItemService>(ItemService.new);
  }
  if (!getIt.isRegistered<BottleService>()) {
    getIt.registerLazySingleton<BottleService>(BottleService.new);
  }
  if (!getIt.isRegistered<SubscriptionService>()) {
    getIt.registerLazySingleton<SubscriptionService>(SubscriptionService.new);
  }
}