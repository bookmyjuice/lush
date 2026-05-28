class DynamicItem {
  DynamicItem({
    this.itemID = '',
    this.name = '',
    this.externalName = '',
    this.description = '',
    this.imagePath = '',
    this.startColor = '',
    this.endColor = '',
    this.meals = const [],
    this.kacl = 0,
    this.type = '',
    this.status = '',
    this.unit = '',
    this.itemFamilyId = '',
    this.enabledInPortal = false,
    this.enabledForCheckout = false,
    this.isGiftable = false,
    this.isShippable = false,
    this.deleted = false,
    this.category = '',
    this.subcategory = '',
    this.benefits = const [],
    this.allergies = const [],
    this.tags = const [],
    this.servingSize = '',
    this.shelfLife = '',
    this.preparationTime = '',
    this.temperature = '',
    this.popularity = 0,
    this.itemPrices = const [],
    this.metaData = const {},
  });

  String itemID;
  String name;
  String externalName;
  String description;
  String imagePath;
  String startColor;
  String endColor;
  List<String> meals;
  int kacl;
  String type;
  String status;
  String unit;
  String itemFamilyId;
  bool enabledInPortal;
  bool enabledForCheckout;
  bool isGiftable;
  bool isShippable;
  bool deleted;
  String category;
  String subcategory;
  List<String> benefits;
  List<String> allergies;
  List<String> tags;
  String servingSize;
  String shelfLife;
  String preparationTime;
  String temperature;
  int popularity;
  List<dynamic> itemPrices;
  Map<String, dynamic> metaData;

  // Get the display name (prioritize externalName if available)
  String get displayName => externalName.isNotEmpty ? externalName : name;

  // Check if the item is ready to be displayed
  bool isDisplayReady() {
    return status == 'ACTIVE' &&
        !deleted &&
        enabledForCheckout &&
        (name.isNotEmpty || externalName.isNotEmpty);
  }

  // Chargebee returns snake_case keys.
  // camelCase fallback supports legacy internal API calls.
  // Reference: docs/data_models_map.md
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return false;
  }

  // Create from API response
  static DynamicItem fromApiResponse(Map<String, dynamic> json) {
    // Extract item prices if available
    List<dynamic> itemPrices = [];
    final rawPrices = json['item_prices'] ?? json['itemPrices'];
    if (rawPrices is List) {
      itemPrices = rawPrices;
    }

    // Extract metadata if available (Chargebee: 'metadata', legacy: 'metaData')
    Map<String, dynamic> metaData = {};
    final rawMeta = json['metadata'] ?? json['metaData'];
    if (rawMeta is Map) {
      metaData = Map<String, dynamic>.from(rawMeta);
    }

    // Extract colors from metadata or use defaults
    String startColor = '#FFCC80'; // Default start color
    String endColor = '#FF9800'; // Default end color
    String imagePath = 'assets/default_item.png';
    String servingSize = '200ml';

    if (metaData.containsKey('startColor') &&
        metaData['startColor'] is String) {
      startColor = metaData['startColor'] as String;
    }

    if (metaData.containsKey('servingSize') &&
        metaData['servingSize'] is String) {
      servingSize = metaData['servingSize'] as String;
    }

    if (metaData.containsKey('imagePath') && metaData['imagePath'] is String) {
      imagePath = metaData['imagePath'] as String;
    }

    if (metaData.containsKey('endColor') && metaData['endColor'] is String) {
      endColor = metaData['endColor'] as String;
    }

    // Extract meals/ingredients if available
    List<String> meals = [];
    if (json.containsKey('ingredients') && json['ingredients'] is List) {
      meals = List<String>.from(json['ingredients'] as Iterable);
    } else if (metaData.containsKey('ingredients') &&
        metaData['ingredients'] is List) {
      meals = List<String>.from(metaData['ingredients'] as List);
    }

    // Extract calories if available
    int kacl = 0;
    if (json.containsKey('calories') && json['calories'] is int) {
      kacl = json['calories'] as int;
    } else if (metaData.containsKey('calories')) {
      try {
        kacl = int.parse(metaData['calories'].toString());
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return DynamicItem(
      itemID: (json['id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      externalName: (json['external_name'] ?? json['externalName'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      imagePath: imagePath,
      startColor: startColor,
      endColor: endColor,
      meals: meals,
      kacl: kacl,
      type: (json['type'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      unit: (json['unit'] ?? '') as String,
      itemFamilyId: (json['item_family_id'] ?? json['itemFamilyId'] ?? '') as String,
      enabledInPortal: _parseBool(json['enabled_in_portal'] ?? json['enabledInPortal']),
      enabledForCheckout: _parseBool(json['enabled_for_checkout'] ?? json['enabledForCheckout']),
      isGiftable: _parseBool(json['giftable'] ?? json['isGiftable']),
      isShippable: _parseBool(json['shippable'] ?? json['isShippable']),
      deleted: _parseBool(json['deleted']),
      category: json['category'] as String? ?? '',
      subcategory: json['subcategory'] as String? ?? '',
      benefits: json.containsKey('benefits') && json['benefits'] is List
          ? List<String>.from(json['benefits'] as Iterable)
          : [],
      allergies: json.containsKey('allergies') && json['allergies'] is List
          ? List<String>.from(json['allergies'] as Iterable)
          : [],
      tags: json.containsKey('tags') && json['tags'] is List
          ? List<String>.from(json['tags'] as Iterable)
          : [],
      servingSize: servingSize,
      shelfLife: (json['shelf_life'] ?? json['shelfLife']) as String? ?? '',
      preparationTime: (json['preparation_time'] ?? json['preparationTime']) as String? ?? '',
      temperature: (json['temperature'] ?? '') as String? ?? '',
      popularity: (json['popularity'] ?? 0) as int? ?? 0,
      itemPrices: itemPrices.map((ip) {
        if (ip is Map && ip.containsKey('price')) {
          // Create a new map with price divided by 100
          return {
            ...ip,
            'price': (ip['price'] ?? 0) / 100,
          };
        }
        return ip;
      }).toList(),
      metaData: metaData,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'itemID': itemID,
      'name': name,
      'externalName': externalName,
      'description': description,
      'imagePath': imagePath,
      'startColor': startColor,
      'endColor': endColor,
      'meals': meals,
      'kacl': kacl,
      'type': type,
      'status': status,
      'unit': unit,
      'itemFamilyId': itemFamilyId,
      'enabledInPortal': enabledInPortal,
      'enabledForCheckout': enabledForCheckout,
      'isGiftable': isGiftable,
      'isShippable': isShippable,
      'deleted': deleted,
      'category': category,
      'subcategory': subcategory,
      'benefits': benefits,
      'allergies': allergies,
      'tags': tags,
      'servingSize': servingSize,
      'shelfLife': shelfLife,
      'preparationTime': preparationTime,
      'temperature': temperature,
      'popularity': popularity,
      'itemPrices': itemPrices.map((ip) {
        if (ip is Map && ip.containsKey('price')) {
          // Create a new map with price divided by 100
          return {
            ...ip,
            'price': (ip['price'] ?? 0) / 100,
          };
        }
        return ip;
      }).toList(),
      'metaData': metaData,
    };
  }
}
