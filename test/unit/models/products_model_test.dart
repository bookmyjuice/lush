import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/ProductsBloc/products_bloc.dart';

void main() {
  group('ProductPrice model', () {
    test('constructor sets fields correctly', () {
      const price = ProductPrice(
        itemPriceId: 'price_001',
        unitAmount: 199.0,
        period: '1',
        periodUnit: 'month',
      );
      expect(price.itemPriceId, 'price_001');
      expect(price.currencyCode, 'INR');
      expect(price.unitAmount, 199.0);
      expect(price.period, '1');
      expect(price.periodUnit, 'month');
    });

    test('toJson returns correct keys', () {
      const price = ProductPrice(
        itemPriceId: 'p_2',
        currencyCode: 'USD',
        unitAmount: 5.99,
      );
      final json = price.toJson();
      expect(json['itemPriceId'], 'p_2');
      expect(json['currencyCode'], 'USD');
      expect(json['unitAmount'], 5.99);
    });
  });

  group('Product model', () {
    test('fromJson delegates to fromServerJson', () {
      final json = {
        'id': 'juice_test',
        'name': 'Test Juice',
        'family': 'juice',
        'prices': [],
        'isFeatured': true,
        'isAvailable': true,
      };
      final product = Product.fromJson(json);
      expect(product.id, 'juice_test');
      expect(product.name, 'Test Juice');
      expect(product.family, 'juice');
      expect(product.isFeatured, true);
      expect(product.isAvailable, true);
    });
  });
}