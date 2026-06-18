/// Glassmorphism Menu Tab — Combined One-Time Order + Subscription
///
/// Segment toggle at top: "One-Time" | "Subscribe"
/// One-Time shows product catalog with add-to-cart
/// Subscribe shows subscription plan cards
/// Preserves all existing Bloc wiring — only UI/UX changes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart' hide AddToCart;
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
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
  String? _selectedCategory;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> _categories = [];

  @override
  void initState() {
    super.initState();
    context.read<ProductCatalogBloc>().add(const LoadProductCatalog());
    context.read<SubscriptionBloc>().add(const LoadSubscriptionPlans());
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
          hintStyle: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            color: AppColors.glassTextDim,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.glassTextDim,
            size: 20,
          ),
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

  // ═══ ONE-TIME CONTENT ══════════════════════════════════════════════════
  Widget _buildOneTimeContent(bool isDark) {
    return BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
      builder: (context, state) {
        List<CatalogItem> items = [];
        List<String> categories = [];

        if (state is ProductCatalogLoaded) {
          items = state.items;
          categories = state.categories;
          _categories = categories;
          if (_selectedCategory == null && categories.isNotEmpty) {
            _selectedCategory = categories[0];
            // Auto-apply the first category filter (usually "Delight")
            context.read<ProductCatalogBloc>().add(FilterByCategory(category: _selectedCategory!));
            // Return early; the filter event will rebuild with filtered state
            return const SizedBox.shrink();
          }
        } else if (state is ProductCatalogFiltered) {
          items = state.items;
          categories = _categories;
        } else if (state is ProductCatalogLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ProductCatalogEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 64,
                    color: AppColors.glassTextDim,),
                SizedBox(height: 16.h),
                Text(
                  'No products found',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16.sp,
                    color: AppColors.glassTextDim,
                  ),
                ),
              ],
            ),
          );
        } else if (state is ProductCatalogError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64,
                    color: AppColors.glassTextDim,),
                SizedBox(height: 16.h),
                Text(state.message,
                    style: const TextStyle(color: AppColors.glassTextDim),),
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

        if (items.isEmpty) {
          return const Center(child: Text('No products'));
        }

        // Extract unique categories from catalog items if state is ProductCatalogFiltered
        if (state is ProductCatalogFiltered && categories.isEmpty) {
          // We'll still show the filter chips based on the last loaded categories
        }

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Category filter chips (only if not searching)
            if (_searchQuery.isEmpty && categories.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
                  child: _buildCategoryChips(categories, isDark),
                ),
              ),

            // Product grid
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.75,
                  crossAxisSpacing: 12.w,
                  mainAxisSpacing: 12.h,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildProductCard(items[index], isDark),
                  childCount: items.length,
                ),
              ),
            ),

            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        );
      },
    );
  }

  Widget _buildCategoryChips(List<String> categories, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSel = _selectedCategory == cat;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GlassChip(
              label: cat,
              isSelected: isSel,
              selectedColor: AppColors.glassAccent,
              onTap: () {
                setState(() => _selectedCategory = cat);
                context.read<ProductCatalogBloc>().add(FilterByCategory(category: cat));
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProductCard(CatalogItem item, bool isDark) {
    final defaultPrice = item.prices.isNotEmpty
        ? item.prices.firstWhere(
            (p) => p.name?.contains('500ml') ?? false,
            orElse: () => item.prices.first,
          )
        : null;

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
                  colors: [
                    _hexToColor(item.startColor),
                    _hexToColor(item.endColor),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Center(
                child: Icon(
                  Icons.local_drink,
                  size: 48,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
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
                    color: AppColors.glassAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    item.category,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.glassAccent,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                // Name
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                // Calories
                Text(
                  '${item.calories} cal',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    color: AppColors.glassTextDim,
                  ),
                ),
                SizedBox(height: 8.h),
                // Price + Add
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      defaultPrice != null
                          ? '₹${defaultPrice.price?.toStringAsFixed(0) ?? '0'}'
                          : 'From ₹75',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.glassAccent,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.glassAccent.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: AppColors.glassAccent.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.add,
                        size: 18,
                        color: AppColors.glassAccent,
                      ),
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
      builder: (ctx) {
        return _SizeSelectionSheet(item: item);
      },
    );
  }

  // ═══ SUBSCRIBE CONTENT ═════════════════════════════════════════════════
  Widget _buildSubscribeContent(bool isDark) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        List<SubscriptionPlan> plans = [];

        if (state is SubscriptionPlansLoaded) {
          plans = state.plans;
        } else if (state is SubscriptionLoading && plans.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (plans.isEmpty) {
          // Fallback plans
          plans = [
            const SubscriptionPlan(
              id: '1', name: 'Delight', planID: 1,
              description: 'Perfect for beginners',
              features: ['2 juices/week', 'Flexible schedule', 'Free delivery'],
            ),
            const SubscriptionPlan(
              id: '2', name: 'Premium', planID: 2,
              description: 'Our most popular plan',
              features: ['Daily juice', 'Choice of any size', 'Priority support', 'Free delivery'],
              startColor: '#22C55E', endColor: '#16A34A',
            ),
            const SubscriptionPlan(
              id: '3', name: 'Signature', planID: 3,
              description: 'The ultimate experience',
              features: ['2 juices/day', 'All sizes included', 'VIP support', 'Free delivery', 'Exclusive recipes'],
              startColor: '#E91E63', endColor: '#880E4F',
            ),
          ];
        }

        return ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: plans.length + 1, // +1 for header
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Text(
                  'Choose Your Plan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                  ),
                ),
              );
            }
            final plan = plans[index - 1];
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildPlanCard(plan, isDark),
            );
          },
        );
      },
    );
  }

  Widget _buildPlanCard(SubscriptionPlan plan, bool isDark) {
    final colors = [
      _hexToColor(plan.startColor),
      _hexToColor(plan.endColor),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(20),
      hasGlow: plan.name == 'Premium',
      glowColor: colors[0].withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Plan header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(
                  plan.name == 'Delight'
                      ? Icons.emoji_emotions_outlined
                      : plan.name == 'Premium'
                          ? Icons.star_outline
                          : Icons.diamond_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.glassText
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      plan.description,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        color: AppColors.glassTextDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Divider
          Container(
            height: 0.5,
            color: isDark ? AppColors.glassBorder : AppColors.glassBorderLight,
          ),
          SizedBox(height: 16.h),
          // Features
          ...plan.features.map((f) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 16,
                      color: AppColors.glassAccent,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      f,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.sp,
                        color: isDark
                            ? AppColors.glassTextDim
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),),
          SizedBox(height: 16.h),
          // Subscribe button
          GestureDetector(
            onTap: () {
              context
                  .read<SubscriptionBloc>()
                  .add(CreateSubscription(planId: plan.planID, startDate: DateTime.now()));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: colors,
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                'Subscribe with Chargebee',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return AppColors.glassAccent;
  }
}

// ═══ Glass Segment Toggle (local version to avoid Bloc issues) ═══════════
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
            color: isDark
                ? AppColors.glassSurface.withValues(alpha: 0.8)
                : AppColors.glassSurfaceLight.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: isDark ? AppColors.glassBorderSubtle : AppColors.glassBorderLight,
            ),
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
                      color: isSelected
                          ? AppColors.glassAccent.withValues(alpha: 0.25)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      segments[index],
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.glassAccent
                            : (isDark
                                ? AppColors.glassTextDim
                                : AppColors.lightTextSecondary),
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
        border: Border.all(
          color: isDark ? AppColors.glassBorder : AppColors.glassBorderLight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _hexToColor(widget.item.startColor),
                      _hexToColor(widget.item.endColor),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                    Text(
                      widget.item.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'Select size',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13.sp,
                        color: AppColors.glassTextDim,
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.glassSurface.withValues(alpha: 0.6)
                        : AppColors.glassSurfaceLight.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 18, color: AppColors.glassTextDim),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Size options
          ...widget.item.prices.map((price) {
            final isSelected = _selectedPrice == price;
            return GestureDetector(
              onTap: () => setState(() => _selectedPrice = price),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.glassAccent.withValues(alpha: 0.1)
                      : (isDark
                          ? AppColors.glassSurface
                          : AppColors.glassSurfaceLight),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.glassAccent.withValues(alpha: 0.5)
                        : (isDark
                            ? AppColors.glassBorderSubtle
                            : AppColors.glassBorderLight),
                    width: isSelected ? 1 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        price.name ?? 'Standard',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isDark
                              ? AppColors.glassText
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    Text(
                      '₹${price.price?.toStringAsFixed(0) ?? '0'}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.glassAccent
                            : AppColors.glassTextDim,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          SizedBox(height: 16.h),

          // Add to Cart button
          GestureDetector(
            onTap: _selectedPrice != null
                ? () {
                    context.read<CartBloc>().add(AddToCart(
                      CartItem(
                        item: widget.item.item,
                        selectedPrice: _selectedPrice,
                      ),
                    ),);
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${widget.item.name} (${_selectedPrice!.name}) added to cart',
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppColors.glassAccent,
                      ),
                    );
                  }
                : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _selectedPrice != null
                    ? AppColors.glassAccent
                    : AppColors.glassTextDim.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Add to Cart',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: _selectedPrice != null ? Colors.black : AppColors.glassTextDim,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      return Color(int.parse('FF$hex', radix: 16));
    }
    return AppColors.glassAccent;
  }
}