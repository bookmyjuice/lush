import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/subscription_plan_catalog.dart';
import 'package:lush/views/models/subscription_selection.dart';

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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0,
        title: Text('${family.toUpperCase()} Plans', style: TextStyle(color: AppColors.lightTextPrimary)),
      ),
      body: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionCatalogLoaded) {
            final plans = state.plans.where((p) => p.family == family).toList();
            if (plans.isEmpty) return _buildEmpty();
            final generic = plans.where((p) => p.isGeneric).toList();
            final juices = plans.where((p) => p.isJuiceSpecific).toList();
            return SingleChildScrollView(padding: EdgeInsets.all(16.r), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              if (generic.isNotEmpty) ...[
                _STitle('Choose a Plan'), SizedBox(height: 12.h),
                ...generic.map((p) => _SizeCard(plan: p, onSelect: _navigateToSchedule)),
              ],
              if (juices.isNotEmpty) ...[
                SizedBox(height: 24.h), _STitle('Start with a Favourite'), SizedBox(height: 12.h),
                _JGrid(juices: juices, onSelect: _navigateToSchedule),
              ],
            ]));
          }
          if (state is SubscriptionLoading) return const Center(child: CircularProgressIndicator());
          return _buildEmpty();
        },
      ),
    );
  }

  Widget _buildEmpty() => const Center(child: Text('No plans available', style: TextStyle(color: AppColors.lightTextSecondary)));
}

class _STitle extends StatelessWidget {
  final String t;
  const _STitle(this.t);
  @override
  Widget build(BuildContext c) => Text(t, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary));
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
    final p = _w ? widget.plan.weeklyPrice : widget.plan.monthlyPrice;
    if (p == null) return const SizedBox.shrink();
    return GestureDetector(
      onTap: () => widget.onSelect(SubscriptionSelection(itemId: widget.plan.itemId, itemPriceId: p.itemPriceId, family: widget.plan.family, size: widget.plan.size, period: _w ? 'weekly' : 'monthly', priceInPaise: p.priceInPaise, daySchedule: {})),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h), padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColors.lightDivider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(widget.plan.size, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
            const Spacer(),
            ToggleButtons(isSelected: [_w, !_w], onPressed: (i) => setState(() => _w = i == 0), borderRadius: BorderRadius.circular(8.r), selectedColor: AppColors.white, fillColor: AppColors.primaryOrange, color: AppColors.grey,
              children: [Padding(padding: EdgeInsets.symmetric(horizontal: 12.w), child: const Text('Weekly')), Padding(padding: EdgeInsets.symmetric(horizontal: 12.w), child: const Text('Monthly'))]),
          ]),
          SizedBox(height: 8.h),
          Text('₹${p.priceInRupees.toStringAsFixed(0)}/${_w ? 'week' : 'month'}', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
          SizedBox(height: 4.h),
          Text(_w ? '6 bottles/week' : '24 bottles/month', style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary)),
        ]),
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
    for (final j in juices) { u[j.defaultJuice ?? j.name] = j; }
    return GridView.count(crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisSpacing: 8.w, mainAxisSpacing: 8.h, childAspectRatio: 0.85,
      children: u.values.map((j) => _JCard(plan: j, onSelect: onSelect)).toList());
  }
}

class _JCard extends StatelessWidget {
  final SubscriptionPlanCatalog plan;
  final void Function(SubscriptionSelection) onSelect;
  const _JCard({required this.plan, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    final wp = plan.weeklyPrice;
    return GestureDetector(
      onTap: () { showModalBottomSheet<void>(context: context, builder: (_) => _Picker(plan: plan, onSelect: onSelect)); },
      child: Container(padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.secondaryTeal.withValues(alpha: 0.8), AppColors.info.withValues(alpha: 0.6)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12.r)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text((plan.defaultJuice ?? plan.name).replaceAll('-', ' ').split(' ').map((w) => '${w[0].toUpperCase()}${w.substring(1)}').join(' '), style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.white), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          SizedBox(height: 8.h),
          if (wp != null) Text('From ₹${wp.priceInRupees.toStringAsFixed(0)}', style: TextStyle(fontSize: 12.sp, color: AppColors.white)),
        ]),
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
    final selected = _w ? widget.plan.weeklyPrice! : widget.plan.monthlyPrice!;
    return Container(padding: EdgeInsets.all(20.r), child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(2))),
      SizedBox(height: 16.h),
      Text('Select Size & Duration', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary)),
      SizedBox(height: 16.h),
      ToggleButtons(isSelected: List.generate(3, (i) => ['200ml','300ml','500ml'][i]==_s), onPressed: (i){setState((){_s=['200ml','300ml','500ml'][i];});}, borderRadius: BorderRadius.circular(8.r), selectedColor: AppColors.white, fillColor: AppColors.primaryOrange, color: AppColors.grey,
        children: const [Text('200ml'),Text('300ml'),Text('500ml')].map((t)=>Padding(padding: EdgeInsets.symmetric(horizontal: 16.w), child: t)).toList()),
      SizedBox(height: 12.h),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        ChoiceChip(label: const Text('Weekly'), selected: _w, selectedColor: AppColors.primaryOrange, labelStyle: TextStyle(color: _w ? AppColors.white : AppColors.lightTextPrimary), onSelected: (_) => setState(() => _w = true)),
        SizedBox(width: 8.w),
        ChoiceChip(label: const Text('Monthly'), selected: !_w, selectedColor: AppColors.primaryOrange, labelStyle: TextStyle(color: !_w ? AppColors.white : AppColors.lightTextPrimary), onSelected: (_) => setState(() => _w = false)),
      ]),
      SizedBox(height: 12.h),
      Text('₹${selected.priceInRupees.toStringAsFixed(0)}/${_w?'week':'month'}', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.primaryOrange)),
      SizedBox(height: 16.h),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () {
        Navigator.pop(context);
        final ds = <String, String>{'monday':widget.plan.defaultJuice!,'tuesday':widget.plan.defaultJuice!,'wednesday':widget.plan.defaultJuice!,'thursday':widget.plan.defaultJuice!,'friday':widget.plan.defaultJuice!,'saturday':widget.plan.defaultJuice!};
        widget.onSelect(SubscriptionSelection(itemId: widget.plan.itemId, itemPriceId: selected.itemPriceId, family: widget.plan.family, size: _s, period: _w ? 'weekly' : 'monthly', priceInPaise: selected.priceInPaise, defaultJuice: widget.plan.defaultJuice, daySchedule: ds));
      }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryOrange, foregroundColor: AppColors.white, padding: EdgeInsets.symmetric(vertical: 14.h), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))), child: Text('Select', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)))),
    ]));
  }
}