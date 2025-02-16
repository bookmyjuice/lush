import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';

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
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class LogInFailed extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class AuthenticationSuccess extends AuthenticationState {
  // final User user;
  const AuthenticationSuccess();
  // UserRepository
  @override
  List<Object?> get props => throw UnimplementedError();
}

class AuthError extends AuthenticationState {
  // final Key key;
  final String error;
  const AuthError({required this.error});
  @override
  List<Object> get props => [error];
}

class AuthenticationInProgress extends AuthenticationState {
  // final User user=User();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SignUpFailed extends AuthenticationState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SignUpStarted extends AuthenticationState {
  // final User user;
  const SignUpStarted();
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class TokenReceived extends AuthenticationState {}

class SignUpSuccessful extends AuthenticationState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
