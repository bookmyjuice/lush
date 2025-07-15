import 'package:equatable/equatable.dart';
import '../../views/models/user.dart';

// Events
abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class LoadUserProfile extends UserEvent {
  const LoadUserProfile();
}

class UpdateUserProfile extends UserEvent {
  final User user;

  const UpdateUserProfile({required this.user});

  @override
  List<Object> get props => [user];
}

class RefreshUserProfile extends UserEvent {
  const RefreshUserProfile();
}
