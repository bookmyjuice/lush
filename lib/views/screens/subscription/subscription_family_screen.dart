import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/views/models/subscription_plan_catalog.dart';

class SubscriptionFamilyScreen extends StatefulWidget {
  const SubscriptionFamilyScreen({super.key});

  @override
  State<SubscriptionFamilyScreen> createState() =>
      _SubscriptionFamilyScreenState();
}

class _SubscriptionFamilyScreenState extends State<SubscriptionFamilyScreen> {
  static const _familyMeta = {
    'delight': {
      'emoji': '🍊',
      'tagline': 'Fresh & Affordable',
      'description': 'Entry-level juices perfect for daily refreshment.',
    },
    'signature': {
      'emoji': '🥤',
      'tagline': 'Balanced & Popular',
      'description': 'Our signature blends with the perfect balance of taste and nutrition.',
    },
    'premium': {
      'emoji': '👑',
      'tagline': 'Premium & Exclusive',
      'description': 'The finest selection of cold-pressed juices for discerning taste.',
    },
  };

  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(const LoadSubscriptionCatalog());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Choose Your Plan',
          style: AppTextStyles.textTheme.titleLarge?.copyWith(
            color: AppColors.lightTextPrimary,
          ),
        ),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is SubscriptionCatalogError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48.sp, color: AppColors.error),
                  SizedBox(height: 16.h),
                  Text(
                    'Failed to load plans',
                    style: AppTextStyles.textTheme.titleMedium?.copyWith(
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<SubscriptionBloc>()
                          .add(const LoadSubscriptionCatalog());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is SubscriptionCatalogLoaded) {
            final families = _extractFamilies(state.plans);
            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: families.length,
              itemBuilder: (context, index) {
                final family = families[index];
                final lowestPrice = _getLowestPrice(state.plans, family);
                return _FamilyCard(
                  family: family,
                  emoji: _familyMeta[family]?['emoji'] ?? '🧃',
                  tagline: _familyMeta[family]?['tagline'] ?? '',
                  description: _familyMeta[family]?['description'] ?? '',
                  lowestPrice: lowestPrice,
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

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  List<String> _extractFamilies(List<SubscriptionPlanCatalog> plans) {
    return plans.map((p) => p.family).toSet().toList()
      ..sort();
  }

  double _getLowestPrice(List<SubscriptionPlanCatalog> plans, String family) {
    final familyPlans = plans.where((p) => p.family == family);
    double lowest = double.infinity;
    for (final plan in familyPlans) {
      for (final price in plan.prices) {
        if (price.priceInRupees < lowest) {
          lowest = price.priceInRupees;
        }
      }
    }
    return lowest == double.infinity ? 0 : lowest;
  }
}

class _FamilyCard extends StatelessWidget {
  final String family;
  final String emoji;
  final String tagline;
  final String description;
  final double lowestPrice;
  final VoidCallback onTap;

  const _FamilyCard({
    required this.family,
    required this.emoji,
    required this.tagline,
    required this.description,
    required this.lowestPrice,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryOrange.withValues(alpha: 0.9),
              AppColors.gradientEnd.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryOrange.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 64.r,
              height: 64.r,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Center(
                child: Text(emoji, style: TextStyle(fontSize: 32.sp)),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    family.toUpperCase(),
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    tagline,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'From ₹${lowestPrice.toStringAsFixed(0)} / week',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withValues(alpha: 0.7),
              size: 18.sp,
            ),
          ],
        ),
      ),
    );
  }
}