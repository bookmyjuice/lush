/// Unit tests for [OrderSummary], [OrderDetail], and [OrderLineItem] models.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:lush/models/order_detail.dart';
import 'package:lush/models/order_line_item.dart';
import 'package:lush/models/order_summary.dart';
import 'package:lush/views/models/address.dart';

void main() {
  group('OrderLineItem', () {
    test('constructor sets fields correctly', () {
      const item = OrderLineItem(
        itemId: 'item_1',
        itemName: 'Mango Juice',
        quantity: 2,
        unitPrice: 150.0,
        lineTotal: 300.0,
      );
      expect(item.itemId, 'item_1');
      expect(item.itemName, 'Mango Juice');
      expect(item.quantity, 2);
      expect(item.unitPrice, 150.0);
      expect(item.lineTotal, 300.0);
    });

    test('fromJson parses fields correctly', () {
      final json = {
        'itemId': 'item_2',
        'itemName': 'Apple Juice',
        'quantity': 1,
        'unitPrice': 180.0,
        'lineTotal': 180.0,
      };
      final item = OrderLineItem.fromJson(json);
      expect(item.itemId, 'item_2');
      expect(item.itemName, 'Apple Juice');
      expect(item.quantity, 1);
      expect(item.unitPrice, 180.0);
      expect(item.lineTotal, 180.0);
    });

    test('toJson returns correct map', () {
      const item = OrderLineItem(
        itemId: 'i3', itemName: 'Carrot Juice',
        quantity: 3, unitPrice: 120.0, lineTotal: 360.0,
      );
      final json = item.toJson();
      expect(json['itemId'], 'i3');
      expect(json['itemName'], 'Carrot Juice');
      expect(json['quantity'], 3);
      expect(json['unitPrice'], 120.0);
      expect(json['lineTotal'], 360.0);
    });

    test('fromJson and toJson round-trip', () {
      final original = {
        'itemId': 'i4', 'itemName': 'Detox Water',
        'quantity': 5, 'unitPrice': 100.0, 'lineTotal': 500.0,
      };
      final item = OrderLineItem.fromJson(original);
      final output = item.toJson();
      expect(output, original);
    });
  });

  group('OrderSummary', () {
    final lineItem = OrderLineItem(
      itemId: 'i1', itemName: 'Juice',
      quantity: 2, unitPrice: 150.0, lineTotal: 300.0,
    );

    test('constructor sets fields correctly', () {
      final now = DateTime(2026, 6, 10);
      final summary = OrderSummary(
        id: 'ord_1',
        date: now,
        items: [lineItem],
        total: 300.0,
        currency: 'INR',
        status: 'delivered',
      );
      expect(summary.id, 'ord_1');
      expect(summary.date, now);
      expect(summary.items.length, 1);
      expect(summary.total, 300.0);
      expect(summary.currency, 'INR');
      expect(summary.status, 'delivered');
    });

    test('constructor defaults currency to INR', () {
      final summary = OrderSummary(
        id: 'ord_2', date: DateTime.now(),
        items: [], total: 0.0, status: 'placed',
      );
      expect(summary.currency, 'INR');
    });

    test('fromJson parses fields correctly', () {
      final json = {
        'id': 'ord_3',
        'date': '2026-06-10T10:00:00.000',
        'items': [
          {'itemId': 'i1', 'itemName': 'Juice', 'quantity': 1, 'unitPrice': 100.0, 'lineTotal': 100.0},
        ],
        'total': 100.0,
        'currency': 'USD',
        'status': 'placed',
      };
      final summary = OrderSummary.fromJson(json);
      expect(summary.id, 'ord_3');
      expect(summary.date, DateTime(2026, 6, 10, 10, 0, 0));
      expect(summary.items.length, 1);
      expect(summary.total, 100.0);
      expect(summary.currency, 'USD');
      expect(summary.status, 'placed');
    });

    test('toJson returns correct map', () {
      final summary = OrderSummary(
        id: 'ord_4', date: DateTime(2026, 6, 10),
        items: [lineItem], total: 300.0,
        status: 'delivered',
      );
      final json = summary.toJson();
      expect(json['id'], 'ord_4');
      expect(json['total'], 300.0);
      expect((json['items'] as List).length, 1);
    });

    test('formattedDate returns "10 Jun 2026"', () {
      final summary = OrderSummary(
        id: 'ord_5', date: DateTime(2026, 6, 10),
        items: [], total: 0.0, status: 'placed',
      );
      expect(summary.formattedDate, '10 Jun 2026');
    });

    test('itemCount sums quantities', () {
      final summary = OrderSummary(
        id: 'ord_6', date: DateTime.now(),
        items: [
          OrderLineItem(itemId: 'a', itemName: 'A', quantity: 2, unitPrice: 50.0, lineTotal: 100.0),
          OrderLineItem(itemId: 'b', itemName: 'B', quantity: 3, unitPrice: 30.0, lineTotal: 90.0),
        ],
        total: 190.0, status: 'placed',
      );
      expect(summary.itemCount, 5);
    });

    test('itemCount returns 0 for empty items', () {
      final summary = OrderSummary(
        id: 'ord_7', date: DateTime.now(),
        items: [], total: 0.0, status: 'placed',
      );
      expect(summary.itemCount, 0);
    });

    test('fromJson and toJson round-trip', () {
      final originalJson = {
        'id': 'ord_8',
        'date': '2026-06-10T10:00:00.000',
        'items': [
          {'itemId': 'i1', 'itemName': 'Juice', 'quantity': 1, 'unitPrice': 100.0, 'lineTotal': 100.0},
        ],
        'total': 100.0,
        'currency': 'INR',
        'status': 'placed',
      };
      final summary = OrderSummary.fromJson(originalJson);
      final outputJson = summary.toJson();
      expect(outputJson['id'], 'ord_8');
      expect(outputJson['status'], 'placed');
    });
  });

  group('OrderDetail', () {
    final lineItem = OrderLineItem(
      itemId: 'i1', itemName: 'Juice',
      quantity: 2, unitPrice: 150.0, lineTotal: 300.0,
    );
    final address = Address(
      firstName: 'Test', lastName: 'User', phone: '9876543210',
      addr: '42 MG Road', extendedAddr: 'Indiranagar', extendedAddr2: '',
      city: 'Bangalore', stateCode: 'KA', zip: '560038',
      validationStatus: true, subscriptionId: '',
    );

    test('constructor sets fields correctly', () {
      final detail = OrderDetail(
        id: 'det_1', date: DateTime(2026, 6, 10),
        status: 'delivered', lineItems: [lineItem],
        subtotal: 250.0, deliveryFee: 50.0, total: 300.0,
        currency: 'INR', deliveryAddress: address,
      );
      expect(detail.id, 'det_1');
      expect(detail.status, 'delivered');
      expect(detail.lineItems.length, 1);
      expect(detail.subtotal, 250.0);
      expect(detail.deliveryFee, 50.0);
      expect(detail.total, 300.0);
      expect(detail.currency, 'INR');
    });

    test('constructor defaults currency to INR', () {
      final detail = OrderDetail(
        id: 'det_2', date: DateTime.now(), status: 'placed',
        lineItems: [], subtotal: 0.0, deliveryFee: 0.0, total: 0.0,
        deliveryAddress: address,
      );
      expect(detail.currency, 'INR');
    });

    test('fromJson parses fields correctly', () {
      final json = {
        'id': 'det_3',
        'date': '2026-06-10T10:00:00.000',
        'status': 'shipped',
        'lineItems': [
          {'itemId': 'i1', 'itemName': 'Juice', 'quantity': 1, 'unitPrice': 200.0, 'lineTotal': 200.0},
        ],
        'subtotal': 200.0,
        'deliveryFee': 50.0,
        'total': 250.0,
        'currency': 'INR',
        'deliveryAddress': {
          'first_name': 'Test', 'last_name': 'User', 'phone': '9876543210',
          'line1': '42 MG Road', 'line2': 'Indiranagar', 'line3': '',
          'city': 'Bangalore', 'state': 'KA', 'zip': '560038',
        },
      };
      final detail = OrderDetail.fromJson(json);
      expect(detail.id, 'det_3');
      expect(detail.status, 'shipped');
      expect(detail.lineItems.length, 1);
      expect(detail.subtotal, 200.0);
      expect(detail.deliveryFee, 50.0);
      expect(detail.total, 250.0);
    });

    test('toJson returns correct map', () {
      final detail = OrderDetail(
        id: 'det_4', date: DateTime(2026, 6, 10), status: 'delivered',
        lineItems: [lineItem], subtotal: 250.0, deliveryFee: 50.0,
        total: 300.0, deliveryAddress: address,
      );
      final json = detail.toJson();
      expect(json['id'], 'det_4');
      expect(json['status'], 'delivered');
      expect(json['subtotal'], 250.0);
      expect(json['deliveryFee'], 50.0);
      expect(json['total'], 300.0);
    });

    test('fromJson and toJson round-trip', () {
      final originalJson = {
        'id': 'det_5',
        'date': '2026-06-10T10:00:00.000',
        'status': 'placed',
        'lineItems': [
          {'itemId': 'i1', 'itemName': 'Juice', 'quantity': 1, 'unitPrice': 100.0, 'lineTotal': 100.0},
        ],
        'subtotal': 100.0,
        'deliveryFee': 30.0,
        'total': 130.0,
        'currency': 'INR',
        'deliveryAddress': {
          'first_name': 'T', 'last_name': 'U', 'phone': '999',
          'line1': 'Addr', 'line2': '', 'line3': '',
          'city': 'City', 'state': 'ST', 'zip': '123',
        },
      };
      final detail = OrderDetail.fromJson(originalJson);
      final outputJson = detail.toJson();
      expect(outputJson['id'], 'det_5');
      expect(outputJson['total'], 130.0);
    });
  });
}