import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../views/models/subscriptionPlan.dart';
import '../../UserRepository/userRepository.dart';
import '../../getIt.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

class LoadSubscriptionHistory extends SubscriptionEvent {
  const LoadSubscriptionHistory();
}

class CreateSubscription extends SubscriptionEvent {
  final int planId;
  final DateTime startDate;

  const CreateSubscription({
    required this.planId,
    required this.startDate,
  });

  @override
  List<Object> get props => [planId, startDate];
}

class CancelSubscription extends SubscriptionEvent {
  final String subscriptionId;

  const CancelSubscription({required this.subscriptionId});

  @override
  List<Object> get props => [subscriptionId];
}

class PauseSubscription extends SubscriptionEvent {
  final String subscriptionId;
  final DateTime pauseUntil;

  const PauseSubscription({
    required this.subscriptionId,
    required this.pauseUntil,
  });

  @override
  List<Object> get props => [subscriptionId, pauseUntil];
}

class ResumeSubscription extends SubscriptionEvent {
  final String subscriptionId;

  const ResumeSubscription({required this.subscriptionId});

  @override
  List<Object> get props => [subscriptionId];
}

// Enhanced subscription model for active subscriptions
class ActiveSubscription extends Equatable {
  final String id;
  final SubscriptionPlan plan;
  final String
      status; // 'active', 'paused', 'cancelled', 'expired', 'completed'
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

  int get remainingDeliveries {
    return totalDeliveries - completedDeliveries;
  }

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

    // Create a default plan
    final plan = SubscriptionPlan(
      id: json['planId']?.toString() ?? '',
      name: json['planName'] ?? 'Unknown Plan',
      description: json['planDescription'] ?? '',
      pricingPageUrl: '',
      startColor: '#FF9800',
      endColor: '#FF5722',
      imagePath: 'assets/subscription.png',
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
        id,
        plan,
        status,
        startDate,
        endDate,
        nextDeliveryDate,
        totalDeliveries,
        completedDeliveries,
        pausedUntil,
        createdAt,
        updatedAt,
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

// BLoC
class SubscriptionBloc extends Bloc<SubscriptionEvent, SubscriptionState> {
  final UserRepository userRepository = getIt.get();

  // Helper method to create a default subscription plan
  SubscriptionPlan _getDefaultSubscriptionPlan(
      {int planID = 1, String name = 'Premium'}) {
    return SubscriptionPlan(
      id: planID.toString(),
      name: name,
      description: 'Default subscription plan',
      pricingPageUrl: '',
      startColor: '#FF9800',
      endColor: '#FF5722',
      imagePath: 'assets/subscription.png',
      features: ['Daily delivery', 'Premium juices', 'Free delivery'],
      planID: planID,
    );
  }

  // Helper method to get a list of default subscription plans
  List<SubscriptionPlan> _getDefaultSubscriptionPlans() {
    return [
      _getDefaultSubscriptionPlan(planID: 1, name: 'Premium'),
      _getDefaultSubscriptionPlan(planID: 2, name: 'Signature'),
      _getDefaultSubscriptionPlan(planID: 3, name: 'Delight'),
    ];
  }

  SubscriptionBloc() : super(const SubscriptionInitial()) {
    on<LoadActiveSubscriptions>(_onLoadActiveSubscriptions);
    on<LoadSubscriptionPlans>(_onLoadSubscriptionPlans);
    on<LoadSubscriptionHistory>(_onLoadSubscriptionHistory);
    on<CreateSubscription>(_onCreateSubscription);
    on<CancelSubscription>(_onCancelSubscription);
    on<PauseSubscription>(_onPauseSubscription);
    on<ResumeSubscription>(_onResumeSubscription);
  }

  Future<void> _onLoadActiveSubscriptions(
    LoadActiveSubscriptions event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());

    try {
      // Check if user has internet connection
      if (!await userRepository.isInternetAvailable()) {
        // Try to load from SharedPreferences as fallback
        final cachedSubscription = await _loadFromCache();
        if (cachedSubscription != null) {
          emit(SubscriptionLoaded(subscription: cachedSubscription));
          return;
        }
        emit(const SubscriptionError(message: 'No internet connection'));
        return;
      }

      // Make API call to your Spring Boot backend to get active subscriptions
      // For now, simulating API call - replace with actual implementation
      await Future.delayed(const Duration(seconds: 1));

      // Check if user has an active subscription
      if (userRepository.user.id.isNotEmpty) {
        // In real implementation, call your subscription API endpoint
        // Example: GET /api/subscriptions/active?userId=${userRepository.user.id}

        // Mock active subscription for demo
        final mockSubscription = ActiveSubscription(
          id: 'sub_${userRepository.user.id}',
          plan: _getDefaultSubscriptionPlan(),
          status: 'active',
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 25)),
          nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
          totalDeliveries: 30,
          completedDeliveries: 5,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now(),
        );

        // Cache the subscription data
        await _saveToCache(mockSubscription);

        emit(SubscriptionLoaded(subscription: mockSubscription));
      } else {
        emit(const SubscriptionEmpty());
      }
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionPlans(
    LoadSubscriptionPlans event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());

    try {
      // Load available subscription plans from your backend or use static data
      await Future.delayed(const Duration(milliseconds: 500));

      final plans = _getDefaultSubscriptionPlans();
      emit(SubscriptionPlansLoaded(plans: plans));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onLoadSubscriptionHistory(
    LoadSubscriptionHistory event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());

    try {
      // Load user's subscription history from your backend
      // Example: GET /api/subscriptions/history?userId=${userRepository.user.id}
      await Future.delayed(const Duration(seconds: 1));

      // Mock subscription history for demo
      final subscriptions = <ActiveSubscription>[
        ActiveSubscription(
          id: 'sub_current',
          plan: _getDefaultSubscriptionPlan(planID: 1, name: 'Premium'),
          status: 'active',
          startDate: DateTime.now().subtract(const Duration(days: 5)),
          endDate: DateTime.now().add(const Duration(days: 25)),
          nextDeliveryDate: DateTime.now().add(const Duration(days: 1)),
          totalDeliveries: 30,
          completedDeliveries: 5,
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
          updatedAt: DateTime.now(),
        ),
        ActiveSubscription(
          id: 'sub_previous',
          plan: _getDefaultSubscriptionPlan(planID: 2, name: 'Signature'),
          status: 'completed',
          startDate: DateTime.now().subtract(const Duration(days: 60)),
          endDate: DateTime.now().subtract(const Duration(days: 30)),
          nextDeliveryDate: null,
          totalDeliveries: 15,
          completedDeliveries: 15,
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now().subtract(const Duration(days: 30)),
        ),
      ];

      emit(SubscriptionListLoaded(subscriptions: subscriptions));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onCreateSubscription(
    CreateSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());

    try {
      // Create new subscription via your backend API
      // Example: POST /api/subscriptions with Chargebee integration
      await Future.delayed(const Duration(seconds: 2));

      // Get the selected plan based on planId
      final selectedPlan = _getDefaultSubscriptionPlan(planID: event.planId);

      final newSubscription = ActiveSubscription(
        id: 'sub_${DateTime.now().millisecondsSinceEpoch}',
        plan: selectedPlan,
        status: 'active',
        startDate: event.startDate,
        endDate: event.startDate.add(const Duration(days: 30)),
        nextDeliveryDate: event.startDate.add(const Duration(days: 1)),
        totalDeliveries: 30,
        completedDeliveries: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Cache the new subscription
      await _saveToCache(newSubscription);

      emit(SubscriptionCreated(subscription: newSubscription));
      emit(SubscriptionLoaded(subscription: newSubscription));
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onCancelSubscription(
    CancelSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    emit(const SubscriptionLoading());

    try {
      // Cancel subscription via your backend API
      // Example: POST /api/subscriptions/{id}/cancel
      await Future.delayed(const Duration(seconds: 1));

      // Clear cached subscription
      await _clearCache();

      emit(SubscriptionCancelled(subscriptionId: event.subscriptionId));
      emit(const SubscriptionEmpty());
    } catch (e) {
      emit(SubscriptionError(message: e.toString()));
    }
  }

  Future<void> _onPauseSubscription(
    PauseSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      emit(const SubscriptionLoading());

      try {
        // Pause subscription via your backend API
        await Future.delayed(const Duration(seconds: 1));

        final currentSubscription = (state as SubscriptionLoaded).subscription;
        final pausedSubscription = currentSubscription.copyWith(
          status: 'paused',
          pausedUntil: event.pauseUntil,
          updatedAt: DateTime.now(),
        );

        // Update cache
        await _saveToCache(pausedSubscription);

        emit(SubscriptionPaused(subscription: pausedSubscription));
        emit(SubscriptionLoaded(subscription: pausedSubscription));
      } catch (e) {
        emit(SubscriptionError(message: e.toString()));
      }
    }
  }

  Future<void> _onResumeSubscription(
    ResumeSubscription event,
    Emitter<SubscriptionState> emit,
  ) async {
    if (state is SubscriptionLoaded) {
      emit(const SubscriptionLoading());

      try {
        // Resume subscription via your backend API
        await Future.delayed(const Duration(seconds: 1));

        final currentSubscription = (state as SubscriptionLoaded).subscription;
        final resumedSubscription = currentSubscription.copyWith(
          status: 'active',
          pausedUntil: null,
          updatedAt: DateTime.now(),
        );

        // Update cache
        await _saveToCache(resumedSubscription);

        emit(SubscriptionResumed(subscription: resumedSubscription));
        emit(SubscriptionLoaded(subscription: resumedSubscription));
      } catch (e) {
        emit(SubscriptionError(message: e.toString()));
      }
    }
  }

  // Cache management using SharedPreferences
  Future<void> _saveToCache(ActiveSubscription subscription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = jsonEncode(subscription.toJson());
      await prefs.setString('active_subscription', subscriptionJson);
    } catch (e) {
      // Handle cache save error silently
    }
  }

  Future<ActiveSubscription?> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final subscriptionJson = prefs.getString('active_subscription');
      if (subscriptionJson != null) {
        final subscriptionMap =
            jsonDecode(subscriptionJson) as Map<String, dynamic>;
        return ActiveSubscription.fromJson(subscriptionMap);
      }
    } catch (e) {
      // Handle cache load error silently
    }
    return null;
  }

  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('active_subscription');
    } catch (e) {
      // Handle cache clear error silently
    }
  }
}
