import 'item.dart';

class Cart {
  Cart(this.items);
  List<Item> items;

  // Helper method to get total price
  double getTotalPrice() {
    double total = 0;
    for (var item in items) {
      total += item.price ?? 0;
    }
    return total;
  }

  // Helper method to get item count
  int getItemCount() {
    return items.length;
  }
}
