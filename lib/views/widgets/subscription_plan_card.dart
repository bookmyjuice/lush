import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart' as hex;
import '../../theme.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import for Android features
// Import for iOS features

import '../models/subscriptionPlan.dart';

class SubscriptionPlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final AnimationController? animationController;
  final Animation<double>? animation;

  const SubscriptionPlanCard({
    super.key,
    required this.plan,
    this.animationController,
    this.animation,
  });

  Future<void> _launchPricingPage(BuildContext context) async {
    if (plan.pricingPageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Pricing page URL not available. Please try again later.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      // Create a WebViewController
      final WebViewController controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0x00000000))
        ..setNavigationDelegate(
          NavigationDelegate(
            onProgress: (int progress) {
              // Update loading bar
              print('WebView is loading (progress : $progress%)');
            },
            onPageStarted: (String url) {
              print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              print('Page finished loading: $url');
            },
            onWebResourceError: (WebResourceError error) {
              print('Webview error: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(plan.pricingPageUrl));

      // Open the pricing page in a WebView instead of an external browser
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: Text('${plan.name} Subscription'),
              backgroundColor: LushTheme.nearlyDarkBlue,
              foregroundColor: Colors.white,
            ),
            body: WebViewWidget(controller: controller),
          ),
        ),
      );
    } catch (e) {
      print('Error launching WebView: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening subscription page: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                      hex.HexColor(plan.startColor),
                      hex.HexColor(plan.endColor),
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
                            plan.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: LushTheme.fontName,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            plan.description,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontFamily: LushTheme.fontName,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '₹${plan.price} / month',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: LushTheme.fontName,
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
                        children: plan.features
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
                                            fontFamily: LushTheme.fontName,
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
                          onPressed: () => _launchPricingPage(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: hex.HexColor(plan.endColor),
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
                              fontFamily: LushTheme.fontName,
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
