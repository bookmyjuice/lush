//When offering subscriptions of products or services,
//each entity that is made available for sale is represented by an “item” object.
//Items therefore represent the various plans, addons or charges
//that you offer as part of your product catalog.
//Non-metered items are charged upfront in Chargebee,
//while metered items are charged at the end of the billing cycle, based on usage.

class Item {
  String? id;
  String? description;
  bool? enabledForCheckout;
  bool? enabledInPortal;
  String? externalName;
  bool? giftable;
  String? itemFamilyId;
  String? jsonObject;
  Map<String, dynamic>? metaData;
  String? name;
  bool? shippable;
  String? status;
  String? type;
  String? unit;
  String? subscriptionId;
  bool? archived;
  bool? deleted;

  // Properties from JuiceItem
  String? imagePath;
  String? titleTxt;
  String? startColor;
  String? endColor;
  List<String>? meals;
  int? kacl;
  double? price;
  double? rating;

  List<ItemPrice>? itemPrices; // List of associated ItemPrice objects

  Item({
    this.id,
    this.description,
    this.enabledForCheckout,
    this.enabledInPortal,
    this.externalName,
    this.giftable,
    this.itemFamilyId,
    this.jsonObject,
    this.metaData,
    this.name,
    this.shippable,
    this.status,
    this.type,
    this.unit,
    this.subscriptionId,
    this.archived,
    this.deleted,
    this.itemPrices,
    // JuiceItem properties
    this.imagePath,
    this.titleTxt,
    this.startColor,
    this.endColor,
    this.meals,
    this.kacl,
    this.price,
    this.rating,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    // Handle item_prices field which could be in different formats
    List<ItemPrice>? itemPrices;
    if (json['item_prices'] != null) {
      if (json['item_prices'] is List) {
        itemPrices = (json['item_prices'] as List)
            .map((e) => e is Map<String, dynamic>
                ? ItemPrice.fromJson(e)
                : ItemPrice(id: e.toString()))
            .toList();
      }
    }

    return Item(
      id: json['id'],
      description: json['description'],
      enabledForCheckout: json['enabled_for_checkout'],
      enabledInPortal: json['enabled_in_portal'],
      externalName: json['external_name'],
      giftable: json['giftable'],
      itemFamilyId: json['item_family_id'],
      jsonObject: json['json_object'],
      metaData: json['meta_data'],
      name: json['name'],
      shippable: json['shippable'],
      status: json['status'],
      type: json['type'],
      unit: json['unit'],
      subscriptionId: json['subscription_id'],
      archived: json['archived'],
      deleted: json['deleted'],
      itemPrices: itemPrices,
      // JuiceItem properties
      imagePath: json['imagePath'],
      titleTxt: json['titleTxt'],
      startColor: json['startColor'],
      endColor: json['endColor'],
      meals: json['meals'] != null ? List<String>.from(json['meals']) : null,
      kacl: json['kacl'] != null
          ? (json['kacl'] is num
              ? (json['kacl'] as num).toInt()
              : int.tryParse(json['kacl'].toString()) ?? 0)
          : null,
      price: json['price'] != null
          ? (json['price'] is num
              ? (json['price'] as num).toDouble()
              : double.tryParse(json['price'].toString()) ?? 0.0)
          : null,
      rating: json['rating'] != null
          ? (json['rating'] is num
              ? (json['rating'] as num).toDouble()
              : double.tryParse(json['rating'].toString()) ?? 0.0)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['description'] = description;
    data['enabled_for_checkout'] = enabledForCheckout;
    data['enabled_in_portal'] = enabledInPortal;
    data['external_name'] = externalName;
    data['giftable'] = giftable;
    data['item_family_id'] = itemFamilyId;
    data['json_object'] = jsonObject;
    data['meta_data'] = metaData;
    data['name'] = name;
    data['shippable'] = shippable;
    data['status'] = status;
    data['type'] = type;
    data['unit'] = unit;
    data['subscription_id'] = subscriptionId;
    data['archived'] = archived;
    data['deleted'] = deleted;
    if (itemPrices != null) {
      data['item_prices'] = itemPrices!.map((e) => e.toJson()).toList();
    }

    // JuiceItem properties
    data['imagePath'] = imagePath;
    data['titleTxt'] = titleTxt;
    data['startColor'] = startColor;
    data['endColor'] = endColor;
    data['meals'] = meals;
    data['kacl'] = kacl;
    data['price'] = price;
    data['rating'] = rating;

    return data;
  }
}

class ItemPrice {
  String? id;
  String? accountingCategory1;
  String? accountingCategory2;
  String? accountingCategory3;
  String? accountingCategory4;
  String? accountingCode;
  int? createdAt;
  String? currencyCode;
  String? description;
  String? externalName;
  String? freeQuantityInDecimal;
  String? invoiceNotes;
  Map<String, dynamic>? metadata;
  String? name;
  int? period;
  String? periodUnit;
  double? price;
  String? pricingModel;
  String? status;
  String? taxProfileId;
  String? taxProfileName;
  String? taxProfileType;
  bool? trialAvailable;
  int? trialPeriod;
  String? trialPeriodUnit;
  int? updatedAt;
  String? itemId;

  ItemPrice({
    this.id,
    this.accountingCategory1,
    this.accountingCategory2,
    this.accountingCategory3,
    this.accountingCategory4,
    this.accountingCode,
    this.createdAt,
    this.currencyCode,
    this.description,
    this.externalName,
    this.freeQuantityInDecimal,
    this.invoiceNotes,
    this.metadata,
    this.name,
    this.period,
    this.periodUnit,
    this.price,
    this.pricingModel,
    this.status,
    this.taxProfileId,
    this.taxProfileName,
    this.taxProfileType,
    this.trialAvailable,
    this.trialPeriod,
    this.trialPeriodUnit,
    this.updatedAt,
    this.itemId,
  });

  factory ItemPrice.fromJson(Map<String, dynamic> json) {
    // Handle different key formats (snake_case vs camelCase)
    return ItemPrice(
      id: json['id'] ?? json['id'],
      accountingCategory1:
          json['accounting_category1'] ?? json['accountingCategory1'],
      accountingCategory2:
          json['accounting_category2'] ?? json['accountingCategory2'],
      accountingCategory3:
          json['accounting_category3'] ?? json['accountingCategory3'],
      accountingCategory4:
          json['accounting_category4'] ?? json['accountingCategory4'],
      accountingCode: json['accounting_code'] ?? json['accountingCode'],
      createdAt: json['created_at'] ?? json['createdAt'],
      currencyCode: json['currency_code'] ?? json['currencyCode'],
      description: json['description'],
      externalName: json['external_name'] ?? json['externalName'],
      freeQuantityInDecimal:
          json['free_quantity_in_decimal'] ?? json['freeQuantityInDecimal'],
      invoiceNotes: json['invoice_notes'] ?? json['invoiceNotes'],
      metadata: json['metadata'] ?? json['metaData'],
      name: json['name'],
      period: json['period'],
      periodUnit: json['period_unit'] ?? json['periodUnit'],
      price: json['price'] != null
          ? (json['price'] is num
              ? (json['price'] as num).toDouble()
              : double.tryParse(json['price'].toString()) ?? 0.0)
          : null,
      pricingModel: json['pricing_model'] ?? json['pricingModel'],
      status: json['status'],
      taxProfileId: json['tax_profile_id'] ?? json['taxProfileId'],
      taxProfileName: json['tax_profile_name'] ?? json['taxProfileName'],
      taxProfileType: json['tax_profile_type'] ?? json['taxProfileType'],
      trialAvailable: json['trial_available'] ?? json['trialAvailable'],
      trialPeriod: json['trial_period'] ?? json['trialPeriod'],
      trialPeriodUnit: json['trial_period_unit'] ?? json['trialPeriodUnit'],
      updatedAt: json['updated_at'] ?? json['updatedAt'],
      itemId: json['item_id'] ?? json['itemId'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['accounting_category1'] = accountingCategory1;
    data['accounting_category2'] = accountingCategory2;
    data['accounting_category3'] = accountingCategory3;
    data['accounting_category4'] = accountingCategory4;
    data['accounting_code'] = accountingCode;
    data['created_at'] = createdAt;
    data['currency_code'] = currencyCode;
    data['description'] = description;
    data['external_name'] = externalName;
    data['free_quantity_in_decimal'] = freeQuantityInDecimal;
    data['invoice_notes'] = invoiceNotes;
    data['metadata'] = metadata;
    data['name'] = name;
    data['period'] = period;
    data['period_unit'] = periodUnit;
    data['price'] = price;
    data['pricing_model'] = pricingModel;
    data['status'] = status;
    data['tax_profile_id'] = taxProfileId;
    data['tax_profile_name'] = taxProfileName;
    data['tax_profile_type'] = taxProfileType;
    data['trial_available'] = trialAvailable;
    data['trial_period'] = trialPeriod;
    data['trial_period_unit'] = trialPeriodUnit;
    data['updated_at'] = updatedAt;
    data['item_id'] = itemId;
    return data;
  }
}
