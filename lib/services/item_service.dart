import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/views/models/dynamic_item.dart';
import 'package:lush/views/models/item.dart';
import 'package:lush/views/models/item_data.dart';

import '../utils/app_logger.dart';

class ItemService {
  final UserRepository _userRepository = getIt.get<UserRepository>();

  /// Get all items (ItemData objects)
  Future<List<ItemData>> getItems() async {
    try {
      final List<Map<String, dynamic>> apiResponse =
          await _userRepository.getChargeItems();

      return apiResponse
          .map((json) => ItemData(
              id: json['id'] as String? ?? '',
              name: json['name'] as String? ?? 'Unknown Item',
              description: json['description'] as String?,
              status: json['status'] as String? ?? 'INACTIVE',),)
          .toList();
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  /// Fetch items from backend and convert to DynamicItem objects
  Future<List<DynamicItem>> fetchItems() async {
    try {
      final List<Map<String, dynamic>> apiResponse =
          await _userRepository.getChargeItems();

      final List<DynamicItem> items = apiResponse
          .map(DynamicItem.fromApiResponse)
          .where((item) =>
              item.isDisplayReady(),) // Filter out inactive/incomplete items
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
      appLogger.e('Error fetching items from backend', error: e);
      // Return empty list on error — UI will handle empty state
      return [];
    }
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
