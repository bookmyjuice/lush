import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/get_it.dart';
import 'package:lush/services/item_service.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/cart_item.dart';
import 'package:lush/views/models/dynamic_item.dart';
import 'package:lush/views/models/item.dart';

class OrderItemScreen extends StatefulWidget {
  final String itemId;
  const OrderItemScreen({super.key, required this.itemId});

  @override
  State<OrderItemScreen> createState() => _OrderItemScreenState();
}

class _OrderItemScreenState extends State<OrderItemScreen> {
  final ItemService _itemService = getIt.get<ItemService>();
  DynamicItem? _item;
  bool _loading = true;
  String? _error;
  String _selectedSize = '200ml';
  int _quantity = 1;

  static const _sizes = ['200ml', '300ml', '500ml'];

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  Future<void> _loadItem() async {
    try {
      final items = await _itemService.fetchItems();
      final found = items.where((i) => i.itemID == widget.itemId).firstOrNull;
      if (mounted) {
        setState(() {
          _item = found;
          _loading = false;
          if (found == null) _error = 'Item not found';
        });
      }
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Map<String, dynamic>? get _selectedPriceData {
    if (_item == null) return null;
    final priceList = _item!.itemPrices;
    if (priceList.isEmpty) return null;
    for (final p in priceList) {
      final map = p as Map<String, dynamic>;
      final name = map['name'] as String? ?? '';
      if (name.contains(_selectedSize)) return map;
    }
    return priceList.first as Map<String, dynamic>;
  }

  double get _selectedPrice {
    final pd = _selectedPriceData;
    if (pd == null) return 0;
    return (pd['price'] as num?)?.toDouble() ?? 0;
  }

  double get _total => _selectedPrice * _quantity;

  void _addToCart() {
    if (_item == null || _selectedPriceData == null) return;
    final pd = _selectedPriceData!;
    final cartItem = CartItem(
      item: Item(
        id: _item!.itemID,
        name: _item!.displayName,
        servingSize: _selectedSize,
        price: _selectedPrice,
        itemPrices: [ItemPrice(id: pd['id'] as String? ?? '', name: _selectedSize, price: _selectedPrice)],
      ),
      quantity: _quantity,
      selectedSize: _selectedSize,
      selectedPrice: ItemPrice(id: pd['id'] as String? ?? '', name: _selectedSize, price: _selectedPrice),
    );
    context.read<CartBloc>().add(AddToCart(cartItem));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${_item!.displayName} added to cart'), backgroundColor: AppColors.success),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(_item?.displayName ?? 'Item Details',
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
              : _item == null
                  ? const Center(child: Text('Item not found'))
                  : SingleChildScrollView(
                      padding: EdgeInsets.all(16.r),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          _item!.displayName.replaceAll('-', ' ').split(' ').map((w) =>
                              '${w[0].toUpperCase()}${w.substring(1)}',).join(' '),
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                        ),
                        SizedBox(height: 12.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(color: AppColors.primaryOrange.withAlpha(30), borderRadius: BorderRadius.circular(8.r)),
                          child: Text((_item!.metaData['family'] as String? ?? 'delight').toUpperCase(),
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.primaryOrange),),
                        ),
                        SizedBox(height: 24.h),
                        Text('Select Size', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
                        SizedBox(height: 12.h),
                        Row(children: _sizes.map((s) {
                          final selected = s == _selectedSize;
                          return Padding(
                            padding: EdgeInsets.only(right: 12.w),
                            child: ChoiceChip(
                              label: Text(s), selected: selected, selectedColor: AppColors.primaryOrange,
                              labelStyle: TextStyle(color: selected ? AppColors.white : AppColors.lightTextPrimary, fontWeight: FontWeight.w600),
                              onSelected: (_) => setState(() => _selectedSize = s),
                            ),
                          );
                        }).toList(),),
                        SizedBox(height: 24.h),
                        Text('Quantity', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
                        SizedBox(height: 12.h),
                        Row(children: [
                          _QtyButton(icon: Icons.remove, onTap: _quantity > 1 ? () => setState(() => _quantity--) : null),
                          Container(width: 48.w, alignment: Alignment.center,
                              child: Text('$_quantity', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),),
                          _QtyButton(icon: Icons.add, onTap: _quantity < 10 ? () => setState(() => _quantity++) : null),
                        ],),
                        SizedBox(height: 24.h),
                        Container(
                          width: double.infinity, padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.lightDivider),),
                          child: Column(children: [
                            _PriceRow('Unit price', '₹${_selectedPrice.toStringAsFixed(0)}'),
                            SizedBox(height: 8.h),
                            _PriceRow('Quantity', '$_quantity'),
                            SizedBox(height: 8.h),
                            const Divider(color: AppColors.lightDivider),
                            SizedBox(height: 8.h),
                            _PriceRow('Total', '₹${_total.toStringAsFixed(0)}', bold: true),
                          ],),
                        ),
                        SizedBox(height: 24.h),
                        SizedBox(
                          width: double.infinity, height: 50.h,
                          child: ElevatedButton(
                            onPressed: _addToCart,
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),),
                            child: Text('Add to Cart', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.white)),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],),
                    ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _QtyButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.r, height: 40.r,
        decoration: BoxDecoration(color: onTap != null ? AppColors.primaryOrange : AppColors.grey.withAlpha(50), borderRadius: BorderRadius.circular(8.r)),
        child: Icon(icon, size: 20.sp, color: onTap != null ? AppColors.white : AppColors.grey),
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _PriceRow(this.label, this.value, {this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextSecondary)),
      Text(value, style: TextStyle(fontSize: bold ? 18.sp : 14.sp, fontWeight: bold ? FontWeight.bold : FontWeight.w500, color: bold ? AppColors.primaryOrange : AppColors.lightTextPrimary)),
    ],);
  }
}