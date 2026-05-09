class ItemData {
  ItemData({
    this.itemID = 0,
    this.id = '',
    this.name = '',
    this.imagePath = '',
    this.titleTxt = '',
    this.startColor = '',
    this.endColor = '',
    this.meals = const [],
    this.kacl = 0,
    this.description,
    this.status = 'ACTIVE',
  });

  int itemID;
  String id;
  String name;
  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? meals;
  int kacl;
  String? description;
  String status;

  static List<ItemData> tabIconsList = <ItemData>[
    ItemData(
      itemID: 0,
      imagePath: 'assets/watermelon.png',
      titleTxt: 'Watermelon',
      kacl: 525,
      meals: <String>['Watermelon juice'],
      startColor: '#FFB1C9',
      endColor: '#B8292C',
    ),
    ItemData(
      itemID: 1,
      imagePath: 'assets/pineapple.png',
      titleTxt: 'Pineapple',
      kacl: 602,
      meals: <String>[
        'Fresh pineapple,',
        'a pinch of salt',
        'It\'s a pineapple',
        'in bottle!'
      ],
      startColor: '#fad704',
      endColor: '#ffd964',
    ),
    ItemData(
      itemID: 2,
      imagePath: 'assets/ABC.png',
      titleTxt: 'ABC',
      kacl: 0,
      meals: <String>['Apple', 'Beetroot', 'Carrot'],
      startColor: '#673f45',
      endColor: '#7a1f3d',
    ),
    ItemData(
      itemID: 3,
      imagePath: 'assets/VitaminC.png',
      titleTxt: 'Vitamin C',
      kacl: 0,
      meals: <String>['Amla', 'Pineapple', 'Tangerine'],
      startColor: '#FFF12D',
      endColor: '#988623',
    ),
    ItemData(
      itemID: 4,
      imagePath: 'assets/PBC.png',
      titleTxt: 'Bloody Red',
      kacl: 0,
      meals: <String>['Beetroot', 'Pomegranate'],
      startColor: '#880808',
      endColor: '#B8292C',
    ),
  ];
}
