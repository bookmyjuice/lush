import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/ProductsBloc/products_bloc.dart';
import 'package:lush/repositories/products_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stub repository that returns controlled data with optional error mode.
class FakeProductsRepository implements ProductsRepository {
  final List<Map<String, dynamic>> _products;
  final bool _shouldThrow;

  FakeProductsRepository(this._products, {bool shouldThrow = false})
      : _shouldThrow = shouldThrow;

  @override
  Future<List<Map<String, dynamic>>> getProducts() async {
    if (_shouldThrow) throw Exception('Network error');
    return _products;
  }

  @override
  Future<Map<String, dynamic>> getProductById(String id) async {
    if (_shouldThrow) throw Exception('Not found');
    final match = _products.firstWhere(
      (p) => p['id'] == id,
      orElse: () => throw Exception('Product not found'),
    );
    return match;
  }

  @override
  Future<List<Map<String, dynamic>>> getProductsByFamily(String family) async {
    if (_shouldThrow) throw Exception('Server error');
    return _products.where((p) => p['family'] == family).toList();
  }

  @override
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    if (_shouldThrow) throw Exception('Search error');
    return _products
        .where((p) =>
            (p['name'] as String).toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    if (_shouldThrow) throw Exception('Featured error');
    return _products.where((p) => p['isFeatured'] == true).toList();
  }
}

Map<String, dynamic> _sampleProductJson({
  String id = 'juice_001',
  String name = 'Watermelon',
  String family = 'juice',
  bool isFeatured = false,
  bool isAvailable = true,
  double unitAmount = 99.0,
  String currencyCode = 'INR',
}) {
  return {
    'id': id,
    'name': name,
    'family': family,
    'description': 'Fresh $name juice',
    'imageUrl': 'assets/$id.png',
    'chargebeeItemId': id,
    'prices': [
      {
        'itemPriceId': '${id}_500ml',
        'currencyCode': currencyCode,
        'unitAmount': unitAmount,
        'period': null,
        'periodUnit': null,
      }
    ],
    'isFeatured': isFeatured,
    'isAvailable': isAvailable,
  };
}

void main() {
  late FakeProductsRepository fakeRepo;
  late List<Map<String, dynamic>> sampleProducts;

  setUp(() {
    // Initialize SharedPreferences for tests that use it (Refresh)
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    sampleProducts = [
      _sampleProductJson(id: 'juice_001', name: 'Watermelon', family: 'juice', isFeatured: true),
      _sampleProductJson(id: 'juice_002', name: 'Green Detox', family: 'detox', isFeatured: false),
      _sampleProductJson(id: 'smoothie_001', name: 'Mango Smoothie', family: 'smoothie', isFeatured: true),
      _sampleProductJson(id: 'juice_003', name: 'ABC Juice', family: 'juice', isFeatured: false),
    ];
    fakeRepo = FakeProductsRepository(sampleProducts);
  });

  group('LoadProducts', () {
    blocTest<ProductsBloc, ProductsState>(
      'emits [Loading, Loaded] on success',
      build: () => ProductsBloc(repository: fakeRepo),
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsLoaded>().having(
          (s) => (s as ProductsLoaded).products.length, 'product count', 4),
      ],
    );
  });

  group('LoadProducts API failure', () {
    blocTest<ProductsBloc, ProductsState>(
      'falls back to legacy items on API failure',
      build: () =>
          ProductsBloc(repository: FakeProductsRepository([], shouldThrow: true)),
      act: (bloc) => bloc.add(const LoadProducts()),
      expect: () => [isA<ProductsLoading>(), isA<ProductsState>()],
    );
  });

  group('LoadProductsByCategory', () {
    blocTest<ProductsBloc, ProductsState>(
      'emits [Loading, Loaded(filtered)] for juice',
      build: () => ProductsBloc(repository: fakeRepo),
      act: (bloc) => bloc.add(const LoadProductsByCategory(category: 'juice')),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsLoaded>().having(
          (s) => (s as ProductsLoaded).products.length, 'filtered count', 2),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [Loading, Empty/Loaded] for unknown category',
      build: () => ProductsBloc(repository: fakeRepo),
      act: (bloc) => bloc.add(const LoadProductsByCategory(category: 'unknown')),
      expect: () => [isA<ProductsLoading>(), isA<ProductsState>()],
    );
  });

  group('SearchProducts', () {
    blocTest<ProductsBloc, ProductsState>(
      'emits [Loading, SearchResults] for matching query',
      build: () => ProductsBloc(repository: fakeRepo),
      act: (bloc) => bloc.add(const SearchProducts(query: 'mango')),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsSearchResults>().having(
          (s) => (s as ProductsSearchResults).products.length, 'result count', 1),
      ],
    );
  });

  group('LoadProductDetails', () {
    blocTest<ProductsBloc, ProductsState>(
      'emits [Loading, ProductDetailsLoaded] for existing ID',
      build: () => ProductsBloc(repository: fakeRepo),
      act: (bloc) => bloc.add(const LoadProductDetails(juiceId: 'juice_001')),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductDetailsLoaded>()
            .having((s) => (s as ProductDetailsLoaded).product.id, 'id', 'juice_001'),
      ],
    );

    blocTest<ProductsBloc, ProductsState>(
      'emits [Loading, Error] for non-existent ID',
      build: () => ProductsBloc(repository: fakeRepo),
      act: (bloc) => bloc.add(const LoadProductDetails(juiceId: 'nonexistent')),
      expect: () => [isA<ProductsLoading>(), isA<ProductsError>()],
    );
  });

  group('RefreshProducts', () {
    blocTest<ProductsBloc, ProductsState>(
      'emits [Loading, Loaded(fresh)] on refresh',
      build: () => ProductsBloc(repository: fakeRepo),
      seed: () => ProductsLoaded(products: []),
      act: (bloc) => bloc.add(const RefreshProducts()),
      expect: () => [
        isA<ProductsLoading>(),
        isA<ProductsLoaded>().having(
          (s) => (s as ProductsLoaded).products.length, 'fresh count', 4),
      ],
    );
  });

  group('Product.fromServerJson', () {
    test('parses bmjServer camelCase JSON correctly', () {
      final json = _sampleProductJson();
      final product = Product.fromServerJson(json);
      expect(product.id, 'juice_001');
      expect(product.name, 'Watermelon');
      expect(product.family, 'juice');
      expect(product.isFeatured, false);
      expect(product.isAvailable, true);
      expect(product.price, 99.0);
      expect(product.currency, 'INR');
      expect(product.prices.length, 1);
      expect(product.prices.first.itemPriceId, 'juice_001_500ml');
      expect(product.prices.first.unitAmount, 99.0);
      expect(product.prices.first.currencyCode, 'INR');
    });

    test('handles featured flag correctly', () {
      final json = _sampleProductJson(isFeatured: true);
      final product = Product.fromServerJson(json);
      expect(product.isFeatured, true);
    });

    test('handles missing fields with defaults', () {
      final product = Product.fromServerJson({'id': 'test_1', 'name': 'Test'});
      expect(product.id, 'test_1');
      expect(product.name, 'Test');
      expect(product.family, 'juice');
      expect(product.prices, isEmpty);
      expect(product.price, 0.0);
      expect(product.currency, 'INR');
      expect(product.isFeatured, false);
    });
  });

  group('ProductPrice fromJson', () {
    test('parses all fields correctly', () {
      final price = ProductPrice.fromJson({
        'itemPriceId': 'price_001',
        'currencyCode': 'INR',
        'unitAmount': 199.0,
        'period': '1',
        'periodUnit': 'month',
      });
      expect(price.itemPriceId, 'price_001');
      expect(price.currencyCode, 'INR');
      expect(price.unitAmount, 199.0);
      expect(price.period, '1');
      expect(price.periodUnit, 'month');
    });
  });
}