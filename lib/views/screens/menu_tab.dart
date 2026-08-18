/// Glassmorphism Menu Tab — Combined One-Time Order + Subscription
///
/// Segment toggle at top: "One-Time" | "Subscribe"
/// One-Time: three-way category toggle (Delight/Signature/Premium) + product cards with minimum price
/// Subscribe: three-way category toggle + Weekly/Monthly cards with size options → Chargebee checkout
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart' hide AddToCart;
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/models/cart_item.dart';
import 'package:lush/views/models/item.dart';
import 'package:lush/widgets/glass_card.dart';
import 'dart:ui';

/// Menu tab with One-Time / Subscribe segment toggle.
class MenuTab extends StatefulWidget {
  const MenuTab({super.key});

  @override
  MenuTabState createState() => MenuTabState();
}

class MenuTabState extends State<MenuTab> {
  int _segmentIndex = 0;
  String? _selectedCategory; // delight, signature, premium (for one-time)
  String? _selectedSubCategory; // delight, signature, premium (for subscription)
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> _cachedOneTimeCategories = [];

  static const List<String> _allCategories = ['delight', 'signature', 'premium'];

  @override
  void initState() {
    super.initState();
    _selectedCategory = 'delight';
    _selectedSubCategory = 'delight';
    context.read<ProductCatalogBloc>().add(const LoadProductCatalog());
    context.read<SubscriptionBloc>().add(const LoadSubscriptionPlans());
    // Auto-filter only after catalog data is loaded
    context.read<ProductCatalogBloc>().stream.listen((state) {
      if (state is ProductCatalogLoaded && state.categories.isNotEmpty) {
        if (_selectedCategory != null && mounted) {
          _cachedOneTimeCategories = List<String>.from(state.categories);
          context.read<ProductCatalogBloc>().add(
            FilterByCategory(category: _selectedCategory!),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final bgColor = isDark ? AppColors.glassBg : AppColors.glassBgLight;

    return Container(
      color: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
              child: _buildSearchBar(isDark),
            ),
            // ── Segment Toggle ──
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _GlassSegmentToggle(
                segments: const ['One-Time', 'Subscribe'],
                selectedIndex: _segmentIndex,
                onSegmentChanged: (index) {
                  setState(() => _segmentIndex = index);
                },
                isDark: isDark,
              ),
            ),
            SizedBox(height: 12.h),
            // ── Content ──
            Expanded(
              child: _segmentIndex == 0
                  ? _buildOneTimeContent(isDark)
                  : _buildSubscribeContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search Bar ──────────────────────────────────────────────────────────
  Widget _buildSearchBar(bool isDark) {
    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.lg,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search juices...',
          hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 14.sp, color: AppColors.glassTextDim),
          prefixIcon: const Icon(Icons.search, color: AppColors.glassTextDim, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18, color: AppColors.glassTextDim),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                    context.read<ProductCatalogBloc>().add(const SearchProducts(query: ''));
                  },
                )
              : null,
          border: InputBorder.none,
          filled: false,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.sp,
          color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
          context.read<ProductCatalogBloc>().add(SearchProducts(query: value));
        },
      ),
    );
  }

  // ═══════════════════ THREE-WAY CATEGORY TOGGLE ══════════════════════════
  Widget _buildCategoryToggle({
    required String? selected,
    required ValueChanged<String> onChanged,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: _allCategories.map((cat) {
          final isSel = selected == cat;
          final color = _categoryColor(cat);
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 3.w),
              child: GestureDetector(
                onTap: () => onChanged(cat),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSel ? color.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSel ? color : (isDark ? AppColors.glassBorderSubtle : AppColors.glassBorderLight),
                      width: isSel ? 1.5 : 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(_categoryIcon(cat), size: 18, color: isSel ? color : AppColors.glassTextDim),
                      SizedBox(height: 4.h),
                      Text(
                        _categoryDisplay(cat),
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                          color: isSel ? color : AppColors.glassTextDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══ ONE-TIME CONTENT ═══════════════════════════════════════════════════
  Widget _buildOneTimeContent(bool isDark) {
    return BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
      builder: (context, state) {
        List<CatalogItem> items = [];

        if (state is ProductCatalogLoaded) {
          items = state.items;
          _cachedOneTimeCategories = state.categories;
        } else if (state is ProductCatalogFiltered) {
          items = state.items;
        } else if (state is ProductCatalogLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductCatalogEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.glassTextDim),
                SizedBox(height: 16.h),
                Text('No products found', style: TextStyle(fontSize: 16.sp, color: AppColors.glassTextDim)),
              ],
            ),
          );
        } else if (state is ProductCatalogError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.glassTextDim),
                SizedBox(height: 16.h),
                Text(state.message, style: const TextStyle(color: AppColors.glassTextDim)),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => context.read<ProductCatalogBloc>().add(const LoadProductCatalog()),
                  child: const GlassCard(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    borderRadius: AppRadius.lg,
                    child: Text('Retry'),
                  ),
                ),
              ],
            ),
          );
        }

        // Filter by selected category
        if (_selectedCategory != null) {
          items = items.where((item) =>
              item.category.toLowerCase() == _selectedCategory!.toLowerCase()).toList();
        }

        return Column(
          children: [
            // Three-way category toggle
            _buildCategoryToggle(
              selected: _selectedCategory,
              onChanged: (cat) {
                setState(() => _selectedCategory = cat);
                context.read<ProductCatalogBloc>().add(FilterByCategory(category: cat));
              },
              isDark: isDark,
            ),
            SizedBox(height: 8.h),
            // Product grid
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text('No items in $_selectedCategory', style: TextStyle(color: AppColors.glassTextDim)))
                  : GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                      ),
                      itemCount: items.length,
                      itemBuilder: (context, index) => _buildProductCard(items[index], isDark),
                    ),
            ),
          ],
        );
      },
    );
  }

  /// Product card showing minimum available price
  Widget _buildProductCard(CatalogItem item, bool isDark) {
    // Find the cheapest price (smallest size)
    ItemPrice? cheapest;
    if (item.prices.isNotEmpty) {
      cheapest = item.prices.reduce((a, b) =>
          (a.price ?? double.infinity) < (b.price ?? double.infinity) ? a : b);
    }

    return GlassCard(
      padding: EdgeInsets.zero,
      borderRadius: AppRadius.lg,
      onTap: () => _showSizeSelectionDialog(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gradient image area
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_hexToColor(item.startColor), _hexToColor(item.endColor)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
              ),
              child: Center(
                child: Icon(Icons.local_drink, size: 48, color: Colors.white.withValues(alpha: 0.6)),
              ),
            ),
          ),
          // Info area
          Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category tag
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                  decoration: BoxDecoration(
                    color: _categoryColor(item.category).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: _categoryColor(item.category)),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Poppins', fontSize: 14.sp, fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text('${item.calories} cal',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 11.sp, color: AppColors.glassTextDim)),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      cheapest != null ? 'From ₹${cheapest.price?.toStringAsFixed(0) ?? '0'}' : 'From ₹75',
                      style: TextStyle(
                        fontFamily: 'Poppins', fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.glassAccent,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.glassAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(color: AppColors.glassAccent.withValues(alpha: 0.3), width: 0.5),
                      ),
                      child: const Icon(Icons.add, size: 18, color: AppColors.glassAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSizeSelectionDialog(CatalogItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _SizeSelectionSheet(item: item),
    );
  }

  // ═══ SUBSCRIBE CONTENT ═════════════════════════════════════════════════
  Widget _buildSubscribeContent(bool isDark) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<SubscriptionPlan> allPlans = [];
        if (state is SubscriptionPlansLoaded) {
          allPlans = state.plans;
        }

    if (allPlans.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.subscriptions_outlined, size: 64, color: AppColors.glassTextDim),
            SizedBox(height: 16.h),
            Text(
              state is SubscriptionError ? 'Loading plans...' : 'No subscription plans available',
              style: TextStyle(fontSize: 16.sp, color: AppColors.glassTextDim)),
            SizedBox(height: 16.h),
            GestureDetector(
              onTap: () => context.read<SubscriptionBloc>().add(const LoadSubscriptionPlans()),
              child: const GlassCard(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                borderRadius: AppRadius.lg,
                child: Text('Retry'),
              ),
            ),
          ],
        ),
      );
    }

        // Filter by selected category
        final filtered = allPlans
            .where((p) => p.category == _selectedSubCategory)
            .toList();

        // Separate weekly and monthly plans
        final weeklyPlans = filtered.where((p) => p.period == 'Weekly').toList();
        final monthlyPlans = filtered.where((p) => p.period == 'Monthly').toList();

        return Column(
          children: [
            // Three-way category toggle
            _buildCategoryToggle(
              selected: _selectedSubCategory,
              onChanged: (cat) {
                setState(() => _selectedSubCategory = cat);
              },
              isDark: isDark,
            ),
            SizedBox(height: 8.h),
            // Weekly/Monthly cards
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                children: [
                  // Weekly card
                  if (weeklyPlans.isNotEmpty)
                    _buildPeriodCard(
                      title: 'Weekly',
                      icon: Icons.calendar_view_week,
                      plans: weeklyPlans,
                      catColor: _categoryColor(_selectedSubCategory ?? 'delight'),
                      isDark: isDark,
                    ),
                  SizedBox(height: 12.h),
                  // Monthly card
                  if (monthlyPlans.isNotEmpty)
                    _buildPeriodCard(
                      title: 'Monthly',
                      icon: Icons.calendar_month,
                      plans: monthlyPlans,
                      catColor: _categoryColor(_selectedSubCategory ?? 'delight'),
                      isDark: isDark,
                    ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  /// Card for Weekly or Monthly section, containing clickable size sub-options
  Widget _buildPeriodCard({
    required String title,
    required IconData icon,
    required List<SubscriptionPlan> plans,
    required Color catColor,
    required bool isDark,
  }) {
    if (plans.isEmpty) return const SizedBox.shrink();

    // Sort by size
    plans.sort((a, b) => int.parse(a.sizeLabel).compareTo(int.parse(b.sizeLabel)));

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [catColor, catColor.withValues(alpha: 0.7)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              SizedBox(width: 10.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          // Size options as clickable tiles
          ...plans.map((plan) {
            final priceStr = plan.price != null
                ? '₹${(plan.price is int ? (plan.price as int) / 100 : plan.price).toStringAsFixed(0)}'
                : 'N/A';

            return GestureDetector(
              onTap: () => _createSubscriptionAndNavigate(context, plan.id),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: catColor.withValues(alpha: 0.25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: catColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            '${plan.sizeLabel}ml',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: catColor,
                            ),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          plan.name,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.sp,
                            color: isDark ? AppColors.glassTextDim : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          '$priceStr/$title',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.glassAccent : AppColors.primaryGreen,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(Icons.arrow_forward_ios, size: 14, color: catColor),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Create subscription and navigate to Chargebee hosted checkout
  Future<void> _createSubscriptionAndNavigate(BuildContext context, String planId) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final service = SubscriptionService();
      final result = await service.createSubscription(planId);
      final url = result['url'] as String?;

      if (mounted) Navigator.pop(context); // dismiss loading

      if (url != null && url.isNotEmpty && mounted) {
        Navigator.pushNamed(context, '/subscription-checkout', arguments: url);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to get checkout: ${result['message'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  // ─── Category Helpers ───────────────────────────────────────────────────
  String _categoryDisplay(String cat) {
    switch (cat) {
      case 'delight': return 'Delight';
      case 'signature': return 'Signature';
      case 'premium': return 'Premium';
      default: return cat;
    }
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'delight': return AppColors.success;
      case 'signature': return AppColors.info;
      case 'premium': return AppColors.primaryOrangeDark;
      default: return AppColors.glassAccent;
    }
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'delight': return Icons.eco;
      case 'signature': return Icons.auto_awesome;
      case 'premium': return Icons.star;
      default: return Icons.category;
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    return AppColors.glassAccent;
  }
}

// ═══ Glass Segment Toggle ═══════════════════════════════════════════════
class _GlassSegmentToggle extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onSegmentChanged;
  final bool isDark;

  const _GlassSegmentToggle({
    required this.segments,
    required this.selectedIndex,
    required this.onSegmentChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassSurface.withValues(alpha: 0.8) : AppColors.glassSurfaceLight.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: isDark ? AppColors.glassBorderSubtle : AppColors.glassBorderLight),
          ),
          child: Row(
            children: List.generate(segments.length, (index) {
              final isSelected = index == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onSegmentChanged(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.glassAccent.withValues(alpha: 0.25) : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      segments[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? AppColors.glassAccent : (isDark ? AppColors.glassTextDim : AppColors.lightTextSecondary),
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ═══ Size Selection Bottom Sheet ════════════════════════════════════════
class _SizeSelectionSheet extends StatefulWidget {
  final CatalogItem item;
  const _SizeSelectionSheet({required this.item});

  @override
  State<_SizeSelectionSheet> createState() => _SizeSelectionSheetState();
}

class _SizeSelectionSheetState extends State<_SizeSelectionSheet> {
  ItemPrice? _selectedPrice;

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.glassElevated : AppColors.glassElevatedLight,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: isDark ? AppColors.glassBorder : AppColors.glassBorderLight),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_hexToColor(widget.item.startColor), _hexToColor(widget.item.endColor)],
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: const Icon(Icons.local_drink, color: Colors.white, size: 28),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item.name, style: TextStyle(fontFamily: 'Poppins', fontSize: 18.sp, fontWeight: FontWeight.w600, color: isDark ? AppColors.glassText : AppColors.lightTextPrimary)),
                    Text('Select size', style: TextStyle(fontFamily: 'Inter', fontSize: 13.sp, color: AppColors.glassTextDim)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.glassSurface.withValues(alpha: 0.6) : AppColors.glassSurfaceLight.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: AppColors.glassTextDim),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ...widget.item.prices.map((price) {
            final isSelected = _selectedPrice == price;
            return GestureDetector(
              onTap: () => setState(() => _selectedPrice = price),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.glassAccent.withValues(alpha: 0.1) : (isDark ? AppColors.glassSurface : AppColors.glassSurfaceLight),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected ? AppColors.glassAccent.withValues(alpha: 0.5) : (isDark ? AppColors.glassBorderSubtle : AppColors.glassBorderLight),
                    width: isSelected ? 1 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(child: Text(price.name ?? 'Standard', style: TextStyle(fontFamily: 'Inter', fontSize: 14.sp, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400, color: isDark ? AppColors.glassText : AppColors.lightTextPrimary))),
                    Text('₹${price.price?.toStringAsFixed(0) ?? '0'}', style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp, fontWeight: FontWeight.bold, color: isSelected ? AppColors.glassAccent : AppColors.glassTextDim)),
                  ],
                ),
              ),
            );
          }),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: _selectedPrice != null
                ? () {
                    context.read<CartBloc>().add(AddToCart(CartItem(item: widget.item.item, selectedPrice: _selectedPrice)));
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${widget.item.name} (${_selectedPrice!.name}) added to cart'), behavior: SnackBarBehavior.floating, backgroundColor: AppColors.glassAccent),
                    );
                  }
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedPrice != null ? AppColors.glassAccent : AppColors.glassTextDim.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text('Add to Cart', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp, fontWeight: FontWeight.w600, color: _selectedPrice != null ? Colors.black : AppColors.glassTextDim)),
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    return AppColors.glassAccent;
  }
}