import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repositories/referral_repository.dart';
import '../../utils/analytics_service.dart';
import 'referral_event.dart';
import 'referral_state.dart';

class ReferralBloc extends Bloc<ReferralEvent, ReferralState> {
  final ReferralRepository _referralRepository;
  final AnalyticsService _analyticsService;
  bool _isClosed = false;

  ReferralBloc({
    required ReferralRepository referralRepository,
    required AnalyticsService analyticsService,
  })  : _referralRepository = referralRepository,
        _analyticsService = analyticsService,
        super(const ReferralInitial()) {
    on<LoadReferralInfo>(_onLoadReferralInfo);
    on<ShareReferralCode>(_onShareReferralCode);
  }

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }

  Future<void> _onLoadReferralInfo(
    LoadReferralInfo event,
    Emitter<ReferralState> emit,
  ) async {
    if (_isClosed) return;
    emit(const ReferralLoading());
    try {
      final info = await _referralRepository.getReferralInfo();
      if (_isClosed) return;
      emit(ReferralLoaded(info: info));
    } catch (e) {
      if (_isClosed) return;
      emit(ReferralError(message: e.toString()));
    }
  }

  Future<void> _onShareReferralCode(
    ShareReferralCode event,
    Emitter<ReferralState> emit,
  ) async {
    if (_isClosed) return;
    try {
      await _analyticsService.logReferralShared();
    } catch (e) {
      developer.log('Analytics error: ' + e.toString());
    }
  }
}
