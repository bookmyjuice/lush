import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/getIt.dart';
import 'AuthEvents.dart';
import 'AuthState.dart';
import '../../UserRepository/userRepository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository = getIt.get();

  AuthenticationBloc() : super(AuthenticationInProgress()) {
    on<AutoLogIn>((event, emit) async {
      await userRepository.autoLogin()
          ? emit(AuthenticationSuccess())
          : emit(LogInFailed());
    });
    on<LogIn>((event, emit) async {
      await userRepository.login(event.username, event.password, event.remember)
          ? emit(AuthenticationSuccess())
          : emit(LogInFailed());
    });

    // on<AuthenticationLoggedIn>((event, emit) async {
    //   await userRepository.persistToken(event.token);
    //   await userRepository.persistCredentials(
    //       userRepository.user.getPhone, userRepository.user.getPassword);
    //   emit(AuthenticationSuccess());
    // });

    on<SignUp>((event, emit) async {
      var res = await userRepository.signUp();
      (res.split(':')[0] == "Error")
          ? emit(SignUpFailed(error: res))
          : emit(SignUpSuccessful());
    });
    on<GoogleSignIn>((event, emit) async {
      await userRepository.googleSignIn_();
      emit(SignUpStarted());
    });
    on<MobileSignUp>((event, emit) {
      userRepository.user.setPhone = event.mobileNumber;
      emit(SignUpStarted());
    });
    on<FacebookSignUp>((event, emit) {});

    @override
    void onChange(Change<AuthenticationState> change) {
      super.onChange(change);
      debugPrint(change.toString());
    }

    @override
    void onTransition(
        Transition<AuthenticationEvent, AuthenticationState> transition) {
      super.onTransition(transition);
      debugPrint(transition.toString());
    }

    @override
    void onError(Object error, StackTrace stackTrace) {
      super.onError(error, stackTrace);
      debugPrint(error.toString());
    }

    @override
    void onEvent(AuthenticationEvent event) {
      super.onEvent(event);
      debugPrint(event.toString());
    }
  }
}
