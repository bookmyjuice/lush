import 'package:flutter/material.dart';
import 'item_card_view.dart';
import '../models/item.dart';
import '../../services/item_service.dart';
import '../../get_it.dart';

class ItemListView extends StatefulWidget {
  const ItemListView(
      {super.key,
      this.mainScreenAnimationController,
      this.mainScreenAnimation,
      this.items,
      this.category,
      this.size,
      this.type,
      this.useFallbackItems = false});

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  final List<Item>? items;
  final String? category;
  final String? size; // Selected size filter
  final String? type; // Selected type filter (CHARGE, PLAN, ADDON)
  final bool
      useFallbackItems; // Flag to determine whether to use fallback items or fetch from server

  @override
  ItemListViewState createState() => ItemListViewState();
}

class ItemListViewState extends State<ItemListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  List<Item> itemList = [];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void didUpdateWidget(ItemListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger rebuild when category changes
    if (oldWidget.category != widget.category) {
      setState(() {}); // Force rebuild with new category filter
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: _buildItemList(),
          ),
        );
      },
    );
  }

  Widget _buildItemList() {
    // If items are provided directly, use them
    if (widget.items != null && widget.items!.isNotEmpty) {
      print('Using provided items: ${widget.items!.length}');
      return _buildItemGrid(widget.items!);
    }

    // Otherwise, load items using the ItemService
    return FutureBuilder<List<Item>>(
      future: _loadItems(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          print('Error loading items: ${snapshot.error}');
          // Use fallback items instead of showing error
          return _buildFallbackItems();
        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final items = snapshot.data!;
          print('Items loaded: ${items.length}');

          // Apply all filters: category, type, and size
          final String category = widget.category ?? 'Premium';
          final String type =
              widget.type ?? 'CHARGE'; // Default to one-time purchases
          final String? size = widget.size; // Size filter is optional

          final filteredItems = items.where((item) {
            // Basic filters: active and not deleted
            bool isActive = item.status == 'ACTIVE' && !(item.deleted ?? false);
            // Type filter
            bool matchesType = item.type == type;
            // Category filter: itemFamilyId contains selected category (case-insensitive)
            bool matchesCategory = true;
            if (category.isNotEmpty) {
              final familyId = item.itemFamilyId ?? '';
              matchesCategory = familyId.toLowerCase().contains(category.toLowerCase());
              if(familyId =='Juices' && category == 'Premium') {
                // Special case for 'Juices' family when category is 'Premium'
                matchesCategory = true; // Always match
              }
            }
            // Size filter (if specified)
            bool matchesSize = true;
            if (size != null && size.isNotEmpty) {
              // Match item's servingSize to selected size
              matchesSize = item.servingSize.toString().toLowerCase() ==
                  size.toLowerCase();
            }
            return isActive && matchesType && matchesSize && matchesCategory;
          }).toList();

          if (filteredItems.isEmpty) {
            return _buildFallbackItems();
          }

          return _buildItemGrid(filteredItems);
        } else {
          // No data or empty data
          return _buildFallbackItems();
        }
      },
    );
  }

  Future<List<Item>> _loadItems() async {
    try {
      final ItemService itemService = getIt.get<ItemService>();

      // If useFallbackItems is true, directly return fallback items
      if (widget.useFallbackItems) {
        print('Using fallback items as requested');
        return _getFallbackItems();
      }

      // Otherwise, fetch items from the server
      final dynamicItems = await itemService.fetchItems();

      if (dynamicItems.isEmpty) {
        print('No items returned from server, using fallback items');
        return _getFallbackItems();
      }

      // Convert DynamicItem objects to Item objects
      print('Successfully loaded ${dynamicItems.length} items from API');
      return dynamicItems.map((dynamicItem) {
        return itemService.convertToItem(dynamicItem);
      }).toList();
    } catch (e) {
      print('Error in _loadItems: $e');
      return _getFallbackItems();
    }
  }

  List<Item> _getFallbackItems() {
    final ItemService itemService= getIt.get<ItemService>();
    final dynamicItems = itemService.getFallbackItems();

    // Convert DynamicItem objects to Item objects
    return dynamicItems
        .map((dynamicItem) => itemService.convertToItem(dynamicItem))
        .toList();
  }

  Widget _buildFallbackItems() {
    print('Building fallback items');
    final fallbackItems = _getFallbackItems();
    return _buildItemGrid(fallbackItems);
  }

  Widget _buildItemGrid(List<Item> items) {
    // Responsive grid layout
    return LayoutBuilder(builder: (context, constraints) {
      // Calculate how many items can fit in a row based on screen width
      final double screenWidth = constraints.maxWidth;
      int crossAxisCount;
      double childAspectRatio;

      // Responsive grid based on screen width
      if (screenWidth > 600) {
        crossAxisCount = 3;
        childAspectRatio = 0.75;
      } else if (screenWidth > 400) {
        crossAxisCount = 2;
        childAspectRatio = 0.7;
      } else {
        // For very small screens, show one item per row
        crossAxisCount = 2;
        childAspectRatio = 0.65; // Taller cards for small screens
      }

      return Container(
        color: Colors.transparent,
        child: items.isEmpty
            ? _buildEmptyState()
            : GridView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                itemCount: items.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 16.0,
                  crossAxisSpacing: 12.0,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final int count = items.length;
                  final Animation<double> animation =
                      Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animationController!,
                      curve: Interval((1 / count) * index, 1.0,
                          curve: Curves.fastOutSlowIn),
                    ),
                  );
                  animationController?.forward();

                  return ItemCardView(
                    item: items[index],
                    animation: animation,
                    animationController: animationController,
                  );
                },
              ),
      );
    });
  }

  // Empty state widget when no items match the filters
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No items found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filter options',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Reset filters by rebuilding the widget
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filters'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }
}
