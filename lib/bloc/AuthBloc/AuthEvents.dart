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

class GoogleSignIn extends AuthenticationEvent {
  // final User user;

  // final String signInVia;
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

class FacebookSignUp extends AuthenticationEvent {}

class SignInFacebook extends AuthenticationEvent {
  // final User user;

  // // final String signInVia;
  // const SignInFacebook(this.user);

  // @override
  // List<Object> get props => [user];
}

class InitialSignUp extends AuthenticationEvent {
  final String phone;
  final String email;
  final String role;
  final String password;

  // final String signInVia;
  const InitialSignUp(
      {required this.email,
      required this.password,
      required this.phone,
      required this.role});

  @override
  List<Object> get props => [email, phone, role, password];
}

class SignUp extends AuthenticationEvent {
  // final String id;
  // final String fname;
  // final String lname;
  // final String phone;
  // final String email;
  // final String role = "USER";
  // final String password;
  final String address;
  final String extendedAddr;
  final String extendedAddr2;
  final String city;
  final String state;
  final String country;
  final String zip;

  const SignUp(
      {
      //   required this.id,
      // required this.fname,
      // required this.lname,
      // required this.phone,
      // required this.email,
      // required this.password,
      required this.address,
      required this.extendedAddr,
      required this.extendedAddr2,
      required this.city,
      required this.state,
      required this.country,
      required this.zip});

  @override
  List<Object> get props => [
        // id,
        // phone,
        // email,
        // role,
        // password,
        address,
        extendedAddr,
        extendedAddr2,
        city,
        state,
        country,
        zip
      ];
}
