import 'package:flutter_bloc/flutter_bloc.dart';
import '../../UserRepository/user_repository.dart';
import '../../get_it.dart';
import '../../services/bottle_service.dart';
import 'user_events.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository;
  final BottleService bottleService;

  UserBloc({
    UserRepository? userRepository,
    BottleService? bottleService,
  })  : userRepository = userRepository ?? getIt.get(),
        bottleService = bottleService ?? getIt.get(),
        super(const UserInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<RefreshUserProfile>(_onRefreshUserProfile);
    on<LoadBottleLedger>(_onLoadBottleLedger);
    on<ReportReturn>(_onReportReturn);
    on<ReportBroken>(_onReportBroken);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      if (userRepository.user.id.isNotEmpty) {
        emit(UserLoaded(user: userRepository.user));
      } else {
        bool loginSuccess = await userRepository.autoLogin();
        if (isClosed) return;
        if (loginSuccess && userRepository.user.id.isNotEmpty) {
          emit(UserLoaded(user: userRepository.user));
        } else {
          emit(const UserError(message: 'Please login to view profile'));
        }
      }
    } catch (e) {
      if (isClosed) return;
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      emit(UserUpdating(user: (state as UserLoaded).user));
    }
    try {
      userRepository.user = event.user;
      // TODO: wire to backend PUT /api/user/profile
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (isClosed) return;
      emit(UserUpdated(user: event.user));
      emit(UserLoaded(user: event.user));
    } catch (e) {
      if (isClosed) return;
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onRefreshUserProfile(
    RefreshUserProfile event,
    Emitter<UserState> emit,
  ) async {
    if (state is UserLoaded) {
      try {
        bool internetAvailable = await userRepository.isInternetAvailable();
        if (internetAvailable) {
          bool loginSuccess = await userRepository.autoLogin();
          if (isClosed) return;
          if (loginSuccess && userRepository.user.id.isNotEmpty) {
            emit(UserLoaded(user: userRepository.user));
          } else {
            emit(const UserError(message: 'Failed to refresh user profile'));
          }
        } else {
          emit(const UserError(message: 'No internet connection'));
        }
      } catch (e) {
        if (isClosed) return;
        emit(UserError(message: e.toString()));
      }
    } else {
      add(const LoadUserProfile());
    }
  }

  Future<void> _onLoadBottleLedger(
    LoadBottleLedger event,
    Emitter<UserState> emit,
  ) async {
    try {
      final ledger = await bottleService.getLedger();
      final transactions = await bottleService.getTransactions();
      if (isClosed) return;
      emit(BottleLedgerLoaded(ledger: ledger, transactions: transactions));
    } catch (e) {
      if (isClosed) return;
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onReportReturn(
    ReportReturn event,
    Emitter<UserState> emit,
  ) async {
    try {
      await bottleService.recordReturn(event.orderId, event.bottleType,
          event.quantity, notes: event.notes);
      if (isClosed) return;
      emit(const BottleReportSuccess(message: 'Bottle return recorded'));
      add(const LoadBottleLedger());
    } catch (e) {
      if (isClosed) return;
      emit(UserError(message: e.toString()));
    }
  }

  Future<void> _onReportBroken(
    ReportBroken event,
    Emitter<UserState> emit,
  ) async {
    try {
      await bottleService.recordBroken(event.orderId, event.bottleType,
          event.quantity, notes: event.notes);
      if (isClosed) return;
      emit(const BottleReportSuccess(message: 'Bottle report recorded'));
      add(const LoadBottleLedger());
    } catch (e) {
      if (isClosed) return;
      emit(UserError(message: e.toString()));
    }
  }
}