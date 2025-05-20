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
          ? emit(AuthenticationSuccess(userRepository.user))
          : emit(AutoLoginFailed(toast_heading: "AutoLogin Failed!", toast_message: "Please login again or register"));
    });
    on<LogIn>((event, emit) async {
      emit(AuthenticationInProgress());
      bool loginSuccess = await userRepository.login(
          event.username, event.password, event.remember);
      loginSuccess
          ? emit(AuthenticationSuccess(userRepository.user))
          : emit(LogInFailed(toast_heading: "Login Failed!", toast_message: "Please check your credentials!"));
    });

    on<LogOut>((event, emit) async {
      emit(AuthenticationInProgress());
      await userRepository.logout();
      emit(LoggedOut());
    });

    on<SignUp>((event, emit) async {
      var res = await userRepository.signUp();
      (res.split(':')[0] == "Error")
          ? emit(SignUpFailed(error: res.split(':')[1], error_heading: "SignUp Failed!"))
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
