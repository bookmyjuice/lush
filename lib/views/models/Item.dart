//When offering subscriptions of products or services,
//each entity that is made available for sale is represented by an “item” object.
//Items therefore represent the various plans, addons or charges
//that you offer as part of your product catalog.
//Non-metered items are charged upfront in Chargebee,
//while metered items are charged at the end of the billing cycle, based on usage.

class Item {
  String? description;
  bool? enabledforcheckout;
  bool? enabledinportal;
  String? id;
  bool? isgiftable;
  bool? isshippable;
  String? itemapplicability;
  String? name;
  String? object;
  double? resourceversion;
  String? status;
  String? type;
  int? updatedat;

  Item(
      {this.description,
      this.enabledforcheckout,
      this.enabledinportal,
      this.id,
      this.isgiftable,
      this.isshippable,
      this.itemapplicability,
      this.name,
      this.object,
      this.resourceversion,
      this.status,
      this.type,
      this.updatedat});

  Item.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    enabledforcheckout = json['enabled_for_checkout'];
    enabledinportal = json['enabled_in_portal'];
    id = json['id'];
    isgiftable = json['is_giftable'];
    isshippable = json['is_shippable'];
    itemapplicability = json['item_applicability'];
    name = json['name'];
    object = json['object'];
    resourceversion = json['resource_version'];
    status = json['status'];
    type = json['type'];
    updatedat = json['updated_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['description'] = description;
    data['enabled_for_checkout'] = enabledforcheckout;
    data['enabled_in_portal'] = enabledinportal;
    data['id'] = id;
    data['is_giftable'] = isgiftable;
    data['is_shippable'] = isshippable;
    data['item_applicability'] = itemapplicability;
    data['name'] = name;
    data['object'] = object;
    data['resource_version'] = resourceversion;
    data['status'] = status;
    data['type'] = type;
    data['updated_at'] = updatedat;
    return data;
  }
}
