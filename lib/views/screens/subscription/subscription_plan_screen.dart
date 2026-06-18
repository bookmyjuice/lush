import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/models/subscription_plan_catalog.dart';
import 'package:lush/views/models/subscription_selection.dart';
import 'package:lush/widgets/glass_card.dart';

class SubscriptionPlanScreen extends StatefulWidget {
  final String family;
  const SubscriptionPlanScreen({super.key, required this.family});
  @override
  State<SubscriptionPlanScreen> createState() => _SubscriptionPlanScreenState();
}

class _SubscriptionPlanScreenState extends State<SubscriptionPlanScreen> {
  void _navigateToSchedule(SubscriptionSelection s) {
    Navigator.pushNamed(context, '/subscription-schedule', arguments: s);
  }

  @override
  Widget build(BuildContext context) {
    final family = widget.family;
    final isDark =
        context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final bgColor = isDark ? AppColors.glassBg : AppColors.glassBgLight;
    final textPrimaryColor =
        isDark ? AppColors.glassText : AppColors.lightTextPrimary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${family.toUpperCase()} Plans 🍊',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
            fontSize: 20.sp,
          ),
        ),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionCatalogLoaded) {
            final plans = state.plans.where((p) => p.family == family).toList();
            if (plans.isEmpty) return _buildEmpty();
            final generic = plans.where((p) => p.isGeneric).toList();
            final juices = plans.where((p) => p.isJuiceSpecific).toList();
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (generic.isNotEmpty) ...[
                    _STitle('Choose a Plan 🌟', isDark: isDark),
                    SizedBox(height: 12.h),
                    ...generic.map((p) =>
                        _SizeCard(plan: p, onSelect: _navigateToSchedule)),
                  ],
                  if (juices.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _STitle('Start with a Favourite 🍹', isDark: isDark),
                    SizedBox(height: 12.h),
                    _JGrid(juices: juices, onSelect: _navigateToSchedule),
                  ],
                ],
              ),
            );
          }
          if (state is SubscriptionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildEmpty();
        },
      ),
    );
  }

  Widget _buildEmpty() => const Center(
        child: Text(
          'No plans available',
          style: TextStyle(
            fontFamily: 'Inter',
            color: AppColors.glassTextDim,
          ),
        ),
      );
}

class _STitle extends StatelessWidget {
  final String t;
  final bool isDark;
  const _STitle(this.t, {required this.isDark});
  @override
  Widget build(BuildContext c) => Text(
        t,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
        ),
      );
}

class _SizeCard extends StatefulWidget {
  final SubscriptionPlanCatalog plan;
  final void Function(SubscriptionSelection) onSelect;
  const _SizeCard({required this.plan, required this.onSelect});
  @override
  State<_SizeCard> createState() => _SizeCardState();
}

class _SizeCardState extends State<_SizeCard> {
  bool _w = true;
  @override
  Widget build(BuildContext context) {
    final isDark =
        context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final textPrimaryColor =
        isDark ? AppColors.glassText : AppColors.lightTextPrimary;
    final textSecondaryColor =
        isDark ? AppColors.glassTextDim : AppColors.lightTextSecondary;
    final accentColor =
        isDark ? AppColors.glassAccent : AppColors.primaryOrange;

    final p = _w ? widget.plan.weeklyPrice : widget.plan.monthlyPrice;
    if (p == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GlassCard(
        padding: EdgeInsets.all(16.r),
        borderRadius: AppRadius.lg,
        onTap: () => widget.onSelect(
          SubscriptionSelection(
            itemId: widget.plan.itemId,
            itemPriceId: p.itemPriceId,
            family: widget.plan.family,
            size: widget.plan.size,
            period: _w ? 'weekly' : 'monthly',
            priceInPaise: p.priceInPaise,
            daySchedule: {},
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.plan.size,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: textPrimaryColor,
                  ),
                ),
                const Spacer(),
                ToggleButtons(
                  isSelected: [_w, !_w],
                  onPressed: (i) => setState(() => _w = i == 0),
                  borderRadius: BorderRadius.circular(8.r),
                  selectedColor: Colors.white,
                  fillColor: accentColor,
                  color: isDark ? AppColors.glassTextDim : AppColors.grey,
                  constraints: BoxConstraints(minHeight: 32.h),
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: const Text('Weekly',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.w),
                      child: const Text('Monthly',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.bold,
                              fontSize: 12)),
                    )
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '₹${p.priceInRupees.toStringAsFixed(0)} / ${_w ? 'week' : 'month'}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              _w ? '📦 6 bottles / week' : '📦 24 bottles / month',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                color: textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JGrid extends StatelessWidget {
  final List<SubscriptionPlanCatalog> juices;
  final void Function(SubscriptionSelection) onSelect;
  const _JGrid({required this.juices, required this.onSelect});
  @override
  Widget build(BuildContext c) {
    final u = <String, SubscriptionPlanCatalog>{};
    for (final j in juices) {
      u[j.defaultJuice ?? j.name] = j;
    }
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10.w,
      mainAxisSpacing: 10.h,
      childAspectRatio: 0.85,
      children:
          u.values.map((j) => _JCard(plan: j, onSelect: onSelect)).toList(),
    );
  }
}

class _JCard extends StatelessWidget {
  final SubscriptionPlanCatalog plan;
  final void Function(SubscriptionSelection) onSelect;
  const _JCard({required this.plan, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final wp = plan.weeklyPrice;
    final isDark =
        context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;

    return GlassCard(
      padding: EdgeInsets.all(12.r),
      borderRadius: AppRadius.lg,
      gradient: LinearGradient(
        colors: isDark
            ? [
                AppColors.glassAccent.withValues(alpha: 0.25),
                AppColors.glassAccentDark.withValues(alpha: 0.15)
              ]
            : [
                AppColors.primaryOrange.withValues(alpha: 0.8),
                AppColors.primaryOrangeDark.withValues(alpha: 0.7)
              ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (_) => _Picker(plan: plan, onSelect: onSelect),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            (plan.defaultJuice ?? plan.name)
                .replaceAll('-', ' ')
                .split(' ')
                .map((w) => w.isNotEmpty
                    ? '${w[0].toUpperCase()}${w.substring(1)}'
                    : '')
                .join(' '),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          if (wp != null)
            Text(
              'From ₹${wp.priceInRupees.toStringAsFixed(0)}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                color: Colors.white70,
              ),
            ),
        ],
      ),
    );
  }
}

class _Picker extends StatefulWidget {
  final SubscriptionPlanCatalog plan;
  final void Function(SubscriptionSelection) onSelect;
  const _Picker({required this.plan, required this.onSelect});
  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  String _s = '200ml';
  bool _w = true;
  @override
  Widget build(BuildContext context) {
    final isDark =
        context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final textPrimaryColor =
        isDark ? AppColors.glassText : AppColors.lightTextPrimary;
    final accentColor =
        isDark ? AppColors.glassAccent : AppColors.primaryOrange;

    final selected = _w ? widget.plan.weeklyPrice! : widget.plan.monthlyPrice!;
    return GlassCard(
      padding: EdgeInsets.all(20.r),
      borderRadius: AppRadius.xl,
      borderColor: isDark ? AppColors.glassBorder : AppColors.glassBorderLight,
      backgroundColor:
          isDark ? AppColors.glassElevated : AppColors.glassElevatedLight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? AppColors.glassTextDim : AppColors.grey,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Select Size & Duration ⚡',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          ToggleButtons(
            isSelected:
                List.generate(3, (i) => ['200ml', '300ml', '500ml'][i] == _s),
            onPressed: (i) {
              setState(() {
                _s = ['200ml', '300ml', '500ml'][i];
              });
            },
            borderRadius: BorderRadius.circular(8.r),
            selectedColor: Colors.white,
            fillColor: accentColor,
            color: isDark ? AppColors.glassTextDim : AppColors.grey,
            children: const [Text('200ml'), Text('300ml'), Text('500ml')]
                .map((t) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: t,
                    ))
                .toList(),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ChoiceChip(
                label: const Text('Weekly'),
                selected: _w,
                selectedColor: accentColor,
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: _w ? Colors.white : textPrimaryColor,
                ),
                onSelected: (_) => setState(() => _w = true),
              ),
              SizedBox(width: 8.w),
              ChoiceChip(
                label: const Text('Monthly'),
                selected: !_w,
                selectedColor: accentColor,
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: !_w ? Colors.white : textPrimaryColor,
                ),
                onSelected: (_) => setState(() => _w = false),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '₹${selected.priceInRupees.toStringAsFixed(0)} / ${_w ? 'week' : 'month'}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final ds = <String, String>{
                  'monday': widget.plan.defaultJuice!,
                  'tuesday': widget.plan.defaultJuice!,
                  'wednesday': widget.plan.defaultJuice!,
                  'thursday': widget.plan.defaultJuice!,
                  'friday': widget.plan.defaultJuice!,
                  'saturday': widget.plan.defaultJuice!
                };
                widget.onSelect(
                  SubscriptionSelection(
                    itemId: widget.plan.itemId,
                    itemPriceId: selected.itemPriceId,
                    family: widget.plan.family,
                    size: _s,
                    period: _w ? 'weekly' : 'monthly',
                    priceInPaise: selected.priceInPaise,
                    defaultJuice: widget.plan.defaultJuice,
                    daySchedule: ds,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Select ✨',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
