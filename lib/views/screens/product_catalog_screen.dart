import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart' hide AddToCart;
import 'package:lush/theme/app_colors.dart';
import 'package:lush/utils/analytics_service.dart';
import 'package:lush/views/models/cart_item.dart';
import 'package:lush/views/models/item.dart';
import 'package:lush/views/widgets/shimmer_product_card.dart';
import 'package:lush/utils/haptic_feedback.dart' as HapticFeedbackUtil;

/// Product Catalog Screen
/// Displays products in Delight/Signature/Premium categories
/// with 200/300/500ml size selection and add to cart
class ProductCatalogScreen extends StatefulWidget {
  static const routeName = '/product-catalog';

  const ProductCatalogScreen({super.key});

  @override
  ProductCatalogScreenState createState() => ProductCatalogScreenState();
}

class ProductCatalogScreenState extends State<ProductCatalogScreen> {
  String? _selectedCategory;
  String? _selectedSize;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductCatalogBloc>().add(const LoadProductCatalog());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Our Products'),
        backgroundColor: AppColors.primaryOrange,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: BlocListener<ProductCatalogBloc, ProductCatalogState>(
        listener: (context, state) {
          if (state is ProductCatalogLoaded) {
            // Auto-select first category and size on initial load
            if (_selectedCategory == null && state.categories.isNotEmpty) {
              setState(() {
                _selectedCategory = state.categories.first;
                _selectedSize = state.sizes.isNotEmpty ? state.sizes.first : null;
              });
              context.read<ProductCatalogBloc>().add(FilterByCategory(category: _selectedCategory!));
            }
          }
        },
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoryFilter(),
            _buildSizeFilter(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<ProductCatalogBloc>().add(const LoadProductCatalog());
                  await Future<void>.delayed(const Duration(seconds: 1));
                },
                child: BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
                  builder: (context, state) {
                    if (state is ProductCatalogLoading) {
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 0.75,
                          crossAxisSpacing: 16, mainAxisSpacing: 16,
                        ),
                        itemCount: 6,
                        itemBuilder: (_, __) => const ShimmerProductCard(),
                      );
                    }
                    if (state is ProductCatalogError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(state.message, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.read<ProductCatalogBloc>().add(const LoadProductCatalog()),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }
                    if (state is ProductCatalogEmpty || (state is ProductCatalogFiltered && state.items.isEmpty)) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text('No products found', style: TextStyle(fontSize: 18, color: Colors.grey)),
                          ],
                        ),
                      );
                    }
                    if (state is ProductCatalogLoaded) {
                      return _buildProductGrid(state.items, _selectedSize);
                    }
                    if (state is ProductCatalogFiltered) return _buildProductGrid(state.items, _selectedSize);
                    return const Center(child: Text('Something went wrong'));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search juices...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    context.read<ProductCatalogBloc>().add(const SearchProducts(query: ''));
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.lightGrey,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          AnalyticsService.logSearchPerformed(value);
          context.read<ProductCatalogBloc>().add(SearchProducts(query: value));
        },
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
      builder: (context, state) {
        List<String> categories = [];
        if (state is ProductCatalogLoaded) {
          categories = state.categories;
        } else if (state is ProductCatalogFiltered) {
          categories = state.categories;
        }
        if (categories.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = _selectedCategory == category;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedCategory = selected ? category : null);
                    AnalyticsService.logFamilySelected(category);
                    context.read<ProductCatalogBloc>().add(FilterByCategory(category: category));
                  },
                  backgroundColor: AppColors.lightGrey,
                  selectedColor: AppColors.primaryOrange.withValues(alpha: 0.3),
                  checkmarkColor: AppColors.primaryOrange,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryOrange : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSizeFilter() {
    return BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
      builder: (context, state) {
        List<String> sizes = [];
        if (state is ProductCatalogLoaded) {
          sizes = state.sizes;
        } else if (state is ProductCatalogFiltered) {
          sizes = state.sizes;
        }
        if (sizes.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: sizes.length,
            itemBuilder: (context, index) {
              final size = sizes[index];
              final isSelected = _selectedSize == size;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(size),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _selectedSize = selected ? size : null);
                    context.read<ProductCatalogBloc>().add(FilterBySize(size: size));
                  },
                  backgroundColor: AppColors.lightGrey,
                  selectedColor: AppColors.primaryOrange.withValues(alpha: 0.3),
                  checkmarkColor: AppColors.primaryOrange,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primaryOrange : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(List<CatalogItem> items, String? selectedSize) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, childAspectRatio: 0.75,
        crossAxisSpacing: 16, mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => _buildProductCard(items[index], selectedSize),
    );
  }

  Widget _buildProductCard(CatalogItem item, String? selectedSize) {
    final defaultPrice = _getDisplayPrice(item, selectedSize);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_hexToColor(item.startColor), _hexToColor(item.endColor)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
              ),
              child: item.imagePath.isNotEmpty
                  ? Image.asset(item.imagePath, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Center(
                        child: Icon(Icons.local_drink, size: 64, color: Colors.white.withValues(alpha: 0.5)),
                      ),
                    )
                  : Center(child: Icon(Icons.local_drink, size: 64, color: Colors.white.withValues(alpha: 0.5))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(item.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _getCategoryColor(item.category))),
                ),
                const SizedBox(height: 8),
                Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('${item.calories} cal', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (defaultPrice != null)
                      Text('₹${defaultPrice.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),)
                    else
                      const Text('From ₹75', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    IconButton(
                      icon: const Icon(Icons.add_circle, size: 32),
                      color: AppColors.primaryOrange,
                      onPressed: () => _showSizeSelectionDialog(item),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Returns the price matching the given size filter,
  /// or the first available price as fallback.
  ItemPrice? _getDisplayPrice(CatalogItem item, String? selectedSize) {
    if (item.prices.isEmpty) return null;

    if (selectedSize != null && selectedSize.isNotEmpty) {
      final match = item.prices.firstWhere(
        (p) => (p.name?.toLowerCase().contains(selectedSize.toLowerCase()) ?? false),
        orElse: () => item.prices.first,
      );
      return match;
    }

    return item.prices.first;
  }

  void _showSizeSelectionDialog(CatalogItem item) {
    showModalBottomSheet<dynamic>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            ItemPrice? selectedPrice;
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Select Size', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 24),
                  ...item.prices.map((price) {
                    final isSelected = selectedPrice == price;
                    return ListTile(
                      title: Text(price.name ?? 'Unknown Size',
                          style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),),
                      subtitle: Text('₹${price.price?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(color: AppColors.primaryOrange, fontWeight: FontWeight.bold),),
                      trailing: Radio<ItemPrice>(value: price, groupValue: selectedPrice,
                          onChanged: (v) => setModalState(() => selectedPrice = v), activeColor: AppColors.primaryOrange,),
                      onTap: () => setModalState(() => selectedPrice = price),
                    );
                  }),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity, height: 50,
                    child: ElevatedButton(
                      onPressed: selectedPrice != null
                          ? () {
                              HapticFeedbackUtil.HapticFeedbackUtil.lightFeedback();
                              context.read<CartBloc>().add(AddToCart(CartItem(item: item.item, selectedPrice: selectedPrice)));
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('${item.name} (${selectedPrice!.name}) added to cart'),
                                backgroundColor: AppColors.success, behavior: SnackBarBehavior.floating,
                              ),);
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Add to Cart', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    return hexColor.length == 6 ? Color(int.parse('0xFF$hexColor')) : AppColors.primaryOrange;
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'delight': return AppColors.success;
      case 'signature': return AppColors.info;
      case 'premium': return AppColors.primaryOrangeDark;
      default: return AppColors.primaryOrange;
    }
  }
}