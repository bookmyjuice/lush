import 'package:equatable/equatable.dart';

abstract class ReferralEvent extends Equatable {
  const ReferralEvent();

  @override
  List<Object> get props => [];
}

class LoadReferralInfo extends ReferralEvent {
  const LoadReferralInfo();

  @override
  List<Object> get props => [];
}

class ShareReferralCode extends ReferralEvent {
  const ShareReferralCode();

  @override
  List<Object> get props => [];
}
