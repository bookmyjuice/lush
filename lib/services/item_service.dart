import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/views/models/dynamic_item.dart';
import 'package:lush/views/models/item.dart';
import 'package:lush/views/models/item_data.dart';

class ItemService {
  final UserRepository _userRepository = getIt.get<UserRepository>();

  /// Get all items (ItemData objects)
  Future<List<ItemData>> getItems() async {
    try {
      List<Map<String, dynamic>> apiResponse =
          await _userRepository.getChargeItems();

      return apiResponse
          .map((json) => ItemData(
              id: json['id'] as String? ?? '',
              name: json['name'] as String? ?? 'Unknown Item',
              description: json['description'] as String?,
              status: json['status'] as String? ?? 'INACTIVE'))
          .toList();
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  /// Fetch items from backend and convert to DynamicItem objects
  Future<List<DynamicItem>> fetchItems() async {
    try {
      List<Map<String, dynamic>> apiResponse =
          await _userRepository.getChargeItems();

      List<DynamicItem> items = apiResponse
          .map((json) => DynamicItem.fromApiResponse(json))
          .where((item) =>
              item.isDisplayReady()) // Filter out inactive/incomplete items
          .toList();

      // Sort by popularity (if available) or alphabetically
      items.sort((a, b) {
        if (a.popularity != b.popularity) {
          return b.popularity
              .compareTo(a.popularity); // Higher popularity first
        }
        return a.displayName.compareTo(b.displayName); // Alphabetical fallback
      });

      return items;
    } catch (e) {
      print('Error fetching items from backend: $e');
      // Return fallback data based on static item list
      return getFallbackItems();
    }
  }

  /// Get fallback items based on the original static data
  List<DynamicItem> getFallbackItems() {
    return ItemData.tabIconsList.map((item) {
      return DynamicItem(
        itemID: item.itemID.toString(),
        name: item.titleTxt,
        description: '${item.titleTxt} juice',
        imagePath: item.imagePath,
        startColor: item.startColor,
        endColor: item.endColor,
        meals: item.meals ?? [],
        kacl: item.kacl,
        type: 'CHARGE',
        status: 'ACTIVE',
        enabledForCheckout: true,
        enabledInPortal: true,
        itemPrices: [
          {
            'id': '${item.itemID}_small',
            'name': 'Small (100ml)',
            'description': 'Perfect for a quick refreshment',
            'price': 9.99,
            'currencyCode': 'INR',
          },
          {
            'id': '${item.itemID}_medium',
            'name': 'Medium (250ml)',
            'description': 'Our most popular size',
            'price': 19.99,
            'currencyCode': 'INR',
          },
          {
            'id': '${item.itemID}_large',
            'name': 'Large (500ml)',
            'description': 'Great value for sharing',
            'price': 34.99,
            'currencyCode': 'INR',
          },
        ],
      );
    }).toList();
  }

  /// Convert DynamicItem to Item for use in the UI
  Item convertToItem(DynamicItem dynamicItem) {
    // Convert dynamic item prices to ItemPrice objects
    List<ItemPrice> itemPrices = [];
    if (dynamicItem.itemPrices.isNotEmpty) {
      itemPrices = dynamicItem.itemPrices.map((priceData) {
        return ItemPrice(
          id: (priceData['id'] as String?) ?? '',
          name: (priceData['name'] as String?) ?? '',
          description: (priceData['description'] as String?) ?? '',
          price:
              priceData['price'] is num ? (priceData['price'] as num).toDouble() : 0.0,
          currencyCode: (priceData['currencyCode'] as String?) ?? 'INR',
        );
      }).toList();
    } else {
      // Create default item prices if none are available
      itemPrices = [
        ItemPrice(
          id: '${dynamicItem.itemID}_small',
          name: 'Small (100ml)',
          description: 'Perfect for a quick refreshment',
          price: 9.99,
          currencyCode: 'INR',
        ),
        ItemPrice(
          id: '${dynamicItem.itemID}_medium',
          name: 'Medium (250ml)',
          description: 'Our most popular size',
          price: 19.99,
          currencyCode: 'INR',
        ),
        ItemPrice(
          id: '${dynamicItem.itemID}_large',
          name: 'Large (500ml)',
          description: 'Great value for sharing',
          price: 34.99,
          currencyCode: 'INR',
        ),
      ];
    }

    return Item(
      id: dynamicItem.itemID,
      name: dynamicItem
          .displayName, // Use displayName which prioritizes externalName
      description: dynamicItem.description,
      imagePath: dynamicItem.imagePath,
      titleTxt: dynamicItem.displayName, // For backward compatibility
      startColor: dynamicItem.startColor,
      servingSize: dynamicItem.servingSize,
      endColor: dynamicItem.endColor,
      meals: dynamicItem.meals,
      kacl: dynamicItem.kacl,
      price: itemPrices.isNotEmpty ? itemPrices[0].price : 0.0,
      rating: 4.5, // Default rating
      itemPrices: itemPrices,
      type: dynamicItem.type,
      status: dynamicItem.status,
      itemFamilyId: dynamicItem.itemFamilyId,
      metaData: dynamicItem.metaData,
    );
  }
}
