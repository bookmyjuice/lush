import 'package:equatable/equatable.dart';

abstract class LushState extends Equatable {

  @override
  List<Object> get props => [];
}

class AppLaunch extends LushState {}

class LushSuccess extends LushState {}

class LushFailure extends LushState {}

class LushInProgress extends LushState {}

class SignUpStarted extends LushState {}
class SignUpSuccessful extends LushState {}
