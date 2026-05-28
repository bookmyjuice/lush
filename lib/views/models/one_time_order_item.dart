/// Represents a one-time order item selected by the user.
/// Built from Catalog → Item Detail → Cart pipeline.
class OneTimeOrderItem {
  final String itemId;
  final String itemPriceId;
  final String name;
  final String family;
  final String size;
  final int priceInPaise;
  final int quantity;

  const OneTimeOrderItem({
    required this.itemId,
    required this.itemPriceId,
    required this.name,
    required this.family,
    required this.size,
    required this.priceInPaise,
    this.quantity = 1,
  });

  double get priceInRupees => priceInPaise / 100;
  int get totalPaise => priceInPaise * quantity;
  double get totalRupees => totalPaise / 100;

  OneTimeOrderItem copyWith({int? quantity}) {
    return OneTimeOrderItem(
      itemId: itemId,
      itemPriceId: itemPriceId,
      name: name,
      family: family,
      size: size,
      priceInPaise: priceInPaise,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toChargebeeLineItem() => {
    'item_price_id': itemPriceId,
    'quantity': quantity,
    'unit_price': priceInPaise,
  };
}