import 'package:equatable/equatable.dart';
import '../../views/models/user.dart';
import '../../views/models/bottle_ledger.dart';

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

/// Bottle ledger has been loaded successfully.
class BottleLedgerLoaded extends UserState {
  final List<BottleLedgerEntry> ledger;
  final List<BottleTransaction> transactions;

  const BottleLedgerLoaded({
    required this.ledger,
    required this.transactions,
  });

  @override
  List<Object> get props => [ledger, transactions];
}

/// A bottle report (return/broken) has succeeded.
class BottleReportSuccess extends UserState {
  final String message;

  const BottleReportSuccess({required this.message});

  @override
  List<Object> get props => [message];
}
