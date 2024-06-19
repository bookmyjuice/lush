import 'package:equatable/equatable.dart';
import '../models/User.dart';

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

class AuthenticationFailed extends AuthenticationEvent {
  final User user;

  const AuthenticationFailed({required this.user});

  @override
  List<Object> get props => [user];
}

class AuthenticationLoggedOut extends AuthenticationEvent {}

class AutoLogIn extends AuthenticationEvent {}

  class SignInGoogle extends AuthenticationEvent {
  final User user;

  // final String signInVia;
  const SignInGoogle(this.user);

  @override
  List<Object> get props => [user];
}

class SignInFacebook extends AuthenticationEvent {
  final User user;

  // final String signInVia;
  const SignInFacebook(this.user);

  @override
  List<Object> get props => [user];
}

class SignInOTP extends AuthenticationEvent {
  final User user;

  // final String signInVia;
  const SignInOTP(this.user);

  @override
  List<Object> get props => [user];
}
// class SignUp extends AuthenticationEvent {
//   final User u;
//   const SignUp(this.u);
//   @override
//   List<Object> get props => [u];
// }

class SignUp extends AuthenticationEvent {
  // final String username;
  // final String password;
  // final String fullName;
  final User u;

  const SignUp(this.u);

  @override
  List<Object> get props => [u];
}

class MobileNumberEntered extends AuthenticationEvent {
  const MobileNumberEntered(this.mobileNumber);

  final String mobileNumber;

  @override
  List<Object> get props => [mobileNumber];
}
