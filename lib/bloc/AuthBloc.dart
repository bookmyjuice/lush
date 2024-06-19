// import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../events/AuthEvents.dart';
import '../states/AuthenticationState.dart';
import '../UserRepository/userRepository.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  late String? token, signUpSuccess;

  // AuthenticationState get initialState => AuthenticationInProgress();

  AuthenticationBloc({required this.userRepository})
      : super(AuthenticationInProgress()) {
    on<AutoLogIn>((event, emit) => emit(AutoLoginFailed()));
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
    on<AuthenticationFailed>((event, emit) {
      emit(AuthenticationFailure(user: event.user, key: UniqueKey()));
    });
    on<SignUp>((event, emit) async {
      if (await userRepository.SignUp(user: event.u)) {
        emit(SignUpSuccessful());
      } else {
        emit(SignUpFailed());
      }
    });
    on<MobileNumberEntered>((event, emit) async {
      userRepository.verifyMobile(event.mobileNumber);
    });
  }

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
