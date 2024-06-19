import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import '../models/User.dart';

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
  List<Object?> get props => throw UnimplementedError();
}

class AuthenticationSuccess extends AuthenticationState {
  @override
  // TODO: implement props
  List<Object?> get props => throw UnimplementedError();
}

class AuthenticationFailure extends AuthenticationState {
  final Key key;
  final User user;
  const AuthenticationFailure({required this.user, required this.key});
  @override
  List<Object> get props => [user];
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
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class SignUpSuccessful extends AuthenticationState {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
