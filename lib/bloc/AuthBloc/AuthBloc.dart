// import 'package:flutter/cupertino.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/getIt.dart';
// import 'package:shared_preferences/shared_preferences.dart';
import 'AuthEvents.dart';
import 'AuthState.dart';
import '../../UserRepository/userRepository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository = getIt.get();

  AuthenticationBloc() : super(AuthenticationInProgress()) {
    on<AutoLogIn>((event, emit) async {
      // emit(AuthenticationInProgress());
      await userRepository.autoLogin()
          ? emit(AuthenticationSuccess())
          : emit(LogInFailed());
    });
    on<LogIn>((event, emit) async {
      // emit(AuthenticationInProgress());
      await userRepository.login(event.username, event.password, event.remember)
          ? emit(AuthenticationSuccess())
          : emit(LogInFailed());
    });

    on<AuthenticationLoggedIn>((event, emit) async {
      // AuthenticationInProgress();
      await userRepository.persistToken(event.token);
      await userRepository.persistCredentials(
          userRepository.user.getPhone, userRepository.user.getPassword);
      emit(AuthenticationSuccess());
    });

    on<SignUp>((event, emit) async {
      userRepository.user.setAddress = event.address;
      userRepository.user.setExtendedAddr = event.extendedAddr;
      userRepository.user.setExtendedAddr2 = event.extendedAddr2;
      userRepository.user.city = event.city;
      userRepository.user.state = event.state;
      userRepository.user.country = event.country;
      userRepository.user.zip = event.zip;
      var res = await userRepository.registerUserWithAddress();
      (res == "registered!") ? emit(SignUpSuccessful()) : emit(SignUpFailed());
    });
    on<InitialSignUp>((event, emit) async {
      userRepository.user.setEmail = event.email;
      userRepository.user.setPhone = event.phone;
      userRepository.user.setPassword = event.password;
      userRepository.user.setRole = "user";
      await userRepository.initialSignUp();
      userRepository.token.isNotEmpty ? TokenReceived() : SignUpFailed();
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
      // debugPrint(change.currentState.toString());
      // debugPrint(change.nextState.toString());
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
