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

  // Create from API response
  static DynamicItem fromApiResponse(Map<String, dynamic> json) {
    // Extract item prices if available
    List<dynamic> itemPrices = [];
    if (json.containsKey('itemPrices') && json['itemPrices'] is List) {
      itemPrices = json['itemPrices'];
    }

    // Extract metadata if available
    Map<String, dynamic> metaData = {};
    if (json.containsKey('metaData') && json['metaData'] is Map) {
      metaData = Map<String, dynamic>.from(json['metaData']);
    }

    // Extract colors from metadata or use defaults
    String startColor = '#FFCC80'; // Default start color
    String endColor = '#FF9800'; // Default end color

    if (metaData.containsKey('startColor') &&
        metaData['startColor'] is String) {
      startColor = metaData['startColor'];
    }

    if (metaData.containsKey('endColor') && metaData['endColor'] is String) {
      endColor = metaData['endColor'];
    }

    // Extract meals/ingredients if available
    List<String> meals = [];
    if (json.containsKey('ingredients') && json['ingredients'] is List) {
      meals = List<String>.from(json['ingredients']);
    } else if (metaData.containsKey('ingredients') &&
        metaData['ingredients'] is List) {
      meals = List<String>.from(metaData['ingredients']);
    }

    // Extract calories if available
    int kacl = 0;
    if (json.containsKey('calories') && json['calories'] is int) {
      kacl = json['calories'];
    } else if (metaData.containsKey('calories')) {
      try {
        kacl = int.parse(metaData['calories'].toString());
      } catch (e) {
        // Ignore parsing errors
      }
    }

    return DynamicItem(
      itemID: json['id'] ?? '',
      name: json['name'] ?? '',
      externalName: json['externalName'] ?? '',
      description: json['description'] ?? '',
      imagePath: json['imageUrl'] ?? 'assets/default_item.png',
      startColor: startColor,
      endColor: endColor,
      meals: meals,
      kacl: kacl,
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      unit: json['unit'] ?? '',
      itemFamilyId: json['itemFamilyId'] ?? '',
      enabledInPortal: json['enabledInPortal'] ?? false,
      enabledForCheckout: json['enabledForCheckout'] ?? false,
      isGiftable: json['isGiftable'] ?? false,
      isShippable: json['isShippable'] ?? false,
      deleted: json['deleted'] ?? false,
      category: json['category'] ?? '',
      subcategory: json['subcategory'] ?? '',
      benefits: json.containsKey('benefits') && json['benefits'] is List
          ? List<String>.from(json['benefits'])
          : [],
      allergies: json.containsKey('allergies') && json['allergies'] is List
          ? List<String>.from(json['allergies'])
          : [],
      tags: json.containsKey('tags') && json['tags'] is List
          ? List<String>.from(json['tags'])
          : [],
      servingSize: json['servingSize'] ?? '',
      shelfLife: json['shelfLife'] ?? '',
      preparationTime: json['preparationTime'] ?? '',
      temperature: json['temperature'] ?? '',
      popularity: json['popularity'] ?? 0,
      itemPrices: itemPrices,
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
      'itemPrices': itemPrices,
      'metaData': metaData,
    };
  }
}
