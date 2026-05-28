import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/get_it.dart';
import 'package:lush/services/item_service.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/dynamic_item.dart';

class OrderCatalogScreen extends StatefulWidget {
  const OrderCatalogScreen({super.key});
  @override
  State<OrderCatalogScreen> createState() => _OrderCatalogScreenState();
}

class _OrderCatalogScreenState extends State<OrderCatalogScreen> {
  final ItemService _itemService = getIt.get<ItemService>();
  late Future<List<DynamicItem>> _itemsFuture;
  String _selectedFamily = 'All';

  static const _families = ['All', 'delight', 'signature', 'premium'];

  @override
  void initState() {
    super.initState();
    _itemsFuture = _itemService.fetchItems();
  }

  void _retry() {
    setState(() {
      _itemsFuture = _itemService.fetchItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Order Juice',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      body: Column(
        children: [
          _buildFamilyTabs(),
          Expanded(child: FutureBuilder<List<DynamicItem>>(
            future: _itemsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                      SizedBox(height: 16.h),
                      Text('Failed to load items',
                          style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 16.sp)),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _retry,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              final items = snapshot.data!
                  .where((i) => i.itemFamilyId == 'bmj-item-family' || i.itemFamilyId.startsWith('bmj'))
                  .toList();

              final filtered = _selectedFamily == 'All'
                  ? items
                  : items.where((i) {
                      final family = i.metaData['family'] as String? ?? '';
                      return family == _selectedFamily;
                    }).toList();

              if (filtered.isEmpty) {
                return Center(
                  child: Text('No items found',
                      style: TextStyle(color: AppColors.lightTextSecondary, fontSize: 16.sp)),
                );
              }

              return GridView.builder(
                padding: EdgeInsets.all(16.r),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return _JuiceItemCard(
                    item: item,
                    onTap: () => Navigator.pushNamed(
                      context,
                      '/order-item',
                      arguments: item.itemID,
                    ),
                  );
                },
              );
            },
          )),
        ],
      ),
    );
  }

  Widget _buildFamilyTabs() {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: _families.map((f) {
            final selected = f == _selectedFamily;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: ChoiceChip(
                label: Text(f[0].toUpperCase() + f.substring(1)),
                selected: selected,
                selectedColor: AppColors.primaryOrange,
                labelStyle: TextStyle(
                  color: selected ? AppColors.white : AppColors.lightTextPrimary,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: (_) => setState(() => _selectedFamily = f),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _JuiceItemCard extends StatelessWidget {
  final DynamicItem item;
  final VoidCallback onTap;

  const _JuiceItemCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final family = item.metaData['family'] as String? ?? 'delight';
    final familyColor = _familyColor(family);
    final prices = item.itemPrices
        .map((p) => (p['price'] as num?)?.toDouble() ?? 0.0)
        .where((p) => p > 0)
        .toList();
    final lowest = prices.isEmpty ? '--' : '₹${prices.reduce((a, b) => a < b ? a : b).toStringAsFixed(0)}';
    final highest = prices.isEmpty ? '--' : '₹${prices.reduce((a, b) => a > b ? a : b).toStringAsFixed(0)}';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.lightDivider),
        ),
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Text(
                  item.displayName.replaceAll('-', ' ').split(' ').map((w) =>
                      w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' '),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.lightTextPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: familyColor.withAlpha(30),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                family.toUpperCase(),
                style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: familyColor),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              '$lowest – $highest',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryOrange,
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              height: 36.h,
              child: ElevatedButton(
                onPressed: onTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Add', style: TextStyle(fontSize: 14.sp, color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _familyColor(String family) {
    switch (family) {
      case 'delight':
        return AppColors.primaryOrange;
      case 'signature':
        return AppColors.secondaryTeal;
      case 'premium':
        return const Color(0xFF673AB7); // deep purple
      default:
        return AppColors.grey;
    }
  }
}