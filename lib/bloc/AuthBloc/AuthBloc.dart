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
  // final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // late String? token, signUpSuccess;

  // AuthenticationState get initialState => AuthenticationInProgress();

  AuthenticationBloc() : super(AuthenticationInProgress()) {
    on<AutoLogIn>((event, emit) async {
      // emit(AuthenticationInProgress());
      var loginResponse = await userRepository.autoLogin();
      if (loginResponse == "0") {
        // Navigator.pushNamed('/');
        emit(LogInFailed());
      } else {
        emit(AuthenticationSuccess());
      }
    });
    on<LogIn>((event, emit) async {
      // emit(AuthenticationInProgress());
      var loginResponse = await userRepository.login(
          event.username, event.password, event.remember);
      if (loginResponse == "0") {
        emit(LogInFailed());
      } else {
        emit(AuthenticationSuccess());
      }
    });

    on<AuthenticationLoggedIn>((event, emit) async {
      // AuthenticationInProgress();
      await userRepository.persistToken(event.token);
      emit(AuthenticationSuccess());
    });
    on<SignInGoogle>((event, emit) async {
      emit(AuthenticationFailure(user: event.user, key: UniqueKey()));
      // if (await userRepository.signInGoogle(user: event.user) == null)
      //   {emit(AuthenticationSuccess())}
      // else
      //   {emit(AuthenticationFailure(user: event.user, key: UniqueKey()))}
    });
    on<SignInFacebook>((event, emit) {
      emit(AuthenticationFailure(user: event.user, key: UniqueKey()));
      // if (userRepository.signInFacebook(user: event.user) == "")
      //   {AuthenticationFailure(user: event.user)}
      // else
      //   {AuthenticationFailure(user: event.user)}
    });

    on<SignUp>((event, emit) async {
      await userRepository
          .signUp(event.phone, event.email, event.role, event.password)
          .then((id) => {if (id.length == 3) {}});
      // on<MobileNumberEntered>((event, emit) async {
      //   userRepository.verifyMobile(event.mobileNumber);
      // });
    });

    @override
    void onChange(Change<AuthenticationState> change) {
      super.onChange(change);
      debugPrint(change.toString());
      debugPrint(change.currentState.toString());
      debugPrint(change.nextState.toString());
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
