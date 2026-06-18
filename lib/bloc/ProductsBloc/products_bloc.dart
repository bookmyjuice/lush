import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../repositories/products_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Events
abstract class ProductsEvent extends Equatable {
  const ProductsEvent();
  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductsEvent {
  const LoadProducts();
}

class LoadRecommendedProducts extends ProductsEvent {
  const LoadRecommendedProducts();
}

class LoadProductsByCategory extends ProductsEvent {
  final String category;
  const LoadProductsByCategory({required this.category});
  @override
  List<Object> get props => [category];
}

class SearchProducts extends ProductsEvent {
  final String query;
  const SearchProducts({required this.query});
  @override
  List<Object> get props => [query];
}

class LoadProductDetails extends ProductsEvent {
  final String juiceId;
  const LoadProductDetails({required this.juiceId});
  @override
  List<Object> get props => [juiceId];
}

class RefreshProducts extends ProductsEvent {
  const RefreshProducts();
}

/// Price sub-model matching bmjServer PriceResponse
class ProductPrice extends Equatable {
  final String itemPriceId;
  final String currencyCode;
  final double unitAmount;
  final String? period;
  final String? periodUnit;

  const ProductPrice({
    required this.itemPriceId,
    this.currencyCode = 'INR',
    this.unitAmount = 0.0,
    this.period,
    this.periodUnit,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      itemPriceId: json['itemPriceId'] as String? ?? '',
      currencyCode: json['currencyCode'] as String? ?? 'INR',
      unitAmount: (json['unitAmount'] as num?)?.toDouble() ?? 0.0,
      period: json['period'] as String?,
      periodUnit: json['periodUnit'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'itemPriceId': itemPriceId,
        'currencyCode': currencyCode,
        'unitAmount': unitAmount,
        'period': period,
        'periodUnit': periodUnit,
      };

  @override
  List<Object?> get props =>
      [itemPriceId, currencyCode, unitAmount, period, periodUnit];
}

/// Enhanced product model — matches bmjServer ProductResponse JSON
class Product extends Equatable {
  final String id;
  final String name;
  final String family;
  final String description;
  final String imageUrl;
  final String chargebeeItemId;
  final List<ProductPrice> prices;
  final bool isFeatured;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final List<String>? nutritionFacts;
  final double price;
  final String currency;

  const Product({
    required this.id,
    required this.name,
    this.family = 'juice',
    this.description = '',
    this.imageUrl = '',
    this.chargebeeItemId = '',
    this.prices = const [],
    this.isFeatured = false,
    this.isAvailable = true,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.nutritionFacts,
    this.price = 0.0,
    this.currency = 'INR',
  });

  factory Product.fromServerJson(Map<String, dynamic> json) {
    List<ProductPrice> prices = [];
    if (json['prices'] != null && json['prices'] is List) {
      prices = (json['prices'] as List)
          .map((p) => ProductPrice.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    double price = 0.0;
    String currency = 'INR';
    if (prices.isNotEmpty) {
      final firstPrice = prices.first;
      price = firstPrice.unitAmount;
      currency = firstPrice.currencyCode;
    }

    return Product(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      family: json['family'] as String? ?? 'juice',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      chargebeeItemId: json['chargebeeItemId'] as String? ?? '',
      prices: prices,
      isFeatured:
          json['featured'] as bool? ?? json['isFeatured'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      price: price,
      currency: currency,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'family': family,
        'description': description,
        'imageUrl': imageUrl,
        'chargebeeItemId': chargebeeItemId,
        'prices': prices.map((p) => p.toJson()).toList(),
        'isFeatured': isFeatured,
        'isAvailable': isAvailable,
        'rating': rating,
        'reviewCount': reviewCount,
        'price': price,
        'currency': currency,
        'nutritionFacts': nutritionFacts,
      };

  factory Product.fromJson(Map<String, dynamic> json) =>
      Product.fromServerJson(json);

  @override
  List<Object?> get props => [
        id,
        name,
        family,
        description,
        imageUrl,
        chargebeeItemId,
        prices,
        isFeatured,
        isAvailable,
        rating,
        reviewCount,
        price,
        currency,
        nutritionFacts,
      ];
}

// States
abstract class ProductsState extends Equatable {
  const ProductsState();
  @override
  List<Object> get props => [];
}

class ProductsInitial extends ProductsState {
  const ProductsInitial();
}

class ProductsLoading extends ProductsState {
  const ProductsLoading();
}

class ProductsLoaded extends ProductsState {
  final List<Product> products;
  const ProductsLoaded({required this.products});
  @override
  List<Object> get props => [products];
}

class RecommendedProductsLoaded extends ProductsState {
  final List<Product> products;
  const RecommendedProductsLoaded({required this.products});
  @override
  List<Object> get props => [products];
}

class ProductDetailsLoaded extends ProductsState {
  final Product product;
  const ProductDetailsLoaded({required this.product});
  @override
  List<Object> get props => [product];
}

class ProductsError extends ProductsState {
  final String message;
  const ProductsError({required this.message});
  @override
  List<Object> get props => [message];
}

class ProductsEmpty extends ProductsState {
  const ProductsEmpty();
}

class ProductsSearchResults extends ProductsState {
  final List<Product> products;
  final String query;
  const ProductsSearchResults({required this.products, required this.query});
  @override
  List<Object> get props => [products, query];
}

// BLoC
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepository _repository;

  ProductsBloc({ProductsRepository? repository})
      : _repository = repository ?? ProductsRepository(),
        super(const ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<LoadRecommendedProducts>(_onLoadRecommendedProducts);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
    on<SearchProducts>(_onSearchProducts);
    on<LoadProductDetails>(_onLoadProductDetails);
    on<RefreshProducts>(_onRefreshProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    try {
      final jsonList = await _repository.getProducts();
      final products = jsonList.map(Product.fromServerJson).toList();
      await _saveToCache(products);
      if (isClosed) return;
      emit(ProductsLoaded(products: products));
    } catch (e) {
      final cached = await _loadFromCache();
      if (isClosed) return;
      if (cached.isNotEmpty) {
        emit(ProductsLoaded(products: cached));
      } else {
        emit(ProductsError(message: 'Failed to load products: $e'));
      }
    }
  }

  Future<void> _onLoadRecommendedProducts(
    LoadRecommendedProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    try {
      final jsonList = await _repository.getFeaturedProducts();
      final products = jsonList.map(Product.fromServerJson).toList();
      final recommended = products.take(3).toList();
      if (isClosed) return;
      emit(RecommendedProductsLoaded(products: recommended));
    } catch (e) {
      try {
        final allJson = await _repository.getProducts();
        final allProducts =
            allJson.map(Product.fromServerJson).toList();
        final featured =
            allProducts.where((p) => p.isFeatured).take(3).toList();
        if (isClosed) return;
        emit(RecommendedProductsLoaded(products: featured));
      } catch (e2) {
        if (isClosed) return;
        emit(ProductsError(message: 'Failed to load recommendations: $e'));
      }
    }
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    try {
      final family = _mapCategoryToFamily(event.category);
      final jsonList = await _repository.getProductsByFamily(family);
      final products = jsonList.map(Product.fromServerJson).toList();
      if (isClosed) return;
      if (products.isEmpty) {
        emit(const ProductsEmpty());
      } else {
        emit(ProductsLoaded(products: products));
      }
    } catch (e) {
      try {
        final allJson = await _repository.getProducts();
        final allProducts =
            allJson.map(Product.fromServerJson).toList();
        final family = _mapCategoryToFamily(event.category);
        final filtered =
            allProducts.where((p) => p.family == family).toList();
        if (isClosed) return;
        if (filtered.isEmpty) {
          emit(const ProductsEmpty());
        } else {
          emit(ProductsLoaded(products: filtered));
        }
      } catch (e2) {
        if (isClosed) return;
        emit(
            ProductsError(message: 'Failed to load products by category: $e'),);
      }
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    try {
      final jsonList = await _repository.searchProducts(event.query);
      final products = jsonList.map(Product.fromServerJson).toList();
      if (isClosed) return;
      emit(ProductsSearchResults(products: products, query: event.query));
    } catch (e) {
      if (isClosed) return;
      emit(ProductsError(message: 'Search failed: $e'));
    }
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    try {
      final json = await _repository.getProductById(event.juiceId);
      final product = Product.fromServerJson(json);
      if (isClosed) return;
      emit(ProductDetailsLoaded(product: product));
    } catch (e) {
      if (isClosed) return;
      emit(ProductsError(message: 'Product not found: $e'));
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_products');
      final jsonList = await _repository.getProducts();
      final products = jsonList.map(Product.fromServerJson).toList();
      await _saveToCache(products);
      if (isClosed) return;
      emit(ProductsLoaded(products: products));
    } catch (e) {
      if (isClosed) return;
      emit(ProductsError(message: 'Refresh failed: $e'));
    }
  }

  String _mapCategoryToFamily(String category) {
    switch (category.toLowerCase()) {
      case 'citrus':
      case 'fruit':
      case 'blend':
        return 'juice';
      case 'vegetable':
      case 'green':
        return 'detox';
      default:
        return category.toLowerCase();
    }
  }

  Future<void> _saveToCache(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final js = jsonEncode(products.map((p) => p.toJson()).toList());
      await prefs.setString('cached_products', js);
      await prefs.setInt(
          'products_cache_timestamp', DateTime.now().millisecondsSinceEpoch,);
    } catch (_) {}
  }

  Future<List<Product>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('cached_products');
      final timestamp = prefs.getInt('products_cache_timestamp') ?? 0;
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      const oneHour = 60 * 60 * 1000;
      if (productsJson != null && cacheAge < oneHour) {
        final list = jsonDecode(productsJson) as List;
        return list
            .map((j) => Product.fromJson(j as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return [];
  }
}