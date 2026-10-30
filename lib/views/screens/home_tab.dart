/// Stitch `unified_home_dashboard` — Home tab.
///
/// The first viewport follows the Stitch reference exactly:
/// greeting → active subscription card → three-stat strip → trending grid.
/// The promo rail, quick picks and recent orders keep their original routes
/// and BLoC wiring and sit below that block, so nothing functional was lost.
///
/// Preserved wiring (unchanged from the previous implementation):
/// - `ProductCatalogBloc.LoadProductCatalog()` and `OrderBloc.LoadOrderHistory()`
///   are dispatched from [HomeTab.initState] (orders only when signed in);
/// - the size picker is the shared `showSizeSelectionSheet`;
/// - routes `/productDetails`, `/plan-selection`, `/manage-subscriptions`,
///   `/orders` and `/order-history` are untouched.
library;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/bloc/OrderBloc/order_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_event.dart';
import 'package:lush/bloc/OrderBloc/order_state.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/get_it.dart';
import 'package:lush/models/order_summary.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';
import 'package:lush/utils/price_utils.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/views/widgets/size_selection_sheet.dart';
import 'package:lush/widgets/bmj_glass_button.dart';
import 'package:lush/widgets/bmj_glass_card.dart';
import 'package:lush/widgets/bmj_pill.dart';
import 'package:lush/widgets/bmj_stat_tile.dart';

/// Callback to switch the bottom nav to a given index.
typedef NavSwitchCallback = void Function(int index);

/// Home tab content — greeting, subscription, stats, trending, promos, orders.
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
  final PageController _offerCarouselController =
      PageController(viewportFraction: 0.9);
  int _currentOfferPage = 0;

  /// Predefined offers. Purely promotional copy — no prices and no API calls.
  static const List<_OfferData> _offers = <_OfferData>[
    _OfferData(
      emoji: '🧃',
      title: 'Summer Detox',
      subtitle: '20% off Signature juices',
      gradientColors: <Color>[Color(0xFFF97316), Color(0xFFC2410C)],
    ),
    _OfferData(
      emoji: '🎁',
      title: 'Refer & Earn',
      subtitle: 'Get ₹200 per referral',
      gradientColors: <Color>[Color(0xFF16A34A), Color(0xFF067A3E)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Dispatch events needed for trending juices and recent orders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProductCatalogBloc>().add(const LoadProductCatalog());
      // DP-1: order history is authenticated - skip the call while signed out.
      if (_isSignedIn) {
        context.read<OrderBloc>().add(const LoadOrderHistory());
      }
    });
  }

  /// DP-1: true when an account session exists, so authenticated loads are safe.
  bool get _isSignedIn {
    if (getIt.get<UserRepository>().userLoggedIn) return true;
    return context.read<AuthenticationBloc>().state is AuthenticationSuccess;
  }

  @override
  void dispose() {
    _offerCarouselController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);

    return Container(
      color: palette.surface,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          // Room for the floating glass bottom nav (`extendBody: true`).
          padding: const EdgeInsets.only(bottom: 104),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // ── Greeting (Stitch: "Good morning," + "Welcome back") ──
              _buildGreeting(context),

              const SizedBox(height: AppSpacing.lg),

              // ── Active subscription card ──
              _buildSubscriptionSection(context),

              const SizedBox(height: AppSpacing.lg),

              // ── Three-stat strip ──
              _buildStatsStrip(palette),

              const SizedBox(height: AppSpacing.lg),

              // ── Trending juices (2-column grid) ──
              _buildTrendingJuices(context),

              const SizedBox(height: AppSpacing.lg),

              // ── Promotional rail ──
              _buildOffers(context),

              const SizedBox(height: AppSpacing.lg),

              // ── Quick picks ──
              _buildOrderTodaySection(context),

              // ── Recent orders ──
              _buildRecentOrders(context),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Greeting ────────────────────────────────────────────────────────────
  Widget _buildGreeting(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);
    final String rawName = widget.user?.firstName ?? '';
    final String? firstName =
        widget.isAuth && rawName.trim().isNotEmpty ? rawName.trim() : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        BMJTokens.pageMargin,
        BMJTokens.spaceLg,
        BMJTokens.pageMargin,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Good morning,',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Semantics(
            header: true,
            child: Text(
              firstName == null
                  ? 'Welcome to BookMyJuice'
                  : 'Welcome back, $firstName',
              style: BMJType.heroGreeting.copyWith(color: palette.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Subscription card ───────────────────────────────────────────────────
  Widget _buildSubscriptionSection(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, subState) {
        if (_isSignedIn && subState is SubscriptionLoading) {
          return _cardShell(
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Loading your subscription…',
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: BMJPalette.of(context).onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (_isSignedIn && subState is SubscriptionError) {
          final BMJPalette palette = BMJPalette.of(context);
          return _cardShell(
            child: Row(
              children: <Widget>[
                Icon(Icons.error_outline, color: palette.error, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Failed to load subscription status',
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: palette.onSurfaceVariant,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => context
                      .read<SubscriptionBloc>()
                      .add(const LoadSubscriptionPlans()),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (subState is SubscriptionLoaded && subState.subscription.isActive) {
          return _activeSubscriptionCard(context, subState.subscription);
        }

        return _inactiveSubscriptionCard(context);
      },
    );
  }

  /// Page-margin card shell shared by every subscription state.
  Widget _cardShell({required Widget child, bool glow = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BMJTokens.pageMargin),
      child: BMJGlassCard(
        glow: glow,
        child: child,
      ),
    );
  }

  /// Stitch active plan card: status pill, plan name, next delivery and the
  /// full-width "Manage delivery" action.
  Widget _activeSubscriptionCard(
    BuildContext context,
    ActiveSubscription subscription,
  ) {
    final BMJPalette palette = BMJPalette.of(context);
    final String planName = subscription.plan.name;
    final String description = subscription.plan.description;
    final String period = subscription.plan.period;
    final bool hasDelivery = subscription.nextDeliveryDate != null;

    return _cardShell(
      glow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const BMJPill(
                label: 'Active Subscription',
                tone: BMJPillTone.success,
                icon: Icons.check_circle_rounded,
              ),
              const Spacer(),
              // The reference fills this corner with a big count over a caps
              // caption. Deliveries-to-date is real subscription data, so the slot
              // gets a real number instead of empty space.
              if (subscription.totalDeliveries > 0)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      '${subscription.totalDeliveries}',
                      style: BMJType.statNum.copyWith(
                        fontSize: 26,
                        height: 1.05,
                        color: palette.onSurface,
                      ),
                    ),
                    Text(
                      'DELIVERIES',
                      style: AppTextStyles.textTheme.labelSmall?.copyWith(
                        color: palette.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            planName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textTheme.titleSmall?.copyWith(
              color: palette.onSurface,
            ),
          ),
          if (description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: palette.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm + 2),
          Row(
            children: <Widget>[
              Icon(
                Icons.schedule_rounded,
                size: 15,
                color: palette.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpacing.xs + 2),
              Expanded(
                child: Text(
                  hasDelivery
                      ? 'Next delivery: Tomorrow, 7-9 AM'
                      : 'Next delivery will be scheduled soon',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
              ),
              // The cadence moved off the top row (the stat block took that
              // corner), so it rides at the end of the schedule line.
              if (period.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Text(
                    '$period plan',
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: palette.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          BMJGlassButton.inCard(
            label: 'Manage delivery',
            icon: Icons.tune_rounded,
            onPressed: () => Navigator.pushNamed(
              context,
              '/manage-subscriptions',
            ),
          ),
        ],
      ),
    );
  }

  /// Signed-out / no-plan state — same shell, Stitch typography.
  Widget _inactiveSubscriptionCard(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);

    return _cardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const BMJPill(
            label: 'No active plan',
            tone: BMJPillTone.neutral,
            icon: Icons.info_outline_rounded,
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            'Start your juice subscription',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.textTheme.titleSmall?.copyWith(
              color: palette.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Fresh cold-pressed juice, delivered daily or weekly. Skip, pause '
            'or change plans any time.',
            style: AppTextStyles.textTheme.bodyMedium?.copyWith(
              color: palette.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          BMJGlassButton(
            key: const Key('home_browse_plans_button'),
            label: 'Browse plans',
            icon: Icons.local_drink_outlined,
            onPressed: () => Navigator.pushNamed(context, '/plan-selection'),
          ),
        ],
      ),
    );
  }

  // ─── Stats strip ─────────────────────────────────────────────────────────
  /// Stitch "Quick Stats": `flex gap-gutter overflow-x-auto px-md pb-2` holding
  /// `flex-none w-28 p-sm rounded-lg` tiles. 3 × 112 dp + 2 × 12 dp gutters is
  /// 360 dp before the 32 dp of page margin, so the reference *scrolls* this
  /// row on a 390 dp canvas — reproducing the scroll is what keeps the tiles
  /// square-ish instead of squeezing them into unequal thirds.
  Widget _buildStatsStrip(BMJPalette palette) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(
        BMJTokens.pageMargin,
        AppSpacing.sm,
        BMJTokens.pageMargin,
        AppSpacing.sm + 4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _statTile(palette,
              icon: Icons.eco_rounded, value: '100%', label: 'Natural'),
          const SizedBox(width: AppSpacing.sm + 4),
          _statTile(palette,
              icon: Icons.timer_outlined, value: '30m', label: 'Delivery'),
          const SizedBox(width: AppSpacing.sm + 4),
          _statTile(
            palette,
            icon: Icons.verified_outlined,
            value: '0',
            label: 'Preservatives',
          ),
        ],
      ),
    );
  }

  /// One stat tile: wider than the reference's, a large neutral number, one
  /// accent-coloured glyph and a caption that can breathe — the reference reads
  /// as a bright number over a coloured icon, not as a coloured chip.
  Widget _statTile(
    BMJPalette palette, {
    required IconData icon,
    required String value,
    required String label,
  }) {
    return SizedBox(
      width: 124,
      child: BMJGlassCard(
        radius: AppRadius.sm,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm + 2,
          horizontal: AppSpacing.sm,
        ),
        child: BMJStatTile(
          icon: icon,
          value: value,
          label: label,
          alignment: CrossAxisAlignment.center,
          stacked: true,
          uppercase: false,
          accent: palette.onSurface,
          iconColor: palette.primaryEmphasis,
          valueStyle: BMJType.statNum.copyWith(fontSize: 28, height: 1.1),
        ),
      ),
    );
  }

  // ─── Trending juices ─────────────────────────────────────────────────────
  Widget _buildTrendingJuices(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);

    return BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
      builder: (context, state) {
        final List<CatalogItem> catalog = _catalogItems(state);
        // Fixed seed keeps the "trending" pick stable between rebuilds.
        final Random rng = Random(42);
        final List<CatalogItem> trending =
            (List<CatalogItem>.from(catalog)..shuffle(rng)).take(4).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: BMJTokens.pageMargin),
              child: Semantics(
                header: true,
                child: Text(
                  'Trending Juices',
                  // Stitch section header is `font-headline-md` — 20/26, 700.
                  style: AppTextStyles.textTheme.titleMedium?.copyWith(
                    color: palette.onSurface,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (trending.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BMJTokens.pageMargin,
                ),
                child: BMJGlassCard(
                  child: Text(
                    catalog.isEmpty
                        ? 'Loading today’s juices…'
                        : 'No juices available right now',
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: palette.onSurfaceVariant,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: BMJTokens.pageMargin,
                ),
                child: Column(
                  children: <Widget>[
                    for (int i = 0; i < trending.length; i += 2)
                      Padding(
                        padding: EdgeInsets.only(
                          bottom:
                              i + 2 < trending.length ? AppSpacing.sm + 4 : 0,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Expanded(
                              child: _trendingCard(context, trending[i]),
                            ),
                            const SizedBox(width: AppSpacing.sm + 4),
                            Expanded(
                              child: i + 1 < trending.length
                                  ? _trendingCard(context, trending[i + 1])
                                  : const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  /// Stitch product tile: artwork, floating add button, name, ingredients, price.
  Widget _trendingCard(BuildContext context, CatalogItem item) {
    final BMJPalette palette = BMJPalette.of(context);
    final String ingredients =
        item.ingredients.isEmpty ? item.category : item.ingredients.join(', ');

    return BMJGlassCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Stack(
            children: <Widget>[
              AspectRatio(
                // Stitch product media is `h-32` (128 dp) inside a card that is
                // 173 dp wide on the 390 dp reference canvas → 173 : 128 = 1.35.
                // A ratio instead of a fixed 128 dp keeps the identical crop at
                // every device width.
                aspectRatio: 1.28,
                child: GestureDetector(
                  onTap: () => _openProductDetails(item),
                  behavior: HitTestBehavior.opaque,
                  child: _itemArtwork(item),
                ),
              ),
              Positioned(
                right: AppSpacing.sm,
                bottom: AppSpacing.sm,
                child: _addToCartButton(context, item),
              ),
            ],
          ),
          // `p-sm` in the reference: 8 dp of chrome, so the artwork keeps the
          // card's visual weight instead of the caption block.
          Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BMJType.cardTitle.copyWith(color: palette.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  ingredients,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  // A short regular-weight line, the way the reference draws the
                  // ingredient list — not a bold micro-label.
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  formatRupees(cheapestPrice(item.prices)),
                  // The price is the second-loudest thing in the tile, as in the
                  // reference, where it sits a clear step above the caption.
                  style: AppTextStyles.textTheme.titleSmall?.copyWith(
                    color: palette.primaryEmphasis,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Product artwork on the item's own gradient.
  ///
  /// Catalog artwork is a transparent cut-out (the assets ship with alpha), so
  /// the gradient behind it carries the brand colour and the photo keeps its
  /// real produce colours. `BlendMode` filters are deliberately avoided — a
  /// non-`srcOver` colour filter blends with the whole backdrop, which painted
  /// the card body behind the caption (found in the golden capture).
  Widget _itemArtwork(CatalogItem item) {
    final Color start = _colorFromHex(item.startColor);
    final Color end = _colorFromHex(item.endColor);
    final Gradient gradient = LinearGradient(
      colors: <Color>[start, end],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final Widget fallback = Center(
      child: Icon(
        Icons.local_drink_rounded,
        size: 40,
        color: BMJTokens.inkOnBrand.withValues(alpha: 0.9),
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: item.imagePath.isEmpty
          ? fallback
          : Image.asset(
              item.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
    );
  }

  /// Circular add button (Stitch "FAB": `w-10 h-10 rounded-full` + orange
  /// glow); opens the shared size sheet.
  Widget _addToCartButton(BuildContext context, CatalogItem item) {
    final BMJPalette palette = BMJPalette.of(context);

    return Semantics(
      button: true,
      label: 'Choose a size for ${item.name}',
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.primary.withValues(alpha: 0.60),
              blurRadius: 15,
            ),
          ],
        ),
        child: Material(
          color: palette.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => showSizeSelectionSheet(context, item),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(
                Icons.add_rounded,
                size: 20,
                color: palette.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Promotional rail ────────────────────────────────────────────────────
  Widget _buildOffers(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: BMJTokens.pageMargin),
          child: Text(
            'Today’s offers',
            // Stitch section header is `font-headline-md` — 20/26, 700.
            style: AppTextStyles.textTheme.titleMedium?.copyWith(
              color: palette.onSurface,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm + 4),
        SizedBox(
          height: 104,
          child: PageView.builder(
            controller: _offerCarouselController,
            onPageChanged: (int index) =>
                setState(() => _currentOfferPage = index),
            itemCount: _offers.length,
            itemBuilder: (context, index) =>
                _offerCard(context, _offers[index]),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List<Widget>.generate(_offers.length, (int index) {
            final bool selected = _currentOfferPage == index;
            return AnimatedContainer(
              duration: BMJTokens.motionBase,
              curve: BMJTokens.motionCurve,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: selected ? 20 : 8,
              height: 6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                color: selected ? palette.primary : palette.outlineVariant,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _offerCard(BuildContext context, _OfferData offer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.card),
          onTap: () => widget.onNavigateToMenu(1),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: offer.gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: BMJTokens.inkOnBrand.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Center(
                    child: Text(
                      offer.emoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        offer.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textTheme.titleSmall?.copyWith(
                          color: BMJTokens.inkOnBrand,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        offer.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.textTheme.bodySmall?.copyWith(
                          color: BMJTokens.inkOnBrand.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: BMJTokens.inkOnBrand.withValues(alpha: 0.9),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Quick picks ─────────────────────────────────────────────────────────
  Widget _buildOrderTodaySection(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BMJTokens.pageMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  header: true,
                  child: Text(
                    'Order today',
                    // Stitch section header is `font-headline-md` — 20/26, 700.
                    style: AppTextStyles.textTheme.titleMedium?.copyWith(
                      color: palette.onSurface,
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => widget.onNavigateToMenu(1),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'View menu',
                  style: AppTextStyles.textTheme.labelLarge?.copyWith(
                    color: palette.primaryEmphasis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm + 4),
          BlocBuilder<ProductCatalogBloc, ProductCatalogState>(
            builder: (context, state) {
              final List<CatalogItem> items =
                  _catalogItems(state).take(3).toList();

              if (items.isEmpty) {
                return Text(
                  'No juices available right now',
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                );
              }

              return Column(
                children: <Widget>[
                  for (final CatalogItem item in items) ...<Widget>[
                    _quickProductCard(context, item),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _quickProductCard(BuildContext context, CatalogItem item) {
    final BMJPalette palette = BMJPalette.of(context);

    return BMJGlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => _openProductDetails(item),
            child: SizedBox(
              width: 52,
              height: 52,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.md),
                child: _itemArtwork(item),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: GestureDetector(
              onTap: () => _openProductDetails(item),
              behavior: HitTestBehavior.opaque,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.textTheme.titleSmall?.copyWith(
                      color: palette.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.category} · ${item.calories} cal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.textTheme.bodySmall?.copyWith(
                      color: palette.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            formatRupees(cheapestPrice(item.prices)),
            style: AppTextStyles.textTheme.titleMedium?.copyWith(
              color: palette.primaryEmphasis,
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          _addToCartButton(context, item),
        ],
      ),
    );
  }

  // ─── Recent orders ───────────────────────────────────────────────────────
  Widget _buildRecentOrders(BuildContext context) {
    if (!widget.isAuth) return const SizedBox.shrink();
    final BMJPalette palette = BMJPalette.of(context);

    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, orderState) {
        if (orderState is! OrderHistoryLoaded) {
          return const SizedBox.shrink();
        }

        final List<OrderSummary> orders = orderState.orders.take(3).toList();
        if (orders.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.fromLTRB(
            BMJTokens.pageMargin,
            AppSpacing.lg,
            BMJTokens.pageMargin,
            0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Semantics(
                      header: true,
                      child: Text(
                        'Recent orders',
                        // Stitch section header is `font-headline-md` — 20/26.
                        style: AppTextStyles.textTheme.titleMedium?.copyWith(
                          color: palette.onSurface,
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/order-history'),
                    style: TextButton.styleFrom(
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'View all',
                      style: AppTextStyles.textTheme.labelLarge?.copyWith(
                        color: palette.primaryEmphasis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              for (final OrderSummary order in orders) ...<Widget>[
                _orderTile(context, order),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _orderTile(BuildContext context, OrderSummary order) {
    final BMJPalette palette = BMJPalette.of(context);
    final (Color statusColor, String statusLabel) =
        switch (order.status.toLowerCase()) {
      'delivered' => (palette.accentText, 'Delivered'),
      'processing' => (palette.primaryEmphasis, 'Processing'),
      'cancelled' => (palette.error, 'Cancelled'),
      _ => (palette.onSurfaceVariant, order.status),
    };
    final String shortId =
        order.id.length > 8 ? order.id.substring(0, 8) : order.id;

    return BMJGlassCard(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      child: Row(
        children: <Widget>[
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 20,
              color: statusColor,
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Order #$shortId',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textTheme.titleSmall?.copyWith(
                    color: palette.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${order.itemCount} items · ${order.formattedDate}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                formatRupees(order.total),
                style: AppTextStyles.textTheme.titleMedium?.copyWith(
                  color: palette.primaryEmphasis,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                statusLabel,
                style: AppTextStyles.textTheme.labelSmall?.copyWith(
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────
  /// `#RRGGBB` → [Color]; falls back to the brand orange when malformed.
  Color _colorFromHex(String? hex) {
    if (hex == null) return BMJTokens.orange;
    final String cleaned = hex.replaceFirst('#', '');
    if (cleaned.length != 6) return BMJTokens.orange;
    final int? value = int.tryParse(cleaned, radix: 16);
    return value == null ? BMJTokens.orange : Color(0xFF000000 | value);
  }

  /// Opens the BMJ product detail page for [item].
  void _openProductDetails(CatalogItem item) {
    Navigator.of(context).pushNamed('/productDetails', arguments: item);
  }

  /// Items for the loaded/filtered catalog states.
  List<CatalogItem> _catalogItems(ProductCatalogState state) {
    if (state is ProductCatalogLoaded) return state.items;
    if (state is ProductCatalogFiltered) return state.items;
    return const <CatalogItem>[];
  }
}

/// Data class for the promo rail.
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
