import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart' as hex;
import 'package:lush/theme/app_text_styles.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final Map<String, dynamic> plan;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    this.animationController,
    this.animation,
  });

  void _navigateToPlans(BuildContext context) {
    Navigator.of(context).pushNamed('/plan-selection');
  }

  @override
  Widget build(BuildContext context) {
    final startColor = (plan['startColor'] as String?) ?? '#FF9800';
    final endColor = (plan['endColor'] as String?) ?? '#FF5722';
    final planName = (plan['name'] as String?) ?? '';
    final planDescription = (plan['description'] as String?) ?? '';
    final planPrice = (plan['price'] as String?) ?? '0';

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [
                        hex.HexColor(startColor),
                        hex.HexColor(endColor),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Plan header
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            planName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            planDescription,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '\u20B9$planPrice / month',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Features list
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: ((plan['features'] as List<dynamic>?)
                                    ?.cast<String>() ??
                                <String>[])
                            .map((feature) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.check_circle,
                                          color: Colors.white, size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          feature,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: AppTextStyles.fontFamily,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),

                    // Subscribe button
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _navigateToPlans(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: hex.HexColor(endColor),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Subscribe Now',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}