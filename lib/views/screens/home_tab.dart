/// Glassmorphism Home Tab
///
/// Replaces the old _buildHomeTab in dashboard.dart.
/// Preserves all existing Bloc wiring — only UI/UX changes.
library;

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/OrderBloc/order_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_event.dart';
import 'package:lush/bloc/OrderBloc/order_state.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/models/order_summary.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/widgets/glass_card.dart';

/// Callback to switch the bottom nav to a given index.
typedef NavSwitchCallback = void Function(int index);

/// Home tab content — hero, offer carousel, subscription, trending, orders.
class HomeTab extends StatefulWidget {
  final bool isAuth;
  final User? user;
  final NavSwitchCallback onNavigateToMenu;

  const HomeTab({
    super.key,
    required this.isAuth,
    this.user,
    required this.onNavigateToMenu,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _offerCarouselController = PageController(viewportFraction: 0.85);
  int _currentOfferPage = 0;

  // Predefined offers
  static const List<_OfferData> _offers = [
    _OfferData(
      emoji: '🧃',
      title: 'Summer Detox',
      subtitle: '20% off Signature Juices',
      gradientColors: [Color(0xFFFF6B35), Color(0xFFE91E63)],
    ),
    _OfferData(
      emoji: '🎁',
      title: 'Refer & Earn',
      subtitle: 'Get Rs.200 per referral',
      gradientColors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Dispatch events needed for trending juices and recent orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductCatalogBloc>().add(const LoadProductCatalog());
        context.read<OrderBloc>().add(const LoadOrderHistory());
      }
    });
  }

  @override
  void dispose() {
    _offerCarouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final bgColor = isDark ? AppColors.glassBg : AppColors.glassBgLight;

    return Container(
      color: bgColor,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero Section ──
              _buildHero(context, isDark),

              SizedBox(height: 16.h),

              // ── Offer Carousel ──
              _buildOfferCarousel(isDark),

              SizedBox(height: 20.h),

              // ── Subscription Card ──
              _buildSubscriptionSection(context, isDark),

              SizedBox(height: 16.h),

              // ── Stats Strip ──
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: _buildGlassStats(isDark),
              ),

              SizedBox(height: 20.h),

              // ── Trending Juices ──
              _buildTrendingJuices(context, isDark),

              SizedBox(height: 20.h),

              // ── Order Today / Quick Picks ──
              _buildOrderTodaySection(context, isDark),

              SizedBox(height: 20.h),

              // ── Recent Orders ──
              _buildRecentOrders(context, isDark),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Hero ────────────────────────────────────────────────────────────────
  Widget _buildHero(BuildContext context, bool isDark) {
    final greeting = widget.isAuth && widget.user != null
        ? 'Good morning, ${widget.user!.firstName} 👋'
        : 'Welcome to\nBookMyJuice!';

    return Container(
      margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 16.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            isDark ? const Color(0xFF1B5E20) : const Color(0xFF2E7D32),
            isDark ? const Color(0xFF0A0F0D) : const Color(0xFF43A047),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Fresh cold-pressed juices,\ndelivered to your door.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    color: Colors.white.withValues(alpha: 0.75),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Icon(
                  Icons.local_drink,
                  size: 40,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Offer Carousel ──────────────────────────────────────────────────────
  Widget _buildOfferCarousel(bool isDark) {
    return Column(
      children: [
        SizedBox(
          height: 130.h,
          child: PageView.builder(
            controller: _offerCarouselController,
            onPageChanged: (index) => setState(() => _currentOfferPage = index),
            itemCount: _offers.length,
            itemBuilder: (context, index) {
              final offer = _offers[index];
              return _buildOfferCard(offer, isDark);
            },
          ),
        ),
        SizedBox(height: 8.h),
        // Page indicator dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_offers.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 3.w),
              width: _currentOfferPage == index ? 24.w : 8.w,
              height: 8.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: _currentOfferPage == index
                    ? AppColors.glassAccent
                    : AppColors.glassTextDim.withValues(alpha: 0.4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildOfferCard(_OfferData offer, bool isDark) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: offer.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: offer.gradientColors[0].withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          onTap: () {
            if (offer.title == 'Summer Detox') {
              widget.onNavigateToMenu(1);
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Row(
              children: [
                // Emoji
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      offer.emoji,
                      style: TextStyle(fontSize: 24.sp),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        offer.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        offer.subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    'Grab →',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Subscription Section ──────────────────────────────────────────────
  Widget _buildSubscriptionSection(BuildContext context, bool isDark) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
        String planName = '';
        bool isActive = false;
        String nextDelivery = '';

        if (subState is SubscriptionLoaded) {
          planName = subState.subscription.plan.name;
          isActive = subState.subscription.isActive;
          nextDelivery = subState.subscription.nextDeliveryDate != null
              ? 'Tomorrow, 7-9 AM'
              : '';
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            hasGlow: isActive,
            glowColor: AppColors.glassGlow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isActive
                                ? AppColors.glassAccent
                                : AppColors.glassTextDim)
                            .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        Icons.repeat,
                        size: 18,
                        color: isActive
                            ? AppColors.glassAccent
                            : AppColors.glassTextDim,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planName.isNotEmpty ? planName : 'No Active Plan',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 17.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            isActive ? '● Active' : 'Start your subscription',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              color: isActive
                                  ? AppColors.glassAccent
                                  : AppColors.glassTextDim,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (isActive && nextDelivery.isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8,),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.glassAccent.withValues(alpha: 0.1)
                          : AppColors.primaryGreen.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.schedule,
                            size: 14, color: AppColors.glassAccent,),
                        SizedBox(width: 6.w),
                        Text(
                          'Next: $nextDelivery',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            color: AppColors.glassAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                SizedBox(height: 16.h),
                // Action buttons
                Row(
                  children: [
                    _buildTinyButton(
                      label: isActive ? 'Pause' : 'Subscribe',
                      color: AppColors.glassAccent,
                      onTap: () => Navigator.pushNamed(
                          context, '/manage-subscriptions',),
                    ),
                    SizedBox(width: 8.w),
                    _buildTinyButton(
                      label: 'Modify',
                      color: AppColors.glassOrange,
                      onTap: () => Navigator.pushNamed(
                          context, '/manage-subscriptions',),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/order-history'),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'History →',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          color: AppColors.glassTextDim,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTinyButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }

  // ─── Stats Strip (Glass version) ──────────────────────────────────────
  Widget _buildGlassStats(bool isDark) {
    return Row(
      children: [
        Expanded(child: _statTile(Icons.local_fire_department, '0', 'Calories', isDark)),
        SizedBox(width: 8.w),
        Expanded(child: _statTile(Icons.eco, '100%', 'Fresh', isDark)),
        SizedBox(width: 8.w),
        Expanded(child: _statTile(Icons.timer, '30m', 'Delivery', isDark)),
      ],
    );
  }

  Widget _statTile(IconData icon, String value, String label, bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      borderRadius: AppRadius.lg,
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.glassAccent),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              color: AppColors.glassTextDim,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Trending Juices ──────────────────────────────────────────────────
  Widget _buildTrendingJuices(BuildContext context, bool isDark) {
    return BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
      builder: (context, state) {
        List<CatalogItem> trendingItems = [];
        if (state is ProductCatalogLoaded) {
          // Pick up to 5 random items
          final rng = Random(42); // Fixed seed for consistency
          final shuffled = List<CatalogItem>.from(state.items)..shuffle(rng);
          trendingItems = shuffled.take(5).toList();
        } else if (state is ProductCatalogFiltered) {
          final rng = Random(42);
          final shuffled = List<CatalogItem>.from(state.items)..shuffle(rng);
          trendingItems = shuffled.take(5).toList();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, size: 18, color: AppColors.glassAccent),
                  SizedBox(width: 6.w),
                  Text(
                    'Trending Juices',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: 180.h,
              child: trendingItems.isEmpty
                  ? Center(
                      child: Text(
                        'No juices available',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13.sp,
                          color: AppColors.glassTextDim,
                        ),
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      physics: const BouncingScrollPhysics(),
                      itemCount: trendingItems.length,
                      itemBuilder: (context, index) {
                        final item = trendingItems[index];
                        return _buildTrendingCard(item, isDark);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTrendingCard(CatalogItem item, bool isDark) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: GlassCard(
        borderRadius: AppRadius.lg,
        onTap: () => widget.onNavigateToMenu(1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient header
            Container(
              height: 72.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(int.parse(item.startColor.replaceFirst('#', '0xFF'))),
                    Color(int.parse(item.endColor.replaceFirst('#', '0xFF'))),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Center(
                child: Text(
                  '🧃',
                  style: TextStyle(fontSize: 28.sp),
                ),
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          size: 10, color: AppColors.glassOrange,),
                      SizedBox(width: 2.w),
                      Text(
                        '${item.calories} cal',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10.sp,
                          color: AppColors.glassTextDim,
                        ),
                      ),
                      const Spacer(),
                      if (item.prices.isNotEmpty)
                        Text(
                          '₹${item.prices.first.price?.toStringAsFixed(0) ?? "—"}',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
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
      ),
    );
  }

  // ─── Order Today Section ─────────────────────────────────────────────
  Widget _buildOrderTodaySection(BuildContext context, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Order Today',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => widget.onNavigateToMenu(1),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View Menu →',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    color: AppColors.glassAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Quick product cards
          _quickProductCard(
            name: 'Mango Punch',
            tag: 'Delight',
            price: '₹75',
            gradientColors: [const Color(0xFFFF9800), const Color(0xFFFF5722)],
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _quickProductCard(
            name: 'Green Detox',
            tag: 'Signature',
            price: '₹129',
            gradientColors: [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
            isDark: isDark,
          ),
          SizedBox(height: 8.h),
          _quickProductCard(
            name: 'Berry Blast',
            tag: 'Premium',
            price: '₹159',
            gradientColors: [const Color(0xFFE91E63), const Color(0xFF880E4F)],
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _quickProductCard({
    required String name,
    required String tag,
    required String price,
    required List<Color> gradientColors,
    required bool isDark,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: AppRadius.lg,
      onTap: () => widget.onNavigateToMenu(1),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradientColors,
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
                  name,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  tag,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    color: AppColors.glassTextDim,
                  ),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.glassAccent,
            ),
          ),
          SizedBox(width: 8.w),
          const Icon(
            Icons.add_circle,
            color: AppColors.glassAccent,
            size: 24,
          ),
        ],
      ),
    );
  }

  // ─── Recent Orders ──────────────────────────────────────────────────
  Widget _buildRecentOrders(BuildContext context, bool isDark) {
    if (!widget.isAuth) return const SizedBox.shrink();

    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, orderState) {
        List<OrderSummary> orders = [];
        if (orderState is OrderHistoryLoaded) {
          // Show last 3 orders
          orders = orderState.orders.take(3).toList();
        } else if (orderState is OrderHistoryLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.glassAccent,
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'Loading orders...',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    color: AppColors.glassTextDim,
                  ),
                ),
              ],
            ),
          );
        } else if (orderState is OrderHistoryEmpty || orderState is OrderHistoryError) {
          return const SizedBox.shrink();
        }

        if (orders.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long, size: 18, color: AppColors.glassAccent),
                  SizedBox(width: 6.w),
                  Text(
                    'Recent Orders',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/order-history'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View All →',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        color: AppColors.glassTextDim,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              ...orders.map((order) => _buildOrderTile(order, isDark)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderTile(OrderSummary order, bool isDark) {
    // Simple status color
    Color statusColor;
    switch (order.status.toLowerCase()) {
      case 'delivered':
        statusColor = AppColors.success;
        break;
      case 'processing':
        statusColor = AppColors.glassOrange;
        break;
      case 'cancelled':
        statusColor = AppColors.error;
        break;
      default:
        statusColor = AppColors.glassTextDim;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: AppRadius.lg,
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                Icons.shopping_bag,
                size: 20,
                color: statusColor,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order #${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${order.itemCount} items • ${order.formattedDate}',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11.sp,
                      color: AppColors.glassTextDim,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹${order.total.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.glassAccent,
                  ),
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    order.status,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 9.sp,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Data class for carousel offers.
class _OfferData {
  final String emoji;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;

  const _OfferData({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
  });
}