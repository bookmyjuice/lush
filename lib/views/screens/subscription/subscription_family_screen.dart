/// Subscription family picker — first step of the subscription flow.
///
/// Stitch `vibrant_zest` styling: glass header, glass family cards and brand
/// gradient icon tiles. The BLoC contract is unchanged (`LoadSubscriptionCatalog`
/// on mount, `SubscriptionCatalogLoaded` renders the cards) and the price is the
/// real cheapest price from Chargebee — never a fabricated `₹0`.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/bmj_tokens.dart';
import 'package:lush/utils/price_utils.dart';
import 'package:lush/views/models/subscription_plan_catalog.dart';
import 'package:lush/widgets/bmj_empty_state.dart';
import 'package:lush/widgets/bmj_glass_button.dart';
import 'package:lush/widgets/bmj_glass_card.dart';
import 'package:lush/widgets/bmj_glass_header.dart';

/// Copy + icon for each Chargebee item family.
class _FamilyMeta {
  final IconData icon;
  final String tagline;
  final String description;

  const _FamilyMeta({
    required this.icon,
    required this.tagline,
    required this.description,
  });
}

class SubscriptionFamilyScreen extends StatefulWidget {
  const SubscriptionFamilyScreen({super.key});

  @override
  State<SubscriptionFamilyScreen> createState() =>
      _SubscriptionFamilyScreenState();
}

class _SubscriptionFamilyScreenState extends State<SubscriptionFamilyScreen> {
  static const Map<String, _FamilyMeta> _familyMeta = <String, _FamilyMeta>{
    'delight': _FamilyMeta(
      icon: Icons.wb_sunny_outlined,
      tagline: 'Fresh & Affordable',
      description: 'Entry-level juices perfect for daily refreshment.',
    ),
    'signature': _FamilyMeta(
      icon: Icons.bolt_outlined,
      tagline: 'Balanced & Popular',
      description:
          'Our signature blends with the perfect balance of taste and nutrition.',
    ),
    'premium': _FamilyMeta(
      icon: Icons.workspace_premium_outlined,
      tagline: 'Premium & Exclusive',
      description:
          'The finest selection of cold-pressed juices for discerning taste.',
    ),
  };

  static const _FamilyMeta _fallbackMeta = _FamilyMeta(
    icon: Icons.local_drink_outlined,
    tagline: 'Cold-pressed',
    description: 'Fresh juice delivered on your schedule.',
  );

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(const LoadSubscriptionCatalog());
  }

  @override
  Widget build(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);

    return Scaffold(
      backgroundColor: palette.surface,
      body: Column(
        children: <Widget>[
          BMJGlassHeader(
            title: 'Choose a Plan',
            // The sub-flow has no cart action of its own and the header must
            // not require a CartBloc in scope.
            showCart: false,
            leading: Semantics(
              button: true,
              label: 'Back',
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_rounded),
                color: palette.onSurface,
                tooltip: 'Back',
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
              builder: (context, state) {
                if (state is SubscriptionCatalogLoaded) {
                  return _buildFamilies(context, state.plans);
                }
                if (state is SubscriptionCatalogError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(BMJTokens.pageMargin),
                      child: BMJEmptyState(
                        icon: Icons.cloud_off_rounded,
                        title: 'Failed to load plans',
                        message: state.message,
                        action: BMJGlassButton(
                          label: 'Retry',
                          icon: Icons.refresh_rounded,
                          onPressed: () => context
                              .read<SubscriptionBloc>()
                              .add(const LoadSubscriptionCatalog()),
                        ),
                      ),
                    ),
                  );
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilies(
    BuildContext context,
    List<SubscriptionPlanCatalog> plans,
  ) {
    final List<String> families = _extractFamilies(plans);

    if (families.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(BMJTokens.pageMargin),
          child: BMJEmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No plans available',
            message: 'New plans are on the way. Please check back soon.',
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        BMJTokens.pageMargin,
        BMJTokens.spaceMd,
        BMJTokens.pageMargin,
        BMJTokens.spaceXl,
      ),
      itemCount: families.length,
      itemBuilder: (context, index) {
        final String family = families[index];
        final _FamilyMeta meta = _familyMeta[family] ?? _fallbackMeta;

        return _FamilyCard(
          family: family,
          meta: meta,
          priceLabel: _lowestPriceLabel(plans, family),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/subscription/plan',
              arguments: family,
            );
          },
        );
      },
    );
  }

  List<String> _extractFamilies(List<SubscriptionPlanCatalog> plans) {
    return plans.map((p) => p.family).toSet().toList()..sort();
  }

  /// "From ₹699/week" using the cheapest *priced* option of the family.
  ///
  /// Weekly wins over monthly (it is the price customers compare); options
  /// without a price are ignored so the label never shows a fabricated `₹0`.
  String _lowestPriceLabel(
    List<SubscriptionPlanCatalog> plans,
    String family,
  ) {
    final Iterable<SubscriptionPlanCatalog> familyPlans =
        plans.where((p) => p.family == family);

    double? cheapestAmount;
    bool cheapestIsWeekly = false;

    for (final SubscriptionPlanCatalog plan in familyPlans) {
      for (final SubscriptionPriceOption option in plan.prices) {
        if (option.priceInPaise <= 0) continue; // no price known
        final bool weekly = option.period == 'weekly';
        if (cheapestAmount == null ||
            (weekly && !cheapestIsWeekly) ||
            (weekly == cheapestIsWeekly &&
                option.priceInRupees < cheapestAmount)) {
          cheapestAmount = option.priceInRupees;
          cheapestIsWeekly = weekly;
        }
      }
    }

    if (cheapestAmount == null) return 'From $kPriceFallback';
    final String period = cheapestIsWeekly ? 'week' : 'month';
    return 'From ${formatRupees(cheapestAmount)}/$period';
  }
}

class _FamilyCard extends StatelessWidget {
  final String family;
  final _FamilyMeta meta;
  final String priceLabel;
  final VoidCallback onTap;

  const _FamilyCard({
    required this.family,
    required this.meta,
    required this.priceLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final BMJPalette palette = BMJPalette.of(context);
    final String title = family.toUpperCase();

    return BMJGlassCard(
      onTap: onTap,
      semanticLabel: '$title plans, $priceLabel',
      margin: const EdgeInsets.only(bottom: BMJTokens.gutter),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: BMJTokens.minTouchTarget,
            height: BMJTokens.minTouchTarget,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: <Color>[palette.primary, palette.primaryEmphasis],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(meta.icon, color: BMJTokens.inkOnBrand, size: 24),
          ),
          const SizedBox(width: BMJTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: AppTextStyles.textTheme.titleMedium?.copyWith(
                    color: palette.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                  ),
                ),
                const SizedBox(height: BMJTokens.spaceXs),
                Text(
                  meta.tagline,
                  style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                    color: palette.primaryEmphasis,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: BMJTokens.spaceXs),
                Text(
                  meta.description,
                  style: AppTextStyles.textTheme.bodySmall?.copyWith(
                    color: palette.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: BMJTokens.spaceSm),
                Text(
                  priceLabel,
                  style: AppTextStyles.textTheme.titleSmall?.copyWith(
                    color: palette.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: BMJTokens.spaceSm),
          Icon(
            Icons.chevron_right_rounded,
            color: palette.onSurfaceVariant,
            size: 22,
          ),
        ],
      ),
    );
  }
}
