import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class AuthenticationStarted extends AuthenticationEvent {}

class AuthenticationLoggedIn extends AuthenticationEvent {
  final String token;

  const AuthenticationLoggedIn({required this.token});

  @override
  List<Object> get props => [token];

  @override
  String toString() => 'AuthenticationLoggedIn { token: $token }';
}

class LogOut extends AuthenticationEvent {}

class AutoLogIn extends AuthenticationEvent {}

class LogIn extends AuthenticationEvent {
  final String username;
  final String password;
  final bool remember;
  const LogIn(this.username, this.password, this.remember);
  @override
  List<Object> get props => [username, password, remember];
}

class GoogleSignIn extends AuthenticationEvent {
  const GoogleSignIn();

  @override
  List<Object> get props => [];
}

class MobileSignUp extends AuthenticationEvent {
  final String mobileNumber;

  const MobileSignUp({required this.mobileNumber});
  @override
  List<Object> get props => [mobileNumber];
}

class FacebookSignUp extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}

class SignInFacebook extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}

class SignUp extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}
