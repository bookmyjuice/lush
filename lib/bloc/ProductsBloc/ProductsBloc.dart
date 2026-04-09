import 'dart:ffi';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../views/models/ItemData.dart';
import '../../views/models/Item.dart';
import '../../UserRepository/userRepository.dart';
import '../../services/ItemService.dart';
import '../../getIt.dart';
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

// Enhanced product model that wraps the existing ItemData model
class Product extends Equatable {
  final ItemData item;
  final bool isRecommended;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final double price;
  final String currency;
  final List<String>? nutritionFacts;
  final String? description;
  final String? category;
  final List<ItemPrice>? itemPrices;

  const Product({
    required this.item,
    this.isRecommended = false,
    this.isAvailable = true,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.price = 8.99,
    this.currency = 'USD',
    this.nutritionFacts,
    this.description,
    this.category,
    this.itemPrices,
  });

  // Getters that map to the enhanced dashboard expectations
  String get id => item.itemID.toString();
  String get name => item.titleTxt;
  String get imageUrl => item
      .imagePath; // This should be a valid asset path like 'assets/watermelon.png'
  List<String> get ingredients => item.meals ?? [];
  int get calories => item.kacl;

  // Debug method to print all product details
  void debugPrint() {
    print('Product Details:');
    print('  ID: $id');
    print('  Name: $name');
    print('  ImageUrl: $imageUrl');
    print('  StartColor: ${item.startColor}');
    print('  EndColor: ${item.endColor}');
    print('  Ingredients: $ingredients');
    print('  Calories: $calories');
    print('  Price: $price');
    print('  Rating: $rating');
  }

  Product copyWith({
    ItemData? item,
    bool? isRecommended,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    double? price,
    String? currency,
    List<String>? nutritionFacts,
    String? description,
    String? category,
    List<ItemPrice>? itemPrices,
  }) {
    return Product(
      item: item ?? this.item,
      isRecommended: isRecommended ?? this.isRecommended,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      nutritionFacts: nutritionFacts ?? this.nutritionFacts,
      description: description ?? this.description,
      category: category ?? this.category,
      itemPrices: itemPrices ?? this.itemPrices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemID': item.itemID,
      'isRecommended': isRecommended,
      'isAvailable': isAvailable,
      'rating': rating,
      'reviewCount': reviewCount,
      'price': price,
      'currency': currency,
      'nutritionFacts': nutritionFacts,
      'description': description,
      'category': category,
      'itemPrices': itemPrices
          ?.map((price) => {
                'id': price.id,
                'name': price.name,
                'description': price.description,
                'price': price.price,
                'currencyCode': price.currencyCode,
              })
          .toList(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json, ItemData item) {
    // Parse item prices if available
    List<ItemPrice>? parsedItemPrices;
    if (json.containsKey('itemPrices') && json['itemPrices'] is List) {
      parsedItemPrices = (json['itemPrices'] as List)
          .map((priceJson) => ItemPrice(
                id: priceJson['id'] as String? ?? '',
                name: priceJson['name'] as String? ?? '',
                description: priceJson['description'] as String? ?? '',
                price: priceJson['price'] as double? ?? 0.0,
                currencyCode: priceJson['currencyCode'] as String? ?? 'INR',
              ))
          .toList();
    }

    return Product(
      item: item,
      isRecommended: json['isRecommended'] as bool? ?? false,
      isAvailable: json['isAvailable'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.5,
      reviewCount: json['reviewCount'] as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 8.99,
      currency: json['currency'] as String? ?? 'USD',
      nutritionFacts: (json['nutritionFacts'] as List?)?.cast<String>(),
      description: json['description'] as String?,
      category: json['category'] as String?,
      itemPrices: parsedItemPrices,
    );
  }

  @override
  List<Object?> get props => [
        item,
        isRecommended,
        isAvailable,
        rating,
        reviewCount,
        price,
        currency,
        nutritionFacts,
        description,
        category,
        itemPrices,
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

  const ProductsSearchResults({
    required this.products,
    required this.query,
  });

  @override
  List<Object> get props => [products, query];
}

// BLoC
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final UserRepository userRepository = getIt.get();
  final ItemService itemService = getIt.get();

  ProductsBloc() : super(const ProductsInitial()) {
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
      // Check internet connectivity - temporarily disabled for debugging
      // if (!await userRepository.isInternetAvailable()) {
      //   // Try to load from cache as fallback
      //   final cachedProducts = await _loadFromCache();
      //   if (cachedProducts.isNotEmpty) {
      //     emit(ProductsLoaded(products: cachedProducts));
      //     return;
      //   }
      //   emit(const ProductsError(message: 'No internet connection'));
      //   return;
      // }

      // Skip internet check for now to ensure products load

      // Load products from your backend API
      // Example: GET /api/products or /api/juices
      await Future.delayed(const Duration(
          milliseconds: 300)); // Reduced delay for faster loading

      // Create enhanced products from existing juice models
      final products = await _createEnhancedProducts();

      // Debug log
      print('ProductsBloc: Loaded ${products.length} products');
      for (var product in products) {
        product.debugPrint();
      }

      // Cache the products
      await _saveToCache(products);

      emit(ProductsLoaded(products: products));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onLoadRecommendedProducts(
    LoadRecommendedProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      // Check internet connectivity
      if (!await userRepository.isInternetAvailable()) {
        final cachedProducts = await _loadFromCache();
        if (cachedProducts.isNotEmpty) {
          final recommendedProducts = cachedProducts
              .where((product) => product.isRecommended)
              .take(3)
              .toList();
          emit(RecommendedProductsLoaded(products: recommendedProducts));
          return;
        }
        emit(const ProductsError(message: 'No internet connection'));
        return;
      }

      // Load recommended products from your backend
      // Example: GET /api/products/recommended?userId=${userRepository.user.id}
      await Future.delayed(const Duration(milliseconds: 800));

      final allProducts = await _createEnhancedProducts();
      final recommendedProducts = allProducts
          .where((product) => product.isRecommended)
          .take(3)
          .toList();

      emit(RecommendedProductsLoaded(products: recommendedProducts));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      // Load products by category from your backend
      // Example: GET /api/products?category=${event.category}
      await Future.delayed(const Duration(milliseconds: 800));

      final allProducts = await _createEnhancedProducts();

      // Filter by category
      List<Product> categoryProducts;

      switch (event.category.toLowerCase()) {
        case 'citrus':
          categoryProducts = allProducts
              .where((p) =>
                  p.category == 'citrus' ||
                  p.name.toLowerCase().contains('vitamin c') ||
                  p.ingredients
                      .any((i) => i.toLowerCase().contains('tangerine')))
              .toList();
          break;
        case 'green':
          categoryProducts = allProducts
              .where((p) =>
                  p.category == 'green' ||
                  p.ingredients.any((i) =>
                      i.toLowerCase().contains('green') ||
                      i.toLowerCase().contains('spinach') ||
                      i.toLowerCase().contains('kale')))
              .toList();
          break;
        case 'fruit':
          categoryProducts = allProducts
              .where((p) =>
                  p.category == 'fruit' ||
                  p.ingredients.any((i) =>
                      i.toLowerCase().contains('apple') ||
                      i.toLowerCase().contains('pineapple') ||
                      i.toLowerCase().contains('watermelon')))
              .toList();
          break;
        default:
          categoryProducts = allProducts;
      }

      if (categoryProducts.isEmpty) {
        emit(const ProductsEmpty());
      } else {
        emit(ProductsLoaded(products: categoryProducts));
      }
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      // Search products in your backend
      // Example: GET /api/products/search?q=${event.query}
      await Future.delayed(const Duration(milliseconds: 500));

      final allProducts = await _createEnhancedProducts();
      final searchResults = allProducts
          .where((product) =>
              product.name.toLowerCase().contains(event.query.toLowerCase()) ||
              product.ingredients.any((ingredient) => ingredient
                  .toLowerCase()
                  .contains(event.query.toLowerCase())) ||
              (product.description
                      ?.toLowerCase()
                      .contains(event.query.toLowerCase()) ??
                  false))
          .toList();

      emit(ProductsSearchResults(
        products: searchResults,
        query: event.query,
      ));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductsState> emit,
  ) async {
    emit(const ProductsLoading());

    try {
      // Load product details from your backend
      // Example: GET /api/products/${event.juiceId}
      await Future.delayed(const Duration(milliseconds: 800));

      final allProducts = await _createEnhancedProducts();
      final product = allProducts.firstWhere(
        (p) => p.item.id == event.juiceId,
        orElse: () => throw Exception('Product not found'),
      );

      emit(ProductDetailsLoaded(product: product));
    } catch (e) {
      emit(ProductsError(message: e.toString()));
    }
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is ProductsLoaded) {
      try {
        await Future.delayed(const Duration(milliseconds: 500));

        final products = await _createEnhancedProducts();
        await _saveToCache(products);
        emit(ProductsLoaded(products: products));
      } catch (e) {
        emit(ProductsError(message: e.toString()));
      }
    } else {
      add(const LoadProducts());
    }
  }

  Future<List<Product>> _createEnhancedProducts() async {
    try {
      // Try to fetch items from the backend using ItemService
      final dynamicItems = await itemService.fetchItems();

      print('Fetched ${dynamicItems.length} items from backend');

      if (dynamicItems.isEmpty) {
        // Fallback to static items if no items were fetched
        return _createFallbackProducts();
      }

      // Convert dynamic items to products
      final products = dynamicItems.map((dynamicItem) {
        // Convert to Item first
        final item = itemService.convertToItem(dynamicItem);

        // Create Product from Item
        return Product(
          item: ItemData(
            itemID: int.tryParse(dynamicItem.itemID) ?? 0,
            titleTxt: dynamicItem.displayName,
            imagePath: dynamicItem.imagePath,
            startColor: dynamicItem.startColor,
            endColor: dynamicItem.endColor,
            meals: dynamicItem.meals,
            kacl: dynamicItem.kacl,
          ),
          isRecommended: dynamicItem.metaData['recommended'] == true,
          isAvailable: dynamicItem.status == 'ACTIVE',
          rating: 4.5, // Default rating
          reviewCount: 0,
          price: item.itemPrices != null &&
                  item.itemPrices!.isNotEmpty &&
                  item.itemPrices![0].price != null
              ? item.itemPrices![0].price!.toDouble()
              : 0.0,
          currency: 'INR',
          description: dynamicItem.description,
          category: dynamicItem.category,
          itemPrices: item.itemPrices,
        );
      }).toList();

      return products;
    } catch (e) {
      print('Error creating enhanced products: $e');
      return _createFallbackProducts();
    }
  }

  // Fallback method to create products from static data
  List<Product> _createFallbackProducts() {
    // Get base item models
    final items = ItemData.tabIconsList;

    print('Creating fallback products from ${items.length} items');

    // Check if items list is empty
    if (items.isEmpty) {
      print('WARNING: ItemData.tabIconsList is empty!');
      return [];
    }

    // Print each item for debugging
    for (var item in items) {
      print(
          'Item: ${item.titleTxt}, ID: ${item.itemID}, Image: ${item.imagePath}');
    }

    // Create enhanced products from static data
    final products = items.map((item) {
      // Calculate price based on item ID
      final basePrice = 7.99 + (item.itemID * 1.5);

      // Create item prices for different sizes
      final itemPrices = [
        ItemPrice(
          id: '${item.itemID}_small',
          name: 'Small (100ml)',
          description: 'Perfect for a quick refreshment',
          price: basePrice,
          currencyCode: 'INR',
        ),
        ItemPrice(
          id: '${item.itemID}_medium',
          name: 'Medium (250ml)',
          description: 'Our most popular size',
          price: basePrice * 2,
          currencyCode: 'INR',
        ),
        ItemPrice(
          id: '${item.itemID}_large',
          name: 'Large (500ml)',
          description: 'Great value for sharing',
          price: basePrice * 3.5,
          currencyCode: 'INR',
        ),
      ];

      return Product(
        item: item,
        isRecommended: item.itemID < 3, // First 3 are recommended
        isAvailable: true,
        rating: 4.0 +
            (item.itemID * 0.2).clamp(0.0, 1.0), // Vary ratings between 4.0-5.0
        reviewCount: 50 + (item.itemID * 25),
        price: basePrice,
        currency: 'INR',
        nutritionFacts: _getNutritionFacts(item),
        description: _getDescription(item),
        category: _getCategory(item),
        itemPrices: itemPrices,
      );
    }).toList();

    print('Created ${products.length} enhanced products');
    return products;
  }

  List<String> _getNutritionFacts(ItemData item) {
    // Generate nutrition facts based on item type
    switch (item.itemID) {
      case 0: // Watermelon
        return [
          'Vitamin C: 25% DV',
          'Lycopene: High',
          'Calories: ${item.kacl}',
          'Hydration: Excellent'
        ];
      case 1: // Pineapple
        return [
          'Vitamin C: 150% DV',
          'Manganese: 30% DV',
          'Calories: ${item.kacl}',
          'Bromelain: Natural enzyme'
        ];
      case 2: // ABC
        return [
          'Vitamin A: 200% DV',
          'Iron: 15% DV',
          'Fiber: 4g',
          'Beta-carotene: High'
        ];
      case 3: // Vitamin C
        return [
          'Vitamin C: 300% DV',
          'Antioxidants: High',
          'Natural Sugars: 20g',
          'Immune Support: Excellent'
        ];
      case 4: // Bloody Red
        return [
          'Nitrates: High',
          'Folate: 25% DV',
          'Iron: 18% DV',
          'Energy Boost: Natural'
        ];
      default:
        return ['Natural', 'Fresh', 'Nutritious', 'Cold-pressed'];
    }
  }

  String _getDescription(ItemData item) {
    // Generate descriptions based on item type
    switch (item.itemID) {
      case 0:
        return 'Refreshing watermelon juice packed with natural hydration and lycopene for healthy skin. Perfect for post-workout recovery.';
      case 1:
        return 'Tropical pineapple juice rich in vitamin C and enzymes for digestive health. A burst of tropical sunshine in every sip.';
      case 2:
        return 'A powerful blend of apple, beetroot, and carrot for natural energy and vitality. The classic ABC combination for daily nutrition.';
      case 3:
        return 'Vitamin C powerhouse with amla, pineapple, and tangerine for immune support. Your daily shield against seasonal changes.';
      case 4:
        return 'Rich, earthy blend perfect for natural energy and cardiovascular health. Fuel your day with this nutrient-dense powerhouse.';
      default:
        return 'Fresh, cold-pressed juice made with premium organic ingredients. Crafted for your health and wellness journey.';
    }
  }

  String _getCategory(ItemData item) {
    // Assign categories based on item type
    switch (item.itemID) {
      case 0: // Watermelon
        return 'fruit';
      case 1: // Pineapple
        return 'fruit';
      case 2: // ABC
        return 'blend';
      case 3: // Vitamin C
        return 'citrus';
      case 4: // Bloody Red
        return 'vegetable';
      default:
        return 'specialty';
    }
  }

  // Cache management using SharedPreferences
  Future<void> _saveToCache(List<Product> products) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = jsonEncode(products.map((p) => p.toJson()).toList());
      await prefs.setString('cached_products', productsJson);
      await prefs.setInt(
          'products_cache_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      // Handle cache save error silently
    }
  }

  Future<List<Product>> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final productsJson = prefs.getString('cached_products');
      final timestamp = prefs.getInt('products_cache_timestamp') ?? 0;

      // Check if cache is less than 1 hour old
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final oneHour = 60 * 60 * 1000; // 1 hour in milliseconds

      if (productsJson != null && cacheAge < oneHour) {
        final productsList = jsonDecode(productsJson) as List;
        // Use ItemData instead of Juice
        final items = await getIt<ItemService>().getItems();

        return productsList.map((productJson) {
          final itemId = productJson['id'] as String;
          final item = items.firstWhere((i) => i.id == itemId,
              orElse: () => ItemData(id: itemId, name: 'Unknown Item'));
          return Product.fromJson(productJson as Map<String, dynamic>, item);
        }).toList();
      }
    } catch (e) {
      // Handle cache load error silently
    }
    return [];
  }
}
