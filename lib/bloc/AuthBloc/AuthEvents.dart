import 'package:equatable/equatable.dart';
import '../../views/models/User.dart';

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

class AuthenticationLoggedOut extends AuthenticationEvent {}

class AutoLogIn extends AuthenticationEvent {}

class LogIn extends AuthenticationEvent {
  final String username;
  final String password;
  final bool remember;
  const LogIn(this.username, this.password, this.remember);
  @override
  List<Object> get props => [username, password, remember];
}

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
  final String phone;
  final String email;
  final String role = "USER";
  final String password;
  const SignUp(this.phone, this.email, this.password);

  @override
  List<Object> get props => [phone, email, role, password];
}

class MobileNumberEntered extends AuthenticationEvent {
  const MobileNumberEntered(this.mobileNumber);

  final String mobileNumber;

  @override
  List<Object> get props => [mobileNumber];
}
