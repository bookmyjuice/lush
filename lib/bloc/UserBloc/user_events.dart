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

/// Load the bottle ledger for the authenticated customer.
class LoadBottleLedger extends UserEvent {
  const LoadBottleLedger();
}

/// Report bottles returned by the customer.
class ReportReturn extends UserEvent {
  final String orderId;
  final String bottleType;
  final int quantity;
  final String? notes;

  const ReportReturn({
    required this.orderId,
    required this.bottleType,
    required this.quantity,
    this.notes,
  });

  @override
  List<Object> get props => [orderId, bottleType, quantity];
}

/// Report bottles broken or lost by the customer.
class ReportBroken extends UserEvent {
  final String orderId;
  final String bottleType;
  final int quantity;
  final String? notes;

  const ReportBroken({
    required this.orderId,
    required this.bottleType,
    required this.quantity,
    this.notes,
  });

  @override
  List<Object> get props => [orderId, bottleType, quantity];
}
