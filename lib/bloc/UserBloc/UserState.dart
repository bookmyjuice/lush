import 'package:equatable/equatable.dart';
import '../../views/models/user.dart';

// States
abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final User user;

  const UserLoaded({required this.user});

  @override
  List<Object> get props => [user];
}

class UserError extends UserState {
  final String message;

  const UserError({required this.message});

  @override
  List<Object> get props => [message];
}

class UserUpdating extends UserState {
  final User user;

  const UserUpdating({required this.user});

  @override
  List<Object> get props => [user];
}

class UserUpdated extends UserState {
  final User user;

  const UserUpdated({required this.user});

  @override
  List<Object> get props => [user];
}
