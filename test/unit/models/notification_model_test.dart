/// Unit tests for [NotificationItem] model.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lush/models/notification_model.dart';

void main() {
  group('NotificationItem', () {
    test('constructor sets fields correctly', () {
      final now = DateTime(2026, 6, 10);
      final item = NotificationItem(
        id: 'notif_1',
        type: 'order_update',
        title: 'Order Shipped',
        body: 'Your order has been shipped!',
        isRead: false,
        createdAt: now,
      );
      expect(item.id, 'notif_1');
      expect(item.type, 'order_update');
      expect(item.title, 'Order Shipped');
      expect(item.body, 'Your order has been shipped!');
      expect(item.isRead, false);
    });

    test('constructor defaults isRead to false', () {
      final now = DateTime.now();
      final item = NotificationItem(
        id: 'n1', type: 'general', title: 'Test', body: 'Body',
        createdAt: now,
      );
      expect(item.isRead, false);
    });

    test('constructor defaults type to "general" via fromJson', () {
      final now = DateTime.now();
      final item = NotificationItem(
        id: 'n1', type: 'general', title: 'Test', body: 'Body',
        createdAt: now,
      );
      expect(item.type, 'general');
    });

    test('fromJson parses all fields correctly', () {
      final json = {
        'id': 'notif_2',
        'type': 'promo',
        'title': '50% Off',
        'body': 'Limited time offer!',
        'route': '/promo',
        'isRead': true,
        'createdAt': '2026-06-10T10:00:00.000',
      };
      final item = NotificationItem.fromJson(json);
      expect(item.id, 'notif_2');
      expect(item.type, 'promo');
      expect(item.title, '50% Off');
      expect(item.body, 'Limited time offer!');
      expect(item.route, '/promo');
      expect(item.isRead, true);
      expect(item.createdAt, DateTime(2026, 6, 10, 10, 0, 0));
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final item = NotificationItem.fromJson(json);
      expect(item.id, '');
      expect(item.type, 'general');
      expect(item.title, '');
      expect(item.body, '');
      expect(item.route, isNull);
      expect(item.isRead, false);
    });

    test('toJson returns correct map', () {
      final now = DateTime(2026, 6, 10);
      final item = NotificationItem(
        id: 'n3', type: 'alert', title: 'Alert', body: 'Test alert',
        route: '/alert', isRead: true, createdAt: now,
      );
      final json = item.toJson();
      expect(json['id'], 'n3');
      expect(json['type'], 'alert');
      expect(json['title'], 'Alert');
      expect(json['body'], 'Test alert');
      expect(json['route'], '/alert');
      expect(json['isRead'], true);
      expect(json['createdAt'], '2026-06-10T00:00:00.000');
    });

    test('fromJson and toJson round-trip', () {
      final originalJson = {
        'id': 'n4',
        'type': 'general',
        'title': 'Welcome',
        'body': 'Welcome to BMJ',
        'route': '/home',
        'isRead': false,
        'createdAt': '2026-06-10T12:00:00.000',
      };
      final item = NotificationItem.fromJson(originalJson);
      final outputJson = item.toJson();
      expect(outputJson['id'], 'n4');
      expect(outputJson['type'], 'general');
      expect(outputJson['title'], 'Welcome');
      expect(outputJson['body'], 'Welcome to BMJ');
      expect(outputJson['route'], '/home');
      expect(outputJson['isRead'], false);
    });

    test('copyWith preserves unchanged fields', () {
      final now = DateTime(2026, 6, 10);
      final original = NotificationItem(
        id: 'n5', type: 'order', title: 'Update', body: 'Body',
        route: '/orders', isRead: false, createdAt: now,
      );
      final copied = original.copyWith();
      expect(copied.id, original.id);
      expect(copied.type, original.type);
      expect(copied.title, original.title);
      expect(copied.body, original.body);
      expect(copied.route, original.route);
      expect(copied.isRead, false);
      expect(copied.createdAt, original.createdAt);
    });

    test('copyWith overrides isRead', () {
      final now = DateTime(2026, 6, 10);
      final original = NotificationItem(
        id: 'n6', type: 'general', title: 'Test', body: 'Body',
        isRead: false, createdAt: now,
      );
      final copied = original.copyWith(isRead: true);
      expect(copied.isRead, true);
      expect(copied.id, original.id);
    });
  });
}