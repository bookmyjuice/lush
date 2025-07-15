class DynamicJuice {
  DynamicJuice({
    this.juiceID = '',
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
    this.seasonal = false,
    this.nutritionalInfo = const {},
    this.customization = const {},
  });

  String juiceID;
  String name;
  String externalName;
  String description;
  String imagePath;
  String startColor;
  String endColor;
  List<String> meals;
  int kacl; // keeping kacl for backward compatibility
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
  bool seasonal;
  Map<String, dynamic> nutritionalInfo;
  Map<String, dynamic> customization;

  /// Create DynamicJuice from backend API response
  factory DynamicJuice.fromApiResponse(Map<String, dynamic> json) {
    // Extract metadata if it exists
    Map<String, dynamic> metaData = json['metaData'] is Map<String, dynamic>
        ? json['metaData']
        : <String, dynamic>{};

    return DynamicJuice(
      juiceID: json['id']?.toString() ?? json['juiceID']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Juice',
      externalName:
          json['externalName']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imagePath: metaData['imagePath']?.toString() ??
          'assets/ABC.png', // default image
      startColor: metaData['startColor']?.toString() ?? '#FF6B6B',
      endColor: metaData['endColor']?.toString() ?? '#4ECDC4',
      meals: _parseStringList(metaData['meals']),
      kacl: metaData['calories'] ?? json['calories'] ?? json['kacl'] ?? 0,
      type: json['type']?.toString() ?? 'CHARGE',
      status: json['status']?.toString() ?? 'ACTIVE',
      unit: json['unit']?.toString() ?? '',
      itemFamilyId: json['itemFamilyId']?.toString() ?? '',
      enabledInPortal: json['enabledInPortal'] ?? false,
      enabledForCheckout: json['enabledForCheckout'] ?? true,
      isGiftable: json['isGiftable'] ?? false,
      isShippable: json['isShippable'] ?? false,
      deleted: json['deleted'] ?? false,
      category: metaData['category']?.toString() ?? 'juice',
      subcategory: metaData['subcategory']?.toString() ?? '',
      benefits: _parseStringList(metaData['benefits']),
      allergies: _parseStringList(metaData['allergies']),
      tags: _parseStringList(metaData['tags']),
      servingSize: metaData['servingSize']?.toString() ?? '300ml',
      shelfLife: metaData['shelfLife']?.toString() ?? '24 hours',
      preparationTime: metaData['preparationTime']?.toString() ?? '5 minutes',
      temperature: metaData['temperature']?.toString() ?? 'Cold',
      popularity: metaData['popularity'] ?? 0,
      seasonal: metaData['seasonal'] ?? false,
      nutritionalInfo: metaData['nutritionalInfo'] is Map<String, dynamic>
          ? metaData['nutritionalInfo']
          : {},
      customization: metaData['customization'] is Map<String, dynamic>
          ? metaData['customization']
          : {},
    );
  }

  /// Parse various formats of string lists from API
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];

    if (value is List<String>) {
      return value;
    } else if (value is List) {
      return value.map((item) => item.toString()).toList();
    } else if (value is String) {
      // Handle comma-separated strings
      if (value.contains(',')) {
        return value
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } else {
        return [value];
      }
    }

    return [];
  }

  /// Convert to the old Juice format for backward compatibility
  Map<String, dynamic> toOldJuiceFormat() {
    return {
      'juiceID': juiceID,
      'imagePath': imagePath,
      'titleTxt':
          displayName, // Use display name which prioritizes externalName
      'startColor': startColor,
      'endColor': endColor,
      'meals': meals,
      'kacl': kacl,
    };
  }

  /// Check if this juice has all required fields for display
  bool isDisplayReady() {
    return (name.isNotEmpty || externalName.isNotEmpty) &&
        juiceID.isNotEmpty &&
        status.toUpperCase() == 'ACTIVE' &&
        enabledForCheckout &&
        !deleted;
  }

  /// Get display name (fallback to name, then ID if externalName is empty)
  String get displayName {
    if (externalName.isNotEmpty) return externalName;
    if (name.isNotEmpty) return name;
    return juiceID;
  }

  /// Get display description (fallback to a default message)
  String get displayDescription => description.isNotEmpty
      ? description
      : 'Fresh cold-pressed juice made with premium ingredients';

  /// Get display calories with unit
  String get displayCalories =>
      kacl > 0 ? '$kacl kcal' : 'Calories info not available';

  /// Get formatted ingredients/meals
  String get displayIngredients {
    if (meals.isNotEmpty) {
      return meals.join(', ');
    }
    return 'Premium fresh ingredients';
  }

  /// Get display benefits
  String get displayBenefits {
    if (benefits.isNotEmpty) {
      return benefits.join(', ');
    }
    return 'Healthy and nutritious';
  }

  /// Get display tags
  String get displayTags {
    if (tags.isNotEmpty) {
      return tags.join(', ');
    }
    return '';
  }

  /// Check if customization is available
  bool get hasCustomization {
    return customization.isNotEmpty;
  }

  /// Get available customization options
  Map<String, List<String>> get customizationOptions {
    Map<String, List<String>> options = {};

    customization.forEach((key, value) {
      if (value is List) {
        options[key] = value.map((item) => item.toString()).toList();
      }
    });

    return options;
  }

  /// Get nutritional info as formatted string
  String get displayNutritionalInfo {
    if (nutritionalInfo.isEmpty) return 'Nutritional info not available';

    List<String> info = [];
    nutritionalInfo.forEach((key, value) {
      info.add('$key: $value');
    });

    return info.join(', ');
  }

  /// Debug information
  @override
  String toString() {
    return 'DynamicJuice{juiceID: $juiceID, name: $name, status: $status, enabled: $enabledForCheckout}';
  }
}
