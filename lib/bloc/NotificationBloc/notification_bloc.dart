import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../utils/analytics_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/notification_model.dart';

// Events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object> get props => [];
}

class LoadNotifications extends NotificationEvent {
  const LoadNotifications();
}

class MarkAsRead extends NotificationEvent {
  final String id;
  const MarkAsRead({required this.id});
  @override
  List<Object> get props => [id];
}

class MarkAllAsRead extends NotificationEvent {
  const MarkAllAsRead();
}

class ClearNotifications extends NotificationEvent {
  const ClearNotifications();
}

class AddNotification extends NotificationEvent {
  final NotificationItem item;
  const AddNotification({required this.item});
  @override
  List<Object> get props => [item];
}

// States
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<NotificationItem> items;
  final int unreadCount;

  const NotificationLoaded({
    required this.items,
    required this.unreadCount,
  });

  @override
  List<Object> get props => [items, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError({required this.message});
  @override
  List<Object> get props => [message];
}

// BLoC
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc() : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkAsRead>(_onMarkAsRead);
    on<MarkAllAsRead>(_onMarkAllAsRead);
    on<ClearNotifications>(_onClearNotifications);
    on<AddNotification>(_onAddNotification);
  }

  static const String _storageKey = 'saved_notifications';
  static const int _maxItems = 100;

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    try {
      final items = await _loadFromStorage();
      final unreadCount = items.where((n) => !n.isRead).length;
      if (isClosed) return;
      emit(NotificationLoaded(items: items, unreadCount: unreadCount));
    } catch (e) {
      if (isClosed) return;
      emit(NotificationError(message: 'Failed to load notifications: $e'));
    }
  }

  Future<void> _onMarkAsRead(
    MarkAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;
    final current = (state as NotificationLoaded).items;
    final updated = current.map((n) =>
      n.id == event.id ? n.copyWith(isRead: true) : n,
    ).toList();

    await AnalyticsService.logNotificationTapped(event.id);
    await _saveToStorage(updated);
    if (isClosed) return;
    emit(NotificationLoaded(
      items: updated,
      unreadCount: updated.where((n) => !n.isRead).length,
    ));
  }

  Future<void> _onMarkAllAsRead(
    MarkAllAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    if (state is! NotificationLoaded) return;
    final current = (state as NotificationLoaded).items;
    final updated = current.map((n) => n.copyWith(isRead: true)).toList();

    await _saveToStorage(updated);
    if (isClosed) return;
    emit(const NotificationLoaded(items: [], unreadCount: 0));
  }

  Future<void> _onClearNotifications(
    ClearNotifications event,
    Emitter<NotificationState> emit,
  ) async {
    await _clearStorage();
    if (isClosed) return;
    emit(const NotificationLoaded(items: [], unreadCount: 0));
  }

  Future<void> _onAddNotification(
    AddNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      final current = await _loadFromStorage();
      final updated = [event.item, ...current].take(_maxItems).toList();
      await _saveToStorage(updated);
      final unreadCount = updated.where((n) => !n.isRead).length;
      if (isClosed) return;
      emit(NotificationLoaded(items: updated, unreadCount: unreadCount));
    } catch (e) {
      if (isClosed) return;
      emit(NotificationError(message: 'Failed to add notification: $e'));
    }
  }

  // ──────────────── Storage ────────────────

  Future<List<NotificationItem>> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr == null) return [];
      final list = jsonDecode(jsonStr) as List;
      return list
          .map((j) => NotificationItem.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveToStorage(List<NotificationItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = jsonEncode(items.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {
      // Silently ignore storage failures
    }
  }

  Future<void> _clearStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (_) {
      // Silently ignore
    }
  }
}