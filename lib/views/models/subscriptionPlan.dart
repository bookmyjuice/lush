class subscriptionPlan {
  subscriptionPlan({
    this.planID=0,
    // this.imagePath='',
    this.titleTxt='',
    this.startColor='',
    this.endColor='',
    this.text= const <String>[],
    this.price=0,
  });

  int planID;
  // String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? text;
  int price;

  static List<subscriptionPlan> tabIconsList = <subscriptionPlan>[
    subscriptionPlan(
      planID:100,
      titleTxt: '30:30',
      price: 3750,
      text: ["text text text ","text text","text description","more description.."],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    subscriptionPlan(
      planID:101,
      titleTxt: '15:30',
      price: 1150,
      text: ["text text text ","text text","text description"],
      startColor: '#738AE6',
      endColor: '#5C5EDD',
    ),
    subscriptionPlan(
      planID: 2,
      titleTxt: '7:7',
      price: 2140,
      text: ["text text text ","text text","text description"],
      startColor: '#FE95B6',
      endColor: '#FF5287',
    ),
    subscriptionPlan(
      planID: 3,
      titleTxt: '1:7',
      price: 5780,
      text: ["text text text ","text text","text description"],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
    subscriptionPlan(
      planID: 4,
      titleTxt: 'plan name',
      price: 2560,
      text: ["text text text ","text text","text description"],
      startColor: '#6F72CA',
      endColor: '#1E1466',
    ),
  ];
}
