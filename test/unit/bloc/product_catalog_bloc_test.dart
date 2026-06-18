import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart' as cart;
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart';
import 'package:lush/bloc/ProductsBloc/products_bloc.dart' hide SearchProducts;
import 'package:lush/get_it.dart';
import 'package:lush/views/models/item.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

class MockCartBloc extends Mock implements CartBloc {}

class _FakeAddToCart extends Fake implements cart.AddToCart {}

void main() {
  late MockUserRepository mockUserRepo;
  late MockCartBloc mockCartBloc;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(_FakeAddToCart());
  });

  setUp(() {
    mockUserRepo = MockUserRepository();
    mockCartBloc = MockCartBloc();

    if (getIt.isRegistered<UserRepository>()) {
      getIt.unregister<UserRepository>();
    }
    getIt.registerSingleton<UserRepository>(mockUserRepo);
  });

  tearDown(() {
    if (getIt.isRegistered<UserRepository>()) {
      getIt.unregister<UserRepository>();
    }
  });

  Map<String, dynamic> _sampleChargeItem({
    String itemId = 'juice_001',
    String name = 'Watermelon',
    String category = 'Delight',
    double price = 99.0,
    String priceName = '500ml Price',
    String currencyCode = 'INR',
    bool enabledForCheckout = true,
  }) {
    return {
      'itemId': itemId,
      'name': name,
      'description': 'Fresh $name juice',
      'imagePath': 'assets/$itemId.png',
      'category': category,
      'startColor': '#FF8C42',
      'endColor': '#FF6B35',
      'calories': 120,
      'meals': ['Vitamin C', 'Antioxidants'],
      'status': 'ACTIVE',
      'enabledForCheckout': enabledForCheckout,
      'enabledInPortal': true,
      'type': 'CHARGE',
      'servingSize': '500ml',
      'prices': [
        {
          'id': '${itemId}_500ml',
          'name': priceName,
          'price': price,
          'currencyCode': currencyCode,
          'period': null,
          'periodUnit': null,
          'status': 'ACTIVE',
        }
      ],
    };
  }

  Item _createItem({
    String id = 'juice_001',
    String name = 'Watermelon',
    double price = 99.0,
  }) {
    return Item(
      id: id,
      name: name,
      description: 'Fresh $name juice',
      imagePath: 'assets/$id.png',
      startColor: '#FF8C42',
      endColor: '#FF6B35',
      meals: ['Vitamin C', 'Antioxidants'],
      kacl: 120,
      status: 'ACTIVE',
      enabledForCheckout: true,
      enabledInPortal: true,
      type: 'CHARGE',
      servingSize: '500ml',
    );
  }

  // ─── LoadProductCatalog ────────────────────────────────────
  group('LoadProductCatalog', () {
    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'emits [Loading, Loaded] on success with items',
      build: () {
        when(() => mockUserRepo.getChargeItems()).thenAnswer(
          (_) async => [
            _sampleChargeItem(itemId: 'juice_001', name: 'Watermelon', category: 'Delight'),
            _sampleChargeItem(itemId: 'juice_002', name: 'ABC Juice', category: 'Delight'),
          ],
        );
        return ProductCatalogBloc(cartBloc: mockCartBloc);
      },
      act: (bloc) => bloc.add(const LoadProductCatalog()),
      expect: () => [
        isA<ProductCatalogLoading>(),
        isA<ProductCatalogLoaded>().having(
          (s) => s.items.length, 'item count', 2,
        ),
      ],
      verify: (bloc) {
        final state = bloc.state;
        expect(state, isA<ProductCatalogLoaded>());
        expect((state as ProductCatalogLoaded).categories, contains('Delight'));
      },
    );

    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'emits [Loading, Empty] when API returns empty list',
      build: () {
        when(() => mockUserRepo.getChargeItems())
            .thenAnswer((_) async => []);
        return ProductCatalogBloc(cartBloc: mockCartBloc);
      },
      act: (bloc) => bloc.add(const LoadProductCatalog()),
      expect: () => [
        isA<ProductCatalogLoading>(),
        isA<ProductCatalogEmpty>(),
      ],
    );

    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'emits [Loading, Error] on API failure',
      build: () {
        when(() => mockUserRepo.getChargeItems())
            .thenThrow(Exception('Server unreachable'));
        return ProductCatalogBloc(cartBloc: mockCartBloc);
      },
      act: (bloc) => bloc.add(const LoadProductCatalog()),
      expect: () => [
        isA<ProductCatalogLoading>(),
        isA<ProductCatalogError>().having(
          (s) => s.message, 'error message', contains('Failed to load products'),
        ),
      ],
    );

    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'extracts multiple categories from items',
      build: () {
        when(() => mockUserRepo.getChargeItems()).thenAnswer(
          (_) async => [
            _sampleChargeItem(itemId: 'j1', name: 'Delight Juice', category: 'Delight'),
            _sampleChargeItem(itemId: 'j2', name: 'Signature Juice', category: 'Signature'),
          ],
        );
        return ProductCatalogBloc(cartBloc: mockCartBloc);
      },
      act: (bloc) => bloc.add(const LoadProductCatalog()),
      expect: () => [
        isA<ProductCatalogLoading>(),
        isA<ProductCatalogLoaded>().having(
          (s) => s.categories, 'categories', ['Delight', 'Signature'],
        ),
      ],
    );
  });

  // ─── FilterByCategory ──────────────────────────────────────
  group('FilterByCategory', () {
    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'emits [Filtered] when filtering by existing category',
      build: () {
        when(() => mockUserRepo.getChargeItems()).thenAnswer(
          (_) async => [
            _sampleChargeItem(itemId: 'j1', name: 'Delight A', category: 'Delight'),
            _sampleChargeItem(itemId: 'j2', name: 'Signature X', category: 'Signature'),
          ],
        );
        return ProductCatalogBloc(cartBloc: mockCartBloc);
      },
      act: (bloc) async {
        bloc.add(const LoadProductCatalog());
        await bloc.stream.first;
        bloc.add(const FilterByCategory(category: 'Signature'));
      },
      expect: () => [
        isA<ProductCatalogLoading>(),
        isA<ProductCatalogLoaded>(),
        isA<ProductCatalogFiltered>().having(
          (s) => s.items.length, 'filtered count', 1,
        ),
      ],
    );

    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'emits [Empty] when filter matches no items',
      build: () {
        when(() => mockUserRepo.getChargeItems()).thenAnswer(
          (_) async => [
            _sampleChargeItem(itemId: 'j1', name: 'Delight A', category: 'Delight'),
          ],
        );
        return ProductCatalogBloc(cartBloc: mockCartBloc);
      },
      act: (bloc) async {
        bloc.add(const LoadProductCatalog());
        await bloc.stream.first;
        bloc.add(const FilterByCategory(category: 'Premium'));
      },
      expect: () => [
        isA<ProductCatalogLoading>(),
        isA<ProductCatalogLoaded>(),
        isA<ProductCatalogEmpty>(),
      ],
    );
  });

  // ─── SearchProducts ────────────────────────────────────────
  group('SearchProducts', () {
    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'emits [Filtered] with matching results',
      build: () {
        when(() => mockUserRepo.getChargeItems()).thenAnswer(
          (_) async => [
            _sampleChargeItem(itemId: 'j1', name: 'Watermelon Juice'),
            _sampleChargeItem(itemId: 'j2', name: 'ABC Juice'),
          ],
        );
        return ProductCatalogBloc(cartBloc: mockCartBloc);
      },
      act: (bloc) async {
        bloc.add(const LoadProductCatalog());
        await bloc.stream.first;
        bloc.add(const SearchProducts(query: 'Watermelon'));
      },
      expect: () => [
        isA<ProductCatalogLoading>(),
        isA<ProductCatalogLoaded>(),
        isA<ProductCatalogFiltered>().having(
          (s) => s.items.length, 'result count', 1,
        ),
      ],
    );

    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'returns to full list on empty query',
      build: () {
        when(() => mockUserRepo.getChargeItems()).thenAnswer(
          (_) async => [
            _sampleChargeItem(itemId: 'j1', name: 'Watermelon Juice'),
            _sampleChargeItem(itemId: 'j2', name: 'ABC Juice'),
          ],
        );
        return ProductCatalogBloc(cartBloc: mockCartBloc);
      },
      act: (bloc) async {
        bloc.add(const LoadProductCatalog());
        await bloc.stream.first;
        bloc.add(const SearchProducts(query: ''));
      },
      expect: () => [
        isA<ProductCatalogLoading>(),
        isA<ProductCatalogLoaded>(),
        isA<ProductCatalogFiltered>().having(
          (s) => s.items.length, 'all items shown', 2,
        ),
      ],
    );
  });

  // ─── AddToCart ─────────────────────────────────────────────
  group('AddToCart', () {
    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'dispatches AddToCart to CartBloc when CartBloc is provided',
      build: () {
        when(() => mockUserRepo.getChargeItems()).thenAnswer(
          (_) async => [_sampleChargeItem()],
        );
        return ProductCatalogBloc(cartBloc: mockCartBloc);
      },
      seed: () => ProductCatalogLoaded(
        items: [],
        categories: const ['Delight'],
        sizes: const ['500ml'],
      ),
      act: (bloc) {
        bloc.add(AddToCart(
          item: _createItem(),
          selectedPrice: ItemPrice(id: 'juice_001_500ml', name: '500ml Price', price: 99.0),
          quantity: 2,
        ));
      },
      expect: () => [],
      verify: (_) {
        verify(() => mockCartBloc.add(any<cart.AddToCart>())).called(1);
      },
    );

    blocTest<ProductCatalogBloc, ProductCatalogState>(
      'does nothing when CartBloc is null',
      build: () {
        when(() => mockUserRepo.getChargeItems()).thenAnswer(
          (_) async => [_sampleChargeItem()],
        );
        return ProductCatalogBloc(cartBloc: null);
      },
      seed: () => ProductCatalogLoaded(
        items: [],
        categories: const ['Delight'],
        sizes: const ['500ml'],
      ),
      act: (bloc) {
        bloc.add(AddToCart(
          item: _createItem(),
          selectedPrice: ItemPrice(id: 'juice_001_500ml', name: '500ml Price', price: 99.0),
          quantity: 1,
        ));
      },
      expect: () => [],
    );
  });

  // ─── CatalogItem model ─────────────────────────────────────
  group('CatalogItem', () {
    test('CatalogItem holds correct field accessors', () {
      final item = Item(id: 'j1', servingSize: '500ml');
      final catalogItem = CatalogItem(
        item: item,
        category: 'Delight',
        prices: const [],
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
          prices: const [],
        );
      });

      final state = ProductCatalogLoaded(
        items: items,
        categories: const ['Delight'],
        sizes: const ['500ml'],
      );

      expect(state.items.length, 3);
      expect(state.categories, ['Delight']);
      expect(state.sizes, ['500ml']);
    });

    test('CatalogItem copyWith preserves unchanged fields', () {
      final original = CatalogItem(
        item: Item(id: 'j1', servingSize: '500ml'),
        category: 'Delight',
        prices: const [],
      );
      final copied = original.copyWith();
      expect(copied.id, 'j1');
      expect(copied.category, 'Delight');
    });

    test('CatalogItem copyWith overrides specified fields', () {
      final original = CatalogItem(
        item: Item(id: 'j1', servingSize: '500ml'),
        category: 'Delight',
        prices: const [],
      );
      final copied = original.copyWith(category: 'Premium', isAvailable: false);
      expect(copied.category, 'Premium');
      expect(copied.isAvailable, false);
      expect(copied.id, 'j1');
    });
  });

  // ─── Product.fromServerJson (from ProductsBloc) ────────────
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
      const product = Product(
        id: 'test_1',
        name: 'Test',
        description: 'A test juice',
        imageUrl: 'assets/test.png',
        chargebeeItemId: 'test_1',
        prices: [
          ProductPrice(
            itemPriceId: 'p_1',
            unitAmount: 149.0,
          ),
        ],
        price: 149.0,
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
}