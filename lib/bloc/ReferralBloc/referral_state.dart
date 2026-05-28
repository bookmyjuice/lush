import 'package:equatable/equatable.dart';
import '../../models/referral_info.dart';

abstract class ReferralState extends Equatable {
  const ReferralState();
  @override
  List<Object?> get props => [];
}

class ReferralInitial extends ReferralState {
  const ReferralInitial();
  @override
  List<Object?> get props => [];
}

class ReferralLoading extends ReferralState {
  const ReferralLoading();
  @override
  List<Object?> get props => [];
}

class ReferralLoaded extends ReferralState {
  final ReferralInfo info;
  const ReferralLoaded({required this.info});
  @override
  List<Object?> get props => [info];
}

class ReferralError extends ReferralState {
  final String message;
  const ReferralError({required this.message});
  @override
  List<Object?> get props => [message];
}
