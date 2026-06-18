import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/views/models/subscription_plan_catalog.dart';

class SubscriptionPlansScreen extends StatefulWidget {
  const SubscriptionPlansScreen({super.key});
  @override
  State<SubscriptionPlansScreen> createState() => _SubscriptionPlansScreenState();
}

class _SubscriptionPlansScreenState extends State<SubscriptionPlansScreen> {
  @override
  void initState() {
    super.initState();
    context.read<SubscriptionBloc>().add(const LoadSubscriptionCatalog());
  }

  void _onPlanSelected(BuildContext context, SubscriptionPlanCatalog plan) {
    final price = plan.weeklyPrice?.priceInRupees ?? plan.monthlyPrice?.priceInRupees ?? 0;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text('You selected', style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            plan.name,
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
          ),
          Text(
            '₹${price.toStringAsFixed(0)}/month',
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Navigate to schedule/checkout
                if (plan.weeklyPrice != null) {
                  Navigator.pushNamed(context, '/subscription-summary');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Confirm & Continue →',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ),
          ),
        ],),
      ),
    );
  }

  Widget _featureRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey.shade700))),
      ],),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            height: 130,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
            ),
            child: SafeArea(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Choose Your Plan',
                  style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fresh juice, delivered daily ✓',
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70),
                ),
              ],),
            ),
          ),
          // Plan list
          Expanded(
            child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
              builder: (context, state) {
                if (state is SubscriptionLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is SubscriptionCatalogLoaded) {
                  final plans = state.plans.where((p) => p.isGeneric).toList();
                  if (plans.isEmpty) {
                    return const Center(child: Text('No plans available'));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 16),
                    itemCount: plans.length,
                    itemBuilder: (context, index) {
                      final plan = plans[index];
                      final price = plan.weeklyPrice?.priceInRupees ?? plan.monthlyPrice?.priceInRupees ?? 0;
                      final dailyPrice = (price / 30).round();

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        child: Stack(children: [
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(
                                plan.name,
                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1B5E20)),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                plan.metadata['description'] as String? ?? 'Premium daily juice delivery',
                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey, fontStyle: FontStyle.italic),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                              Divider(height: 20, color: Colors.grey.shade200),
                              Row(children: [
                                Text(
                                  '₹${price.toStringAsFixed(0)}',
                                  style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32)),
                                ),
                                const Text('/month', style: TextStyle(fontSize: 14, color: Colors.grey)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFF2E7D32)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '₹$dailyPrice/day',
                                    style: const TextStyle(fontSize: 11, color: Color(0xFF2E7D32)),
                                  ),
                                ),
                              ],),
                              const SizedBox(height: 12),
                              _featureRow('Choose your daily juice variety'),
                              _featureRow('Free doorstep delivery'),
                              _featureRow('Pause or cancel anytime'),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _onPlanSelected(context, plan),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E7D32),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    'Select This Plan →',
                                    style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            ],),
                          ),
                          // POPULAR badge on index 1
                          if (index == 1)
                            Positioned(top: 0, right: 0,
                              child: ClipRRect(
                                borderRadius: const BorderRadius.only(topRight: Radius.circular(16)),
                                child: SizedBox(width: 72, height: 72,
                                  child: Stack(children: [
                                    Positioned(top: 12, right: -20,
                                      child: Transform.rotate(angle: 0.785,
                                        child: Container(width: 90, height: 22,
                                          color: Colors.amber,
                                          child: const Center(child: Text('⭐ POPULAR',
                                            style: TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),),),
                                        ),
                                      ),
                                    ),
                                  ],),
                                ),
                              ),
                            ),
                        ],),
                      );
                    },
                  );
                }
                if (state is SubscriptionCatalogError) {
                  return Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text(state.message, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.read<SubscriptionBloc>().add(const LoadSubscriptionCatalog()),
                        child: const Text('Retry'),
                      ),
                    ],),
                  );
                }
                return const Center(child: Text('Loading...'));
              },
            ),
          ),
        ],
      ),
    );
  }
}