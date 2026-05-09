import 'package:flutter_bloc/flutter_bloc.dart';
import '../../UserRepository/user_repository.dart';
import '../../get_it.dart';
import 'user_events.dart';
import 'user_state.dart';

// BLoC
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository = getIt.get();

  UserBloc() : super(const UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<RefreshUserProfile>(_onRefreshUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());

    try {
      // Check if user is already loaded in repository
      if (userRepository.user.id.isNotEmpty) {
        emit(UserLoaded(user: userRepository.user));
      } else {
        // Try to auto-login or load user profile from SharedPreferences
        bool loginSuccess = await userRepository.autoLogin();
        if (loginSuccess && userRepository.user.id.isNotEmpty) {
          emit(UserLoaded(user: userRepository.user));
        } else {
          emit(const UserError(message: 'Please login to view profile'));
        }
      }
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      emit(UserUpdating(user: (state as UserLoaded).user));
    }

    try {
      // Update user in repository and backend
      userRepository.user = event.user;

      // Call your backend API to update user profile
      // This would be implemented in your UserRepository
      await Future.delayed(const Duration(seconds: 1)); // Simulating API call

      emit(UserUpdated(user: event.user));
      emit(UserLoaded(user: event.user));
    } catch (e) {
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onRefreshUserProfile(
    RefreshUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      try {
        // Refresh user data from backend
        bool internetAvailable = await userRepository.isInternetAvailable();
        if (internetAvailable) {
          bool loginSuccess = await userRepository.autoLogin();
          if (loginSuccess && userRepository.user.id.isNotEmpty) {
            emit(UserLoaded(user: userRepository.user));
          } else {
            emit(const UserError(message: 'Failed to refresh user profile'));
          }
        } else {
          emit(const UserError(message: 'No internet connection'));
        }
      } catch (e) {
        emit(UserError(message: e.toString()));
      }
    } else {
      add(const LoadUserProfile());
    }
  }
}
