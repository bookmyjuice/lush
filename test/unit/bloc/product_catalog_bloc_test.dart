import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart';
import 'package:lush/bloc/ProductsBloc/products_bloc.dart';
import 'package:lush/views/models/item.dart';

void main() {
  group('Product.fromServerJson catalog key parsing', () {
    test('parses camelCase keys from bmjServer Jackson response', () {
      final json = {
        'id': 'juice_001',
        'name': 'Watermelon Juice',
        'family': 'juice',
        'prices': [
          {
            'itemPriceId': 'price_001',
            'currencyCode': 'INR',
            'unitAmount': 99.0,
            'period': null,
            'periodUnit': null,
          }
        ],
        'isFeatured': true,
        'isAvailable': true,
      };

      final product = Product.fromServerJson(json);
      expect(product.id, 'juice_001');
      expect(product.name, 'Watermelon Juice');
      expect(product.family, 'juice');
      expect(product.price, 99.0);
      expect(product.currency, 'INR');
      expect(product.prices.length, 1);
    });

    test('toJson produces camelCase keys matching bmjServer contract', () {
      final product = Product(
        id: 'test_1',
        name: 'Test',
        family: 'juice',
        description: 'A test juice',
        imageUrl: 'assets/test.png',
        chargebeeItemId: 'test_1',
        prices: const [
          ProductPrice(
            itemPriceId: 'p_1',
            currencyCode: 'INR',
            unitAmount: 149.0,
          ),
        ],
        isFeatured: false,
        isAvailable: true,
        price: 149.0,
        currency: 'INR',
      );

      final json = product.toJson();
      expect(json['id'], 'test_1');
      expect(json['name'], 'Test');
      expect(json['family'], 'juice');
      expect(json['isFeatured'], false);
      expect(json['prices'], isA<List>());
      expect((json['prices'] as List).first['itemPriceId'], 'p_1');
      expect((json['prices'] as List).first['currencyCode'], 'INR');
      expect((json['prices'] as List).first['unitAmount'], 149.0);
    });
  });

  group('CatalogItem', () {
    test('CatalogItem holds correct field accessors', () {
      final item = Item(id: 'j1', servingSize: '500ml');
      final catalogItem = CatalogItem(
        item: item,
        category: 'Delight',
        prices: [],
        isAvailable: true,
      );

      expect(catalogItem.id, 'j1');
      expect(catalogItem.category, 'Delight');
      expect(catalogItem.prices.length, 0);
      expect(catalogItem.isAvailable, true);
    });

    test('CatalogLoaded state holds correct item count', () {
      final items = List.generate(3, (i) {
        return CatalogItem(
          item: Item(id: 'j$i', servingSize: '500ml'),
          category: 'Delight',
          prices: [],
          isAvailable: true,
        );
      });

      final state = ProductCatalogLoaded(
        items: items,
        categories: ['Delight'],
        sizes: ['500ml'],
      );

      expect(state.items.length, 3);
      expect(state.categories, ['Delight']);
      expect(state.sizes, ['500ml']);
    });
  });
}