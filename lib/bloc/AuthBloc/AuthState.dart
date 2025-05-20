import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:lush/views/models/user.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState({Key? key});
  @override
  List<Object?> get props => [];
}

class AuthenticationInitiated extends AuthenticationState {
  final Key key;
  const AuthenticationInitiated(this.key);
  @override
  List<Object?> get props => [];
}

class AutoLoginFailed extends AuthenticationState {
  final String toast_message, toast_heading;

  const AutoLoginFailed({super.key, required this.toast_message, required this.toast_heading});
  @override
  
  List<Object?> get props => [toast_heading, toast_message];
}

class LogInFailed extends AuthenticationState {
  final String toast_message, toast_heading;

  const LogInFailed({super.key, required this.toast_message, required this.toast_heading});
  
  @override
  List<Object?> get props => [toast_heading,toast_message];
}

class AuthenticationSuccess extends AuthenticationState {
  final User user;
  const AuthenticationSuccess(this.user);
  // UserRepository
  @override
  List<Object?> get props => [user];
}


class AuthError extends AuthenticationState {
  // final Key key;
  final String error;
  const AuthError({required this.error});
  @override
  List<Object> get props => [error];
}

class AuthenticationInProgress extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class SignUpFailed extends AuthenticationState {
  final String error_heading, error;

  const SignUpFailed({super.key, required this.error_heading, required this.error});

  @override
  List<Object?> get props => [error_heading, error];
}

class SignUpStarted extends AuthenticationState {
  // final User user;
  const SignUpStarted();
  @override
  List<Object?> get props => [];
}

class TokenReceived extends AuthenticationState {}

class SignUpSuccessful extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class LoggedOut extends AuthenticationState {
  @override
  List<Object?> get props => [];
}
