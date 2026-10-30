/// Price presentation helpers.
///
/// Every screen that shows money must go through these helpers so a missing
/// price renders as an em dash instead of a fabricated `₹0` / `₹9.99`
/// (the catalog API legitimately returns `price == null` for some item prices).
///
/// - [formatRupees] formats rupees, keeping paise only when they exist.
/// - [cheapestPricedOption] returns the cheapest option that actually has a
///   price — never the first entry of the list.
/// - [cheapestPrice] / [fromPriceLabel] build the "From ₹X" card label.
library;

import 'package:lush/views/models/item.dart';

/// Em dash used whenever a value is not known.
const String kPriceFallback = '—';

/// Formats [amount] as Indian rupees.
///
/// Whole amounts render as `₹249`; amounts with paise render as `₹249.50`.
/// A `null`, negative, `NaN` or infinite amount renders [fallback].
String formatRupees(num? amount, {String fallback = kPriceFallback}) {
  if (amount == null) return fallback;

  final double value = amount.toDouble();
  if (value.isNaN || value.isInfinite || value < 0) return fallback;

  final int rounded = value.round();
  if ((value - rounded).abs() < 0.005) return '₹$rounded';
  return '₹${value.toStringAsFixed(2)}';
}

/// The cheapest [ItemPrice] whose [ItemPrice.price] is a usable number.
///
/// Options without a price are ignored; `null` means "no price is known",
/// which callers must render with [kPriceFallback] rather than `₹0`.
ItemPrice? cheapestPricedOption(Iterable<ItemPrice> options) {
  ItemPrice? cheapest;
  for (final ItemPrice option in options) {
    final double? price = option.price;
    if (price == null || price.isNaN || price.isInfinite || price <= 0) {
      continue;
    }
    if (cheapest == null || price < cheapest.price!) cheapest = option;
  }
  return cheapest;
}

/// The cheapest known price across [options], or `null` when none is priced.
num? cheapestPrice(Iterable<ItemPrice> options) =>
    cheapestPricedOption(options)?.price;

/// `From ₹249`, or [kPriceFallback] when no option carries a price.
String fromPriceLabel(Iterable<ItemPrice> options, {String prefix = 'From '}) {
  final num? price = cheapestPrice(options);
  return price == null ? kPriceFallback : '$prefix${formatRupees(price)}';
}
