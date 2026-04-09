import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/CartBloc/CartBloc.dart';
import 'package:lush/bloc/CartBloc/cartEvent.dart';
import 'package:lush/bloc/ProductCatalogBloc/ProductCatalogBloc.dart' hide AddToCart;
import 'package:lush/views/models/CartItem.dart';
import 'package:lush/views/models/Item.dart';

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
    // Load products on init
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
        backgroundColor: const Color(0xFFFF8C42),
        elevation: 0,
        actions: [
          // Cart icon
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),
          
          // Category Filter Chips
          _buildCategoryFilter(),
          
          // Size Filter Chips
          _buildSizeFilter(),
          
          // Product Grid
          Expanded(
            child: BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
              builder: (context, state) {
                if (state is ProductCatalogLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFFF8C42),
                    ),
                  );
                }

                if (state is ProductCatalogError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          state.message,
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<ProductCatalogBloc>()
                                .add(const LoadProductCatalog());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ProductCatalogEmpty ||
                    (state is ProductCatalogFiltered &&
                        state.items.isEmpty)) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (state is ProductCatalogLoaded) {
                  _selectedCategory ??=
                      state.categories.isNotEmpty ? state.categories.first : null;
                  _selectedSize ??= state.sizes.isNotEmpty ? state.sizes.first : null;
                  return _buildProductGrid(state.items);
                }

                if (state is ProductCatalogFiltered) {
                  return _buildProductGrid(state.items);
                }

                return const Center(
                  child: Text('Something went wrong'),
                );
              },
            ),
          ),
        ],
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
                    context.read<ProductCatalogBloc>().add(
                          const SearchProducts(query: ''),
                        );
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onChanged: (value) {
          context.read<ProductCatalogBloc>().add(
                SearchProducts(query: value),
              );
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
        }

        if (categories.isEmpty) {
          return const SizedBox.shrink();
        }

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
                    setState(() {
                      _selectedCategory = selected ? category : null;
                    });
                    context.read<ProductCatalogBloc>().add(
                          FilterByCategory(category: category),
                        );
                  },
                  backgroundColor: const Color(0xFFF5F5F5),
                  selectedColor: const Color(0xFFFF8C42).withOpacity(0.3),
                  checkmarkColor: const Color(0xFFFF8C42),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFFFF8C42)
                        : Colors.grey.shade700,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
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
        }

        if (sizes.isEmpty) {
          return const SizedBox.shrink();
        }

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
                    setState(() {
                      _selectedSize = selected ? size : null;
                    });
                    context.read<ProductCatalogBloc>().add(
                          FilterBySize(size: size),
                        );
                  },
                  backgroundColor: const Color(0xFFF5F5F5),
                  selectedColor: const Color(0xFFFF8C42).withOpacity(0.3),
                  checkmarkColor: const Color(0xFFFF8C42),
                  labelStyle: TextStyle(
                    color: isSelected
                        ? const Color(0xFFFF8C42)
                        : Colors.grey.shade700,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(List<CatalogItem> items) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildProductCard(item);
      },
    );
  }

  Widget _buildProductCard(CatalogItem item) {
    // Get the first price (default to 500ml if available)
    final defaultPrice = item.prices.isNotEmpty
        ? item.prices.firstWhere(
            (p) => p.name?.contains('500ml') ?? false,
            orElse: () => item.prices.first,
          )
        : null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _hexToColor(item.startColor),
                    _hexToColor(item.endColor),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: item.imagePath.isNotEmpty
                  ? Image.asset(
                      item.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.local_drink,
                            size: 64,
                            color: Colors.white.withOpacity(0.5),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Icon(
                        Icons.local_drink,
                        size: 64,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
            ),
          ),
          
          // Product Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: _getCategoryColor(item.category),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Product Name
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                
                // Calories
                Text(
                  '${item.calories} cal',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Price and Add to Cart
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (defaultPrice != null)
                      Text(
                        '₹${defaultPrice.price?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF8C42),
                        ),
                      )
                    else
                      const Text(
                        'From ₹75',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    
                    // Add to Cart Button
                    IconButton(
                      icon: const Icon(
                        Icons.add_circle,
                        size: 32,
                      ),
                      color: const Color(0xFFFF8C42),
                      onPressed: () {
                        _showSizeSelectionDialog(item);
                      },
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

  void _showSizeSelectionDialog(CatalogItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
                  // Header
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Select Size',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Size Options
                  ...item.prices.map((price) {
                    final isSelected = selectedPrice == price;
                    return ListTile(
                      title: Text(
                        price.name ?? 'Unknown Size',
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '₹${price.price?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          color: Color(0xFFFF8C42),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: Radio<ItemPrice>(
                        value: price,
                        groupValue: selectedPrice,
                        onChanged: (value) {
                          setModalState(() {
                            selectedPrice = value;
                          });
                        },
                        activeColor: const Color(0xFFFF8C42),
                      ),
                      onTap: () {
                        setModalState(() {
                          selectedPrice = price;
                        });
                      },
                    );
                  }).toList(),
                  
                  const SizedBox(height: 24),
                  
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: selectedPrice != null
                          ? () {
                              // Add to CartBloc
                              final cartItem = CartItem(
                                item: item.item,
                                quantity: 1,
                                selectedPrice: selectedPrice,
                              );
                              context.read<CartBloc>().add(
                                    AddToCart(cartItem),
                                  );

                              Navigator.pop(context);

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${item.name} (${selectedPrice!.name}) added to cart',
                                  ),
                                  backgroundColor: const Color(0xFF4CAF50),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C42),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add to Cart',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
    if (hexColor.length == 6) {
      return Color(int.parse('0xFF$hexColor'));
    }
    return const Color(0xFFFF8C42); // Default orange
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'delight':
        return const Color(0xFF4CAF50); // Green
      case 'signature':
        return const Color(0xFF2196F3); // Blue
      case 'premium':
        return const Color(0xFF9C27B0); // Purple
      default:
        return const Color(0xFFFF8C42); // Orange
    }
  }
}
