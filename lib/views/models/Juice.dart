class Juice {
  Juice({
    this.juiceID=0,
    this.imagePath='',
    this.titleTxt='',
    this.startColor='',
    this.endColor='',
    this.meals= const [],
    this.kacl=0,
  });

  int juiceID;
  String imagePath;
  String titleTxt;
  String startColor;
  String endColor;
  List<String>? meals;
  int kacl;

  static List<Juice> tabIconsList = <Juice>[
    Juice(
      juiceID:0,
      imagePath: 'assets/watermelon.png',
      titleTxt: 'Watermelon',
      kacl: 525,
      meals: <String>['Watermelon juice'],
      startColor: '#FA7D82',
      endColor: '#FFB295',
    ),
    Juice(
      juiceID:1,
      imagePath: 'assets/pineapple.png',
      titleTxt: 'Pineapple',
      kacl: 602,
      meals: <String>[
        'Fresh pineapple,',
        'a pinch of salt',
        'It' 's a pineapple',
        'in bottle!'
      ],
      startColor: '#FEE12D',
      endColor:  '#ffd964',
    ),
    Juice(
      juiceID: 2,
      imagePath: 'assets/ABC.png',
      titleTxt: 'ABC',
      kacl: 0,
      meals: <String>['Apple', 'Beetroot', 'Carrot'],
      startColor: '#673f45',
      endColor: '#7a1f3d',
    ),
    Juice(
      juiceID: 3,
      imagePath: 'assets/VitaminC.png',
      titleTxt: 'Vitamin C',
      kacl: 0,
      meals: <String>['Amla', 'Pineapple', 'Tangerine'],
      startColor: '#FFF12D',
      endColor: '#988623',
    ),
    Juice(
      juiceID: 4,
      imagePath: 'assets/PBC.png',
      titleTxt: 'Bloody Red',
      kacl: 0,
      meals: <String>['Recommend:', '703 kcal'],
      startColor: '#880808',
      endColor: '#B8292C',
    ),
  ];
}
