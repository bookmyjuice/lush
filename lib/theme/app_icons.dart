/// BookMyJuice Design System Icons
///
/// Centralized icon constants for consistent usage across the app.
library;

import 'package:flutter/material.dart';

/// BMJ icon constants.
///
/// Follows Material 3 icon guidelines:
/// - Default size: 24dp
/// - Small size: 20dp
/// - Large size: 32dp
/// - Touch target minimum: 48x48dp
class AppIcons {
  AppIcons._();

  // ── Navigation ──
  static const IconData home = Icons.home_outlined;
  static const IconData search = Icons.search;
  static const IconData cart = Icons.shopping_cart_outlined;
  static const IconData profile = Icons.person_outline;

  // ── Actions ──
  static const IconData add = Icons.add;
  static const IconData remove = Icons.remove;
  static const IconData close = Icons.close;
  static const IconData check = Icons.check;
  static const IconData edit = Icons.edit_outlined;
  static const IconData delete = Icons.delete_outline;
  static const IconData share = Icons.share_outlined;
  static const IconData favorite = Icons.favorite_outline;
  static const IconData favoriteFilled = Icons.favorite;

  // ── Status ──
  static const IconData success = Icons.check_circle_outline;
  static const IconData error = Icons.error_outline;
  static const IconData warning = Icons.warning_amber_outlined;
  static const IconData info = Icons.info_outline;

  // ── Product / Juice ──
  static const IconData juice = Icons.local_drink_outlined;
  static const IconData subscription = Icons.repeat;
  static const IconData order = Icons.receipt_long;
  static const IconData delivery = Icons.local_shipping_outlined;
  static const IconData location = Icons.location_on_outlined;

  // ── Account / Auth ──
  static const IconData email = Icons.email_outlined;
  static const IconData phone = Icons.phone_outlined;
  static const IconData lock = Icons.lock_outline;
  static const IconData visibility = Icons.visibility_outlined;
  static const IconData visibilityOff = Icons.visibility_off_outlined;

  // ── Payment ──
  static const IconData payment = Icons.payment_outlined;
  static const IconData invoice = Icons.receipt_outlined;
  static const IconData wallet = Icons.account_balance_wallet_outlined;
}
