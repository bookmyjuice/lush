import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../UserRepository/user_repository.dart';
import '../../get_it.dart';
import '../../services/subscription_service.dart';
import '../../utils/analytics_service.dart';
import '../../views/models/subscription_plan_catalog.dart';
import '../../views/models/subscription_selection.dart';

// Inline replacement for deleted subscription_plan.dart model
class SubscriptionPlan {
  final String id;
  final String name;
  final String description;
  final String pricingPageUrl;
  final String startColor;
  final String endColor;
  final String imagePath;
  final List<String> features;
  final int planID;

  const SubscriptionPlan({
    required this.id,
    required this.name,
    this.description = '',
    this.pricingPageUrl = '',
    this.startColor = '#FF9800',
    this.endColor = '#FF5722',
    this.imagePath = 'assets/subscription.png',
    this.features = const [],
    required this.planID,
  });
}

// Events
abstract class SubscriptionEvent extends Equatable {
  const SubscriptionEvent();
  @override
  List<Object> get props => [];
}

class LoadActiveSubscriptions extends SubscriptionEvent {
  const LoadActiveSubscriptions();
}

class LoadSubscriptionPlans extends SubscriptionEvent {
  const LoadSubscriptionPlans();
}

class LoadSubscriptionCatalog extends SubscriptionEvent {
  const LoadSubscriptionCatalog();
}

class CreateSubscriptionFromSelection extends SubscriptionEvent {
  final SubscriptionSelection selection;
  const CreateSubscriptionFromSelection({required this.selection});
  @override
  List<Object> get props => [selection];
}

class LoadSubscriptionHistory extends SubscriptionEvent {
  const LoadSubscriptionHistory();
}

class CreateSubscription extends SubscriptionEvent {
  final int planId;
  final DateTime startDate;
  const CreateSubscription({required this.planId, required this.startDate});
  @override
  List<Object> get props => [planId, startDate];
}

/// Cancel subscription with optional reason string.
class CancelSubscription extends SubscriptionEvent {
  final String subscriptionId;
  final String reason;
  const CancelSubscription({
    required this.subscriptionId,
    this.reason = '',
  });
  @override
  List<Object> get props => [subscriptionId, reason];
}

/// Pause subscription with a duration key.
class PauseSubscription extends SubscriptionEvent {
  final String subscriptionId;
  final String duration; // '1_week' | '2_weeks' | '1_month'
  const PauseSubscription({
    required this.subscriptionId,
    this.duration = '1_week',
  });
  @override
  List<Object> get props => [subscriptionId, duration];
}

/// Resume a paused subscription.
class ResumeSubscription extends SubscriptionEvent {
  final String subscriptionId;
  const ResumeSubscription({required this.subscriptionId});
  @override
  List<Object> get props => [subscriptionId];
}

/// Modify subscription day-wise schedule.
class ModifySubscriptionSchedule extends SubscriptionEvent {
  final String subscriptionId;
  final Map<String, String> newSchedule; // day → itemPriceId
  const ModifySubscriptionSchedule({
    required this.subscriptionId,
    required this.newSchedule,
  });
  @override
  List<Object> get props => [subscriptionId, newSchedule];
}

// Enhanced subscription model for active subscriptions
class ActiveSubscription extends Equatable {
  final String id;
  final SubscriptionPlan plan;
  final String status;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextDeliveryDate;
  final int totalDeliveries;
  final int completedDeliveries;
  final DateTime? pausedUntil;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ActiveSubscription({
    required this.id,
    required this.plan,
    required this.status,
    required this.startDate,
    this.endDate,
    this.nextDeliveryDate,
    required this.totalDeliveries,
    required this.completedDeliveries,
    this.pausedUntil,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCancelled => status == 'cancelled';
  bool get isExpired => status == 'expired';
  bool get isCompleted => status == 'completed';

  double get progress {
    if (totalDeliveries == 0) return 0.0;
    return completedDeliveries / totalDeliveries;
  }

  int get remainingDeliveries => totalDeliveries - completedDeliveries;

  String get statusDisplayName {
    switch (status) {
      case 'active':
        return 'Active';
      case 'paused':
        return 'Paused';
      case 'cancelled':
        return 'Cancelled';
      case 'expired':
        return 'Expired';
      case 'completed':
        return 'Completed';
      default:
        return 'Unknown';
    }
  }

  ActiveSubscription copyWith({
    String? id,
    SubscriptionPlan? plan,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextDeliveryDate,
    int? totalDeliveries,
    int? completedDeliveries,
    DateTime? pausedUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ActiveSubscription(
      id: id ?? this.id,
      plan: plan ?? this.plan,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextDeliveryDate: nextDeliveryDate ?? this.nextDeliveryDate,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      completedDeliveries: completedDeliveries ?? this.completedDeliveries,
      pausedUntil: pausedUntil ?? this.pausedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': plan.planID,
      'status': status,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextDeliveryDate': nextDeliveryDate?.toIso8601String(),
      'totalDeliveries': totalDeliveries,
      'completedDeliveries': completedDeliveries,
      'pausedUntil': pausedUntil?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ActiveSubscription.fromJson(Map<String, dynamic> json) {
    final planId = json['planId'] as int;
    final plan = SubscriptionPlan(
      id: json['planId']?.toString() ?? '',
      name: (json['planName'] as String?) ?? 'Unknown Plan',
      description: (json['planDescription'] as String?) ?? '',
      features: [],
      planID: planId,
    );
    return ActiveSubscription(
      id: json['id'] as String,
      plan: plan,
      status: json['status'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      nextDeliveryDate: json['nextDeliveryDate'] != null
          ? DateTime.parse(json['nextDeliveryDate'] as String)
          : null,
      totalDeliveries: json['totalDeliveries'] as int,
      completedDeliveries: json['completedDeliveries'] as int,
      pausedUntil: json['pausedUntil'] != null
          ? DateTime.parse(json['pausedUntil'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  List<Object?> get props => [
        id, plan, status, startDate, endDate, nextDeliveryDate,
        totalDeliveries, completedDeliveries, pausedUntil, createdAt, updatedAt,
      ];
}

// States
abstract class SubscriptionState extends Equatable {
  const SubscriptionState();
  @override
  List<Object> get props => [];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial();
}

class SubscriptionLoading extends SubscriptionState {
  const SubscriptionLoading();
}

class SubscriptionLoaded extends SubscriptionState {
  final ActiveSubscription subscription;
  const SubscriptionLoaded({required this.subscription});
  @override
  List<Object> get props => [subscription];
}

class SubscriptionPlansLoaded extends SubscriptionState {
  final List<SubscriptionPlan> plans;
  const SubscriptionPlansLoaded({required this.plans});
  @override
  List<Object> get props => [plans];
}

class SubscriptionCatalogLoaded extends SubscriptionState {
  final List<SubscriptionPlanCatalog> plans;
  const SubscriptionCatalogLoaded({required this.plans});
  @override
  List<Object> get props => [plans];
}

class SubscriptionCatalogError extends SubscriptionState {
  final String message;
  const SubscriptionCatalogError({required this.message});
  @override
  List<Object> get props => [message];
}

class SubscriptionCreatedSuccess extends SubscriptionState {
  final String message;
  const SubscriptionCreatedSuccess({required this.message});
  @override
  List<Object> get props => [message];
}

class SubscriptionListLoaded extends SubscriptionState {
  final List<ActiveSubscription> subscriptions;
  const SubscriptionListLoaded({required this.subscriptions});
  @override
  List<Object> get props => [subscriptions];
}

class SubscriptionEmpty extends SubscriptionState {
  const SubscriptionEmpty();
}

class SubscriptionError extends SubscriptionState {
  final String message;
  const SubscriptionError({required this.message});
  @override
  List<Object> get props => [message];
}

class SubscriptionCreated extends SubscriptionState {
  final ActiveSubscription subscription;
  const SubscriptionCreated({required this.subscription});
  @override
  List<Object> get props => [subscription];
}

class SubscriptionCancelled extends SubscriptionState {
  final String subscriptionId;
  const SubscriptionCancelled({required this.subscriptionId});
  @override
  List<Object> get props => [subscriptionId];
}

class SubscriptionPaused extends SubscriptionState {
  final ActiveSubscription subscription;
  const SubscriptionPaused({required this.subscription});
  @override
  List<Object> get props => [subscription];
}

class SubscriptionResumed extends SubscriptionState {
  final ActiveSubscription subscription;
  const SubscriptionResumed({required this.subscription});
  @override
  List<Object> get props => [subscription];
}

class SubscriptionModified extends SubscriptionState {
  final String message;
  const SubscriptionModified({required this.message});
  @override
  List<Object> get props => [message];
}

// BLoC
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final UserRepository userRepository = getIt.get();
  late final SubscriptionService _subscriptionService;

  SubscriptionBloc({SubscriptionService? subscriptionService})
      : super(const SubscriptionInitial()) {
    _subscriptionService = subscriptionService ?? SubscriptionService();
    on<LoadActiveSubscriptions>(_onLoadActiveSubscriptions);
    on<LoadSubscriptionPlans>(_onLoadSubscriptionPlans);
    on<LoadSubscriptionHistory>(_onLoadSubscriptionHistory);
    on<CreateSubscription>(_onCreateSubscription);
    on<CancelSubscription>(_onCancelSubscription);
    on<PauseSubscription>(_onPauseSubscription);
    on<ResumeSubscription>(_onResumeSubscription);
    on<LoadSubscriptionCatalog>(_onLoadSubscriptionCatalog);
    on<CreateSubscriptionFromSelection>(_onCreateSubscriptionFromSelection);
    on<ModifySubscriptionSchedule>(_onModifySubscriptionSchedule);
  }

  SubscriptionPlan _getDefaultSubscriptionPlan({
    int planID = 1,
    String name = 'Premium',
  }) {
    return SubscriptionPlan(
      id: planID.toString(),
      name: name,
      description: 'Default subscription plan',
      features: ['Daily delivery', 'Premium juices', 'Free delivery'],
      planID: planID,
    );
  }

  List<SubscriptionPlan> _getDefaultSubscriptionPlans() {
    return [
      _getDefaultSubscriptionPlan(),
      _getDefaultSubscriptionPlan(planID: 2, name: 'Signature'),
      _getDefaultSubscriptionPlan(planID: 3, name: 'Delight'),
    ];
  }

  Future<void> _onLoadSubscriptionCatalog(
    LoadSubscriptionCatalog event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final plansList = await _subscriptionService.getSubscriptionPlans();
      final catalog = plansList
          .map((json) => SubscriptionPlanCatalog.fromMap(json, const []))
          .where((plan) => plan.itemId.startsWith('bmj-'))
          .toList();
      if (isClosed) return;
      emit(SubscriptionCatalogLoaded(plans: catalog));
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionCatalogError(message: e.toString()));
    }
  }

  Future<void> _onCreateSubscriptionFromSelection(
    CreateSubscriptionFromSelection event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      await _subscriptionService.createSubscription(event.selection.itemPriceId);
      if (isClosed) return;
      emit(const SubscriptionCreatedSuccess(message: 'Subscription created successfully'));
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadActiveSubscriptions(
    LoadActiveSubscriptions event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      if (!await userRepository.isInternetAvailable()) {
        final cached = await _loadFromCache();
        if (cached != null) {
          if (isClosed) return;
          emit(SubscriptionLoaded(subscription: cached));
          return;
        }
        if (isClosed) return;
        emit(const SubscriptionError(message: 'No internet connection'));
        return;
      }

      // Try real API, fall back to mock data
      final subscriptions = await _subscriptionService.getMySubscriptions();
      if (subscriptions.isNotEmpty) {
        // Parse first subscription from API response
        final sub = subscriptions.first;
        final planId = (sub['planId'] as int?) ?? 1;
        final activeSub = ActiveSubscription(
          id: sub['id'] as String? ?? '',
          plan: SubscriptionPlan(
            id: sub['planId']?.toString() ?? '',
            name: (sub['planName'] as String?) ?? 'Subscription',
            description: (sub['planDescription'] as String?) ?? '',
            features: [],
            planID: planId,
          ),
          status: sub['status'] as String? ?? 'active',
          startDate: sub['startDate'] != null
              ? DateTime.parse(sub['startDate'] as String)
              : DateTime.now(),
          endDate: sub['endDate'] != null
              ? DateTime.parse(sub['endDate'] as String)
              : null,
          nextDeliveryDate: sub['nextDeliveryDate'] != null
              ? DateTime.parse(sub['nextDeliveryDate'] as String)
              : null,
          totalDeliveries: (sub['totalDeliveries'] as int?) ?? 0,
          completedDeliveries: (sub['completedDeliveries'] as int?) ?? 0,
          pausedUntil: sub['pausedUntil'] != null
              ? DateTime.parse(sub['pausedUntil'] as String)
              : null,
          createdAt: sub['createdAt'] != null
              ? DateTime.parse(sub['createdAt'] as String)
              : DateTime.now(),
          updatedAt: sub['updatedAt'] != null
              ? DateTime.parse(sub['updatedAt'] as String)
              : DateTime.now(),
        );
        await _saveToCache(activeSub);
        if (isClosed) return;
        emit(SubscriptionLoaded(subscription: activeSub));
      } else {
        // No active subscriptions
        if (isClosed) return;
        emit(const SubscriptionEmpty());
      }
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionPlans(
    LoadSubscriptionPlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final apiPlans = await _subscriptionService.getSubscriptionPlans();
      final plans = apiPlans.map((json) {
        return SubscriptionPlan(
          id: json['id']?.toString() ?? '',
          name: json['name'] as String? ?? 'Unknown Plan',
          description: json['description'] as String? ?? '',
          pricingPageUrl: json['pricingPageUrl'] as String? ?? '',
          startColor: json['startColor'] as String? ?? '#FF9800',
          endColor: json['endColor'] as String? ?? '#FF5722',
          imagePath: json['imagePath'] as String? ?? 'assets/subscription.png',
          features: (json['features'] as List?)?.cast<String>() ?? [],
          planID: (json['planId'] ?? json['planID'] ?? 1) as int,
        );
      }).toList();
      if (isClosed) return;
      if (plans.isEmpty) {
        emit(const SubscriptionError(message: 'No subscription plans available'));
      } else {
        emit(SubscriptionPlansLoaded(plans: plans));
      }
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionHistory(
    LoadSubscriptionHistory event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final apiSubs = await _subscriptionService.getMySubscriptions();
      final subscriptions = apiSubs.map((sub) {
        final planId = (sub['planId'] as int?) ?? 1;
        return ActiveSubscription(
          id: sub['id'] as String? ?? '',
          plan: SubscriptionPlan(
            id: sub['planId']?.toString() ?? '',
            name: (sub['planName'] as String?) ?? 'Unknown Plan',
            description: (sub['planDescription'] as String?) ?? '',
            features: [],
            planID: planId,
          ),
          status: sub['status'] as String? ?? 'active',
          startDate: sub['startDate'] != null
              ? DateTime.parse(sub['startDate'] as String)
              : DateTime.now(),
          endDate: sub['endDate'] != null
              ? DateTime.parse(sub['endDate'] as String)
              : DateTime.now().add(const Duration(days: 30)),
          nextDeliveryDate: sub['nextDeliveryDate'] != null
              ? DateTime.parse(sub['nextDeliveryDate'] as String)
              : null,
          totalDeliveries: (sub['totalDeliveries'] as int?) ?? 0,
          completedDeliveries: (sub['completedDeliveries'] as int?) ?? 0,
          pausedUntil: sub['pausedUntil'] != null
              ? DateTime.parse(sub['pausedUntil'] as String)
              : null,
          createdAt: sub['createdAt'] != null
              ? DateTime.parse(sub['createdAt'] as String)
              : DateTime.now(),
          updatedAt: sub['updatedAt'] != null
              ? DateTime.parse(sub['updatedAt'] as String)
              : DateTime.now(),
        );
      }).toList();
      if (isClosed) return;
      if (subscriptions.isEmpty) {
        emit(const SubscriptionEmpty());
      } else {
        emit(SubscriptionListLoaded(subscriptions: subscriptions));
      }
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onCreateSubscription(
    CreateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      final response = await _subscriptionService.createSubscription(
        event.planId.toString(),
      );
      final createdSub = ActiveSubscription(
        id: response['subscriptionId'] as String? ??
            response['id'] as String? ??
            'sub_${DateTime.now().millisecondsSinceEpoch}',
        plan: _getDefaultSubscriptionPlan(planID: event.planId),
        status: response['status'] as String? ?? 'active',
        startDate: event.startDate,
        endDate: event.startDate.add(const Duration(days: 30)),
        nextDeliveryDate: event.startDate.add(const Duration(days: 1)),
        totalDeliveries: (response['totalDeliveries'] as int?) ?? 30,
        completedDeliveries: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _saveToCache(createdSub);
      if (isClosed) return;
      await AnalyticsService.logSubscriptionStarted(
        planId: event.planId.toString(),
        value: 0.0,
      );
      if (isClosed) return;
      emit(SubscriptionCreated(subscription: createdSub));
      if (isClosed) return;
      emit(SubscriptionLoaded(subscription: createdSub));
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionError(message: e.toString()));
    }
  }

  /// Cancel subscription — calls API with reason.
  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      await _subscriptionService.cancelSubscription(
        event.subscriptionId,
        reason: event.reason,
      );
      await _clearCache();
      if (isClosed) return;
      await AnalyticsService.logSubscriptionCancelled(
        planId: event.subscriptionId,
        reason: event.reason.isNotEmpty ? event.reason : 'not specified',
      );
      if (isClosed) return;
      emit(SubscriptionCancelled(subscriptionId: event.subscriptionId));
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionError(message: e.toString()));
    }
  }

  /// Pause subscription — calls API with duration.
  Future<void> _onPauseSubscription(
    PauseSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      await _subscriptionService.pauseSubscription(
        event.subscriptionId,
        duration: event.duration,
      );
      await AnalyticsService.logSubscriptionPaused(event.subscriptionId);
      // Refetch subscription to get updated state
      add(const LoadActiveSubscriptions());
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionError(message: e.toString()));
    }
  }

  /// Resume subscription — calls API.
  Future<void> _onResumeSubscription(
    ResumeSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      await _subscriptionService.resumeSubscription(event.subscriptionId);
      // Refetch to get updated state
      add(const LoadActiveSubscriptions());
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionError(message: e.toString()));
    }
  }

  /// Modify schedule — calls API with new day-wise schedule.
  Future<void> _onModifySubscriptionSchedule(
    ModifySubscriptionSchedule event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());
    try {
      await _subscriptionService.modifySchedule(
        event.subscriptionId,
        event.newSchedule,
      );
      if (isClosed) return;
      emit(const SubscriptionModified(message: 'Schedule updated'));
    } catch (e) {
      if (isClosed) return;
      emit(SubscriptionError(message: e.toString()));
    }
  }

  // Cache management
  Future<void> _saveToCache(ActiveSubscription subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('active_subscription', jsonEncode(subscription.toJson()));
    } catch (_) {}
  }

  Future<ActiveSubscription?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('active_subscription');
      if (jsonStr != null) {
        return ActiveSubscription.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      }
    } catch (_) {}
    return null;
  }

  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_subscription');
    } catch (_) {}
  }
}