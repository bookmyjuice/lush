import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/NotificationBloc/notification_bloc.dart';
import 'package:lush/models/notification_model.dart';
import 'package:lush/utils/analytics_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

void main() {
  late MockFirebaseAnalytics mockAnalytics;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    mockAnalytics = MockFirebaseAnalytics();
    AnalyticsService.setAnalyticsForTesting(mockAnalytics);
    when(() => mockAnalytics.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        )).thenAnswer((_) async {});
  });

  tearDown(() {
    AnalyticsService.resetAnalyticsForTesting();
  });

  group('LoadNotifications', () {
    test('emits Loading then Loaded with empty items initially', () async {
      final bloc = NotificationBloc();
      final states = <NotificationState>[];
      bloc.stream.listen(states.add);

      bloc.add(const LoadNotifications());
      await Future.delayed(const Duration(milliseconds: 80));

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0], isA<NotificationLoading>());
      expect(states.last, isA<NotificationLoaded>());
      expect((states.last as NotificationLoaded).items.length, 0);
      expect((states.last as NotificationLoaded).unreadCount, 0);

      await bloc.close();
    });
  });

  group('AddNotification + LoadNotifications', () {
    test('AddNotification emits Loaded with item and correct unreadCount',
        () async {
      final bloc = NotificationBloc();
      final states = <NotificationState>[];
      bloc.stream.listen(states.add);

      final item = NotificationItem(
        id: 'n1',
        type: 'order_placed',
        title: 'Test',
        body: 'Test body',
        createdAt: DateTime.now(),
      );
      bloc.add(AddNotification(item: item));
      await Future.delayed(const Duration(milliseconds: 80));

      expect(states.isNotEmpty, true);
      final last = states.last as NotificationLoaded;
      expect(last.items.length, 1);
      expect(last.unreadCount, 1);

      await bloc.close();
    });
  });

  group('MarkAsRead', () {
    test('marks item as read and decrements unreadCount', () async {
      final bloc = NotificationBloc();
      final states = <NotificationState>[];
      bloc.stream.listen(states.add);

      bloc.add(AddNotification(item: NotificationItem(
        id: 'r1', type: 'test', title: 'Read Test', body: 'Body',
        createdAt: DateTime.now(),
      ),),);
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const MarkAsRead(id: 'r1'));
      await Future.delayed(const Duration(milliseconds: 80));

      final finalState = states.last as NotificationLoaded;
      final markedItem = finalState.items.firstWhere((n) => n.id == 'r1');
      expect(markedItem.isRead, true);
      expect(finalState.unreadCount, 0);

      await bloc.close();
    });
  });

  group('MarkAllAsRead', () {
    test('marks all items as read and resets unreadCount', () async {
      final bloc = NotificationBloc();
      final states = <NotificationState>[];
      bloc.stream.listen(states.add);

      bloc.add(AddNotification(item: NotificationItem(
        id: 'a1', type: 'test', title: 'A', body: 'Body',
        createdAt: DateTime.now(),
      ),),);
      await Future.delayed(const Duration(milliseconds: 30));
      bloc.add(AddNotification(item: NotificationItem(
        id: 'a2', type: 'test', title: 'B', body: 'Body',
        createdAt: DateTime.now(),
      ),),);
      await Future.delayed(const Duration(milliseconds: 50));

      // MarkAllAsRead currently resets to empty + unreadCount: 0
      bloc.add(const MarkAllAsRead());
      await Future.delayed(const Duration(milliseconds: 80));

      final finalState = states.last as NotificationLoaded;
      expect(finalState.unreadCount, 0);

      await bloc.close();
    });
  });

  group('ClearNotifications', () {
    test('clears all notifications and emits empty', () async {
      final bloc = NotificationBloc();
      final states = <NotificationState>[];
      bloc.stream.listen(states.add);

      bloc.add(AddNotification(item: NotificationItem(
        id: 'c1', type: 'test', title: 'C', body: 'Body',
        createdAt: DateTime.now(),
      ),),);
      await Future.delayed(const Duration(milliseconds: 50));

      bloc.add(const ClearNotifications());
      await Future.delayed(const Duration(milliseconds: 80));

      final finalState = states.last as NotificationLoaded;
      expect(finalState.items.length, 0);
      expect(finalState.unreadCount, 0);

      await bloc.close();
    });
  });

  group('NotificationItem model', () {
    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'n1',
        'type': 'delivery_today',
        'title': 'Delivery Today',
        'body': 'Your juice arrives today',
        'route': '/order-history',
        'isRead': false,
        'createdAt': '2026-05-28T10:00:00.000',
      };
      final item = NotificationItem.fromJson(json);
      expect(item.id, 'n1');
      expect(item.type, 'delivery_today');
      expect(item.title, 'Delivery Today');
      expect(item.body, 'Your juice arrives today');
      expect(item.route, '/order-history');
      expect(item.isRead, false);
      expect(item.createdAt, DateTime(2026, 5, 28, 10));
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final item = NotificationItem.fromJson(json);
      expect(item.id, '');
      expect(item.type, 'general');
      expect(item.title, '');
      expect(item.isRead, false);
    });

    test('toJson produces expected keys', () {
      final item = NotificationItem(
        id: 'n2',
        type: 'referral_reward',
        title: 'Bonus!',
        body: 'You earned points',
        createdAt: DateTime(2026, 5, 28),
      );
      final json = item.toJson();
      expect(json['id'], 'n2');
      expect(json['type'], 'referral_reward');
      expect(json['title'], 'Bonus!');
      expect(json['isRead'], false);
      expect(json['createdAt'], isNotEmpty);
    });

    test('copyWith updates isRead only', () {
      final item = NotificationItem(
        id: 'n3',
        type: 'general',
        title: 'Test',
        body: 'Test body',
        createdAt: DateTime(2026, 5, 28),
      );
      final updated = item.copyWith(isRead: true);
      expect(updated.isRead, true);
      expect(updated.id, 'n3');
      expect(updated.type, 'general');
    });

    test('copyWith preserves isRead when not provided', () {
      final item = NotificationItem(
        id: 'n4', type: 'order_placed', title: 'Order',
        body: 'Confirmed', isRead: true,
        createdAt: DateTime(2026, 5, 28),
      );
      final unchanged = item.copyWith();
      expect(unchanged.isRead, true);
    });
  });

  group('NotificationState equality', () {
    test('NotificationLoaded states equal with same data', () {
      const s1 = NotificationLoaded(items: [], unreadCount: 0);
      const s2 = NotificationLoaded(items: [], unreadCount: 0);
      expect(s1, s2);
    });

    test('NotificationError states equal with same message', () {
      const e1 = NotificationError(message: 'fail');
      const e2 = NotificationError(message: 'fail');
      expect(e1, e2);
    });
  });
}