class SubscriptionPlan {
  SubscriptionPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.pricingPageUrl,
    required this.startColor,
    required this.endColor,
    required this.imagePath,
    required this.features,
    this.price = 0,
    // Legacy support
    this.planID = 0,
    this.titleTxt = '',
    this.text = const <String>[],
  });

  final String id;
  final String name;
  final String description;
  final String pricingPageUrl;
  final String startColor;
  final String endColor;
  final String imagePath;
  final List<String> features;
  final int price;

  // Legacy support
  final int planID;
  final String titleTxt;
  final List<String>? text;

  // Create a Premium plan
  static SubscriptionPlan premium({required String pricingPageUrl}) {
    return SubscriptionPlan(
      id: 'premium',
      name: 'Premium Plan',
      description: 'Our premium selection of cold-pressed juices',
      pricingPageUrl: pricingPageUrl,
      startColor: '#FF9800',
      endColor: '#F57C00',
      imagePath: 'assets/premium_plan.png',
      features: [
        'Premium quality juices',
        'Weekly delivery',
        'Customizable selection',
        'Priority customer support',
      ],
      price: 3750,
      planID: 100,
      titleTxt: 'Premium',
    );
  }

  // Create a Signature plan
  static SubscriptionPlan signature({required String pricingPageUrl}) {
    return SubscriptionPlan(
      id: 'signature',
      name: 'Signature Plan',
      description: 'Our signature collection of exclusive juices',
      pricingPageUrl: pricingPageUrl,
      startColor: '#9C27B0',
      endColor: '#7B1FA2',
      imagePath: 'assets/signature_plan.png',
      features: [
        'Exclusive signature juices',
        'Bi-weekly delivery',
        'Personalized juice selection',
        'VIP customer support',
      ],
      price: 5780,
      planID: 101,
      titleTxt: 'Signature',
    );
  }

  // Create a Delight plan
  static SubscriptionPlan delight({required String pricingPageUrl}) {
    return SubscriptionPlan(
      id: 'delight',
      name: 'Delight Plan',
      description: 'Delightful selection of refreshing juices',
      pricingPageUrl: pricingPageUrl,
      startColor: '#4CAF50',
      endColor: '#388E3C',
      imagePath: 'assets/delight_plan.png',
      features: [
        'Refreshing juice selection',
        'Monthly delivery',
        'Basic customization',
        'Standard customer support',
      ],
      price: 2140,
      planID: 102,
      titleTxt: 'Delight',
    );
  }

  // Legacy list for backward compatibility
  static List<SubscriptionPlan> getLegacyPlans() {
    return [
      SubscriptionPlan(
        id: 'premium',
        name: 'Premium Plan',
        description: 'Our premium selection of cold-pressed juices',
        pricingPageUrl: '',
        startColor: '#FA7D82',
        endColor: '#FFB295',
        imagePath: 'assets/premium_plan.png',
        features: [
          "Premium quality juices",
          "Weekly delivery",
          "Customizable selection",
          "Priority customer support"
        ],
        price: 3750,
        planID: 100,
        titleTxt: '30:30',
        text: [
          "Premium quality juices",
          "Weekly delivery",
          "Customizable selection",
          "Priority customer support"
        ],
      ),
      SubscriptionPlan(
        id: 'signature',
        name: 'Signature Plan',
        description: 'Our signature collection of exclusive juices',
        pricingPageUrl: '',
        startColor: '#738AE6',
        endColor: '#5C5EDD',
        imagePath: 'assets/signature_plan.png',
        features: [
          "Exclusive signature juices",
          "Bi-weekly delivery",
          "Personalized juice selection",
          "VIP customer support"
        ],
        price: 1150,
        planID: 101,
        titleTxt: '15:30',
        text: [
          "Exclusive signature juices",
          "Bi-weekly delivery",
          "Personalized juice selection"
        ],
      ),
      SubscriptionPlan(
        id: 'delight',
        name: 'Delight Plan',
        description: 'Delightful selection of refreshing juices',
        pricingPageUrl: '',
        startColor: '#FE95B6',
        endColor: '#FF5287',
        imagePath: 'assets/delight_plan.png',
        features: [
          "Refreshing juice selection",
          "Monthly delivery",
          "Basic customization",
          "Standard customer support"
        ],
        price: 2140,
        planID: 2,
        titleTxt: '7:7',
        text: [
          "Refreshing juice selection",
          "Monthly delivery",
          "Basic customization"
        ],
      ),
    ];
  }
}
