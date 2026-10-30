import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/bmj_tokens.dart';
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
                    _STitle('Choose a Plan', isDark: isDark),
                    SizedBox(height: 12.h),
                    ...generic.map((p) =>
                        _SizeCard(plan: p, onSelect: _navigateToSchedule)),
                  ],
                  if (juices.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    _STitle('Start with a Favourite', isDark: isDark),
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
  void initState() {
    super.initState();
    // A monthly-only plan used to vanish (the card returned `SizedBox.shrink`
    // because `_w` started on weekly). Start on a period the catalog priced.
    _w = widget.plan.weeklyPrice != null;
  }

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
                  onPressed: (i) {
                    // Never switch to a period this plan has no price for —
                    // that was the force-unwrap crash path.
                    if (i == 0 && widget.plan.weeklyPrice == null) return;
                    if (i == 1 && widget.plan.monthlyPrice == null) return;
                    setState(() => _w = i == 0);
                  },
                  borderRadius: BorderRadius.circular(8.r),
                  selectedColor: BMJTokens.inkOnBrand,
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
              '₹${p.priceInRupees.toStringAsFixed(0)}/${_w ? 'week' : 'month'}',
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
      children: u.values
          .map((j) => _JCard(
                plan: j,
                onSelect: onSelect,
                familyPlans: juices.where((p) => p.family == j.family).toList(),
              ))
          .toList(),
    );
  }
}

class _JCard extends StatelessWidget {
  final SubscriptionPlanCatalog plan;
  final void Function(SubscriptionSelection) onSelect;

  /// Every catalog entry in the same family — one entry per size.
  ///
  /// The picker resolves a chosen size through this list so `itemPriceId`
  /// always belongs to the size the customer picked (previously the size chips
  /// were decorative and the 200 ml price id was sent for a 500 ml choice).
  final List<SubscriptionPlanCatalog> familyPlans;

  const _JCard({
    required this.plan,
    required this.onSelect,
    this.familyPlans = const <SubscriptionPlanCatalog>[],
  });
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
          builder: (_) => _Picker(
            plan: plan,
            onSelect: onSelect,
            familyPlans: familyPlans,
          ),
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
              color: BMJTokens.inkOnBrand,
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

  /// Every size of this family, so a chosen size resolves to its own price id.
  final List<SubscriptionPlanCatalog> familyPlans;

  const _Picker({
    required this.plan,
    required this.onSelect,
    this.familyPlans = const <SubscriptionPlanCatalog>[],
  });

  @override
  State<_Picker> createState() => _PickerState();
}

class _PickerState extends State<_Picker> {
  late String _s;
  late bool _w;

  @override
  void initState() {
    super.initState();
    final List<String> sizes = _sizes;
    final String planSize = widget.plan.size.trim();
    if (planSize.isNotEmpty && sizes.contains(planSize)) {
      _s = planSize;
    } else {
      _s = sizes.isEmpty ? planSize : sizes.first;
    }
    // Start on a period this size actually sells.
    _w = _planForSize(_s)?.weeklyPrice != null;
  }

  List<SubscriptionPlanCatalog> get _plans => widget.familyPlans.isEmpty
      ? <SubscriptionPlanCatalog>[widget.plan]
      : widget.familyPlans;

  /// Distinct sizes sold in this family ("200ml", "300ml", …).
  List<String> get _sizes {
    final Set<String> seen = <String>{};
    for (final SubscriptionPlanCatalog plan in _plans) {
      final String size = plan.size.trim();
      if (size.isNotEmpty) seen.add(size);
    }
    return seen.toList();
  }

  /// Catalog entry for [size] — never borrows another size's price id.
  SubscriptionPlanCatalog? _planForSize(String size) {
    for (final SubscriptionPlanCatalog plan in _plans) {
      if (plan.size.trim() == size) return plan;
    }
    // Single-entry families have nothing to resolve; a multi-entry family must
    // resolve exactly, otherwise the chosen size cannot be honoured.
    return _plans.length == 1 ? _plans.first : null;
  }

  bool _sellsPeriod(SubscriptionPlanCatalog? plan, bool weekly) {
    if (plan == null) return false;
    return weekly ? plan.weeklyPrice != null : plan.monthlyPrice != null;
  }

  SubscriptionPriceOption? get _option {
    final SubscriptionPlanCatalog? plan = _planForSize(_s);
    if (plan == null) return null;
    return _w ? plan.weeklyPrice : plan.monthlyPrice;
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final textPrimaryColor =
        isDark ? AppColors.glassText : AppColors.lightTextPrimary;
    final accentColor =
        isDark ? AppColors.glassAccent : AppColors.primaryOrange;

    final SubscriptionPriceOption? option = _option;

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
            'Select Duration',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: textPrimaryColor,
            ),
          ),
          if (_sizes.length > 1) ...[
            SizedBox(height: 16.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: _sizes.map((size) {
                final bool isSelected = size == _s;
                final bool enabled = _sellsPeriod(_planForSize(size), _w);
                return ChoiceChip(
                  label: Text(size),
                  selected: isSelected,
                  selectedColor: accentColor,
                  labelStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    color: isSelected ? BMJTokens.inkOnBrand : textPrimaryColor,
                  ),
                  onSelected: enabled ? (_) => setState(() => _s = size) : null,
                );
              }).toList(),
            ),
          ],
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
                  color: _w ? BMJTokens.inkOnBrand : textPrimaryColor,
                ),
                onSelected: _sellsPeriod(_planForSize(_s), true)
                    ? (_) => setState(() => _w = true)
                    : null,
              ),
              SizedBox(width: 8.w),
              ChoiceChip(
                label: const Text('Monthly'),
                selected: !_w,
                selectedColor: accentColor,
                labelStyle: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: !_w ? BMJTokens.inkOnBrand : textPrimaryColor,
                ),
                onSelected: _sellsPeriod(_planForSize(_s), false)
                    ? (_) => setState(() => _w = false)
                    : null,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            option == null
                ? '—'
                : '₹${option.priceInRupees.toStringAsFixed(0)} / ${_w ? 'week' : 'month'}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          if (option != null) ...[
            SizedBox(height: 4.h),
            Text(
              '${option.bottleCount} bottles',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                color: isDark ? AppColors.glassTextDim : AppColors.grey,
              ),
            ),
          ],
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: option == null ? null : () => _confirm(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: BMJTokens.inkOnBrand,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                option == null ? 'Unavailable' : 'Select',
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

  void _confirm(SubscriptionPriceOption option) {
    final SubscriptionPlanCatalog plan = _planForSize(_s) ?? widget.plan;
    final String? juice = plan.defaultJuice;

    final Map<String, String> schedule = <String, String>{};
    if (juice != null) {
      for (final String day in const <String>[
        'monday',
        'tuesday',
        'wednesday',
        'thursday',
        'friday',
        'saturday',
      ]) {
        schedule[day] = juice;
      }
    }

    Navigator.pop(context);
    widget.onSelect(
      SubscriptionSelection(
        itemId: plan.itemId,
        itemPriceId: option.itemPriceId,
        family: plan.family,
        size: plan.size.trim().isEmpty ? _s : plan.size,
        period: _w ? 'weekly' : 'monthly',
        priceInPaise: option.priceInPaise,
        defaultJuice: plan.defaultJuice,
        daySchedule: schedule,
      ),
    );
  }
}
