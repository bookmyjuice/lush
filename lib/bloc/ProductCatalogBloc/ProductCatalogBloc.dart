import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../UserRepository/userRepository.dart';
import '../../getIt.dart';
import '../../views/models/Item.dart';

// Events
abstract class ProductCatalogEvent extends Equatable {
  const ProductCatalogEvent();

  @override
  List<Object> get props => [];
}

class LoadProductCatalog extends ProductCatalogEvent {
  const LoadProductCatalog();
}

class FilterByCategory extends ProductCatalogEvent {
  final String category;

  const FilterByCategory({required this.category});

  @override
  List<Object> get props => [category];
}

class FilterBySize extends ProductCatalogEvent {
  final String size;

  const FilterBySize({required this.size});

  @override
  List<Object> get props => [size];
}

class SearchProducts extends ProductCatalogEvent {
  final String query;

  const SearchProducts({required this.query});

  @override
  List<Object> get props => [query];
}

class AddToCart extends ProductCatalogEvent {
  final Item item;
  final ItemPrice selectedPrice;
  final int quantity;

  const AddToCart({
    required this.item,
    required this.selectedPrice,
    this.quantity = 1,
  });

  @override
  List<Object> get props => [item, selectedPrice, quantity];
}

// States
abstract class ProductCatalogState extends Equatable {
  const ProductCatalogState();

  @override
  List<Object> get props => [];
}

class ProductCatalogInitial extends ProductCatalogState {
  const ProductCatalogInitial();
}

class ProductCatalogLoading extends ProductCatalogState {
  const ProductCatalogLoading();
}

class ProductCatalogLoaded extends ProductCatalogState {
  final List<CatalogItem> items;
  final List<String> categories;
  final List<String> sizes;

  const ProductCatalogLoaded({
    required this.items,
    required this.categories,
    required this.sizes,
  });

  @override
  List<Object> get props => [items, categories, sizes];
}

class ProductCatalogFiltered extends ProductCatalogState {
  final List<CatalogItem> items;
  final String? selectedCategory;
  final String? selectedSize;

  const ProductCatalogFiltered({
    required this.items,
    this.selectedCategory,
    this.selectedSize,
  });

  @override
  List<Object> get props => [items, selectedCategory ?? '', selectedSize ?? ''];
}

class ProductCatalogError extends ProductCatalogState {
  final String message;

  const ProductCatalogError({required this.message});

  @override
  List<Object> get props => [message];
}

class ProductCatalogEmpty extends ProductCatalogState {
  const ProductCatalogEmpty();
}

// Catalog Item - wraps Item with display metadata
class CatalogItem extends Equatable {
  final Item item;
  final String category; // Delight, Signature, Premium
  final List<ItemPrice> prices; // 200ml, 300ml, 500ml prices
  final bool isAvailable;

  const CatalogItem({
    required this.item,
    required this.category,
    required this.prices,
    this.isAvailable = true,
  });

  String get id => item.id ?? '';
  String get name => item.name ?? item.titleTxt ?? 'Unknown';
  String get description => item.description ?? '';
  String get imagePath => item.imagePath ?? '';
  String get startColor => item.startColor ?? '#FF8C42';
  String get endColor => item.endColor ?? '#FF6B35';
  int get calories => item.kacl ?? 0;
  List<String> get ingredients => item.meals ?? [];

  CatalogItem copyWith({
    Item? item,
    String? category,
    List<ItemPrice>? prices,
    bool? isAvailable,
  }) {
    return CatalogItem(
      item: item ?? this.item,
      category: category ?? this.category,
      prices: prices ?? this.prices,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [item, category, prices, isAvailable];

  @override
  String toString() {
    return 'CatalogItem(name: $name, category: $category, prices: ${prices.length})';
  }
}

// BLoC
class ProductCatalogBloc extends Bloc<ProductCatalogEvent, ProductCatalogState> {
  final UserRepository _userRepository = getIt.get<UserRepository>();

  List<CatalogItem> _allItems = [];
  String? _selectedCategory;
  String? _selectedSize;

  ProductCatalogBloc() : super(const ProductCatalogInitial()) {
    on<LoadProductCatalog>(_onLoadProductCatalog);
    on<FilterByCategory>(_onFilterByCategory);
    on<FilterBySize>(_onFilterBySize);
    on<SearchProducts>(_onSearchProducts);
    on<AddToCart>(_onAddToCart);
  }

  Future<void> _onLoadProductCatalog(
    LoadProductCatalog event,
    Emitter<ProductCatalogState> emit,
  ) async {
    emit(const ProductCatalogLoading());

    try {
      // Fetch from backend: GET /api/test/charge-items
      final List<Map<String, dynamic>> apiResponse =
          await _userRepository.getChargeItems();

      print('ProductCatalogBloc: Fetched ${apiResponse.length} items from API');

      // Convert to CatalogItem list
      _allItems = _convertToCatalogItems(apiResponse);

      print('ProductCatalogBloc: Converted to ${_allItems.length} catalog items');

      // Extract unique categories and sizes
      final categories = _extractCategories(_allItems);
      final sizes = _extractSizes(_allItems);

      if (_allItems.isEmpty) {
        emit(const ProductCatalogEmpty());
      } else {
        emit(ProductCatalogLoaded(
          items: _allItems,
          categories: categories,
          sizes: sizes,
        ));
      }
    } catch (e) {
      print('ProductCatalogBloc: Error loading products: $e');
      emit(ProductCatalogError(message: 'Failed to load products: $e'));
    }
  }

  void _onFilterByCategory(
    FilterByCategory event,
    Emitter<ProductCatalogState> emit,
  ) {
    _selectedCategory = event.category;
    _applyFilters(emit);
  }

  void _onFilterBySize(
    FilterBySize event,
    Emitter<ProductCatalogState> emit,
  ) {
    _selectedSize = event.size;
    _applyFilters(emit);
  }

  void _onSearchProducts(
    SearchProducts event,
    Emitter<ProductCatalogState> emit,
  ) {
    if (event.query.isEmpty) {
      _applyFilters(emit);
      return;
    }

    final query = event.query.toLowerCase();
    final filteredItems = _allItems.where((item) {
      return item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query) ||
          item.ingredients.any((ing) => ing.toLowerCase().contains(query));
    }).toList();

    emit(ProductCatalogFiltered(
      items: filteredItems,
      selectedCategory: _selectedCategory,
      selectedSize: _selectedSize,
    ));
  }

  Future<void> _onAddToCart(
    AddToCart event,
    Emitter<ProductCatalogState> emit,
  ) async {
    // This would integrate with CartBloc
    // For now, just log the action
    print('ProductCatalogBloc: Adding to cart - ${event.item.name}, '
        'Size: ${event.selectedPrice.name}, '
        'Qty: ${event.quantity}');
    
    // TODO: Integrate with CartBloc
    // context.read<CartBloc>().add(AddToCartEvent(...));
  }

  void _applyFilters(Emitter<ProductCatalogState> emit) {
    List<CatalogItem> filteredItems = List.from(_allItems);

    // Filter by category
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) {
      filteredItems = filteredItems
          .where((item) =>
              item.category.toLowerCase() == _selectedCategory!.toLowerCase())
          .toList();
    }

    // Filter by size
    if (_selectedSize != null && _selectedSize!.isNotEmpty) {
      filteredItems = filteredItems.where((item) {
        return item.prices.any((price) =>
            price.name != null &&
            price.name!.toLowerCase().contains(_selectedSize!.toLowerCase()));
      }).toList();
    }

    if (filteredItems.isEmpty) {
      emit(const ProductCatalogEmpty());
    } else {
      emit(ProductCatalogFiltered(
        items: filteredItems,
        selectedCategory: _selectedCategory,
        selectedSize: _selectedSize,
      ));
    }
  }

  List<CatalogItem> _convertToCatalogItems(List<Map<String, dynamic>> apiResponse) {
    return apiResponse.map((json) {
      // Parse category from metadata or item_family_id
      String category = _extractCategoryFromJson(json);
      
      // Parse item prices
      List<ItemPrice> prices = _parseItemPrices(json);

      // Create Item object
      final item = Item(
        id: json['itemId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        description: json['description'] as String?,
        imagePath: json['imagePath'] as String? ?? '',
        startColor: json['startColor'] as String? ?? '#FF8C42',
        endColor: json['endColor'] as String? ?? '#FF6B35',
        meals: json['meals'] != null ? List<String>.from(json['meals'] as Iterable<String>) : null,
        kacl: json['calories'] as int? ?? 0,
        status: json['status'] as String? ?? 'ACTIVE',
        enabledForCheckout: json['enabledForCheckout'] as bool? ?? true,
        enabledInPortal: json['enabledInPortal'] as bool? ?? true,
        type: 'CHARGE',
        servingSize: json['servingSize'] as String? ?? '500ml',
        itemPrices: prices,
      );

      return CatalogItem(
        item: item,
        category: category,
        prices: prices,
        isAvailable: json['enabledForCheckout'] as bool? ?? true,
      );
    }).toList();
  }

  String _extractCategoryFromJson(Map<String, dynamic> json) {
    // Try to get category from various possible fields
    if (json.containsKey('category')) {
      return json['category'] as String;
    }
    
    // Check itemFamilyId for category hints
    if (json.containsKey('itemFamilyId')) {
      final familyId = json['itemFamilyId'].toString().toLowerCase();
      if (familyId.contains('delight')) return 'Delight';
      if (familyId.contains('signature')) return 'Signature';
      if (familyId.contains('premium')) return 'Premium';
    }

    // Check name for category hints
    if (json.containsKey('name')) {
      final name = json['name'].toString().toLowerCase();
      if (name.contains('delight')) return 'Delight';
      if (name.contains('signature')) return 'Signature';
      if (name.contains('premium')) return 'Premium';
    }

    // Default to first category if not found
    return 'Delight';
  }

  List<ItemPrice> _parseItemPrices(Map<String, dynamic> json) {
    List<ItemPrice> prices = [];

    if (json.containsKey('prices') && json['prices'] is List) {
      final pricesList = json['prices'] as List;
      for (var priceJson in pricesList) {
        if (priceJson is Map<String, dynamic>) {
          final price = ItemPrice.fromJson(priceJson);
          prices.add(price);
        }
      }
    }

    return prices;
  }

  List<String> _extractCategories(List<CatalogItem> items) {
    final categories = items.map((item) => item.category).toSet().toList();
    categories.sort();
    return categories;
  }

  List<String> _extractSizes(List<CatalogItem> items) {
    final sizes = <String>{};
    for (var item in items) {
      for (var price in item.prices) {
        if (price.name != null) {
          // Extract size from price name (e.g., "200ml" from "200ml Price")
          final sizeMatch = RegExp(r'(\d+ml)').firstMatch(price.name!);
          if (sizeMatch != null) {
            sizes.add(sizeMatch.group(0)!);
          }
        }
      }
    }
    return sizes.toList()..sort();
  }
}
