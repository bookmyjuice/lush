import '../../bloc/SubscriptionBloc/subscription_bloc.dart';

/// Plan model for subscription plans.
///
/// Mirrors SubscriptionPlan (inline in subscription_bloc.dart) but adds
/// full JSON serialization (fromJson/toJson) for API integration.
///
/// Use this model when deserializing plan data from the backend,
/// then convert to SubscriptionPlan for bloc consumption.
class Plan {
  final String id;
  final String name;
  final String description;
  final String pricingPageUrl;
  final String startColor;
  final String endColor;
  final String imagePath;
  final List<String> features;
  final int planID;

  const Plan({
    required this.id,
    required this.name,
    this.description = '',
    this.pricingPageUrl = '',
    this.startColor = '#FF9800',
    this.endColor = '#FF5722',
    this.imagePath = 'assets/subscription.png',
    this.features = const [],
    required this.planID,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    // snake_case from Chargebee/backend, camelCase fallback
    final rawFeatures = json['features'];
    return Plan(
      id: (json['id'] ?? json['plan_id'] ?? '').toString(),
      name: (json['name'] ?? json['plan_name'] ?? '').toString(),
      description: (json['description'] ?? json['plan_description'] ?? '').toString(),
      pricingPageUrl: (json['pricing_page_url'] ?? json['pricingPageUrl'] ?? '').toString(),
      startColor: (json['start_color'] ?? json['startColor'] ?? '#FF9800').toString(),
      endColor: (json['end_color'] ?? json['endColor'] ?? '#FF5722').toString(),
      imagePath: (json['image_path'] ?? json['imagePath'] ?? 'assets/subscription.png').toString(),
      features: rawFeatures != null
          ? (rawFeatures is List
              ? List<String>.from(rawFeatures.map((e) => e.toString()))
              : rawFeatures.toString().split(',').map((e) => e.trim()).toList())
          : const [],
      planID: int.tryParse((json['plan_i_d'] ?? json['planID'] ?? '0').toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'pricing_page_url': pricingPageUrl,
      'start_color': startColor,
      'end_color': endColor,
      'image_path': imagePath,
      'features': features,
      'plan_id': planID,
    };
  }

  /// Convert to the inline SubscriptionPlan used by SubscriptionBloc.
  SubscriptionPlan toSubscriptionPlan() {
    return SubscriptionPlan(
      id: id,
      name: name,
      description: description,
      pricingPageUrl: pricingPageUrl,
      startColor: startColor,
      endColor: endColor,
      imagePath: imagePath,
      features: features,
      planID: planID,
    );
  }
}