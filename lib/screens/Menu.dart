import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lush/main.dart';
import 'package:lush/screens/detail.dart';
import 'package:lush/theme.dart';
import 'package:lush/models/model.dart';
import 'package:lush/models/Juice.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> with TickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> topBarAnimation;
  List<Juice> juices = Juice.tabIconsList;
  double topBarOpacity = 0.2;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(),
        body: Container(
      decoration: const BoxDecoration(color: LushTheme.background),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          SafeArea(
            child: ListView.builder(
              padding:
                  const EdgeInsets.only(top: 100, bottom: 2, right: 2, left: 2),
              itemCount: juices.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int index) {
                final int count = juices.length > 10 ? 10 : juices.length;
                final Animation<double> animation =
                    Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                        parent: animationController,
                        curve: Interval((1 / count) * index, 1.0,
                            curve: Curves.fastOutSlowIn)));
                animationController.forward();
                return _JuicesView(
                  JuiceListData: juices[index],
                  animation: animation,
                  animationController: animationController,
                );
              },
            ),
          ),
          getAppBarUI(),
        ],
      ),
    ));
  }

  Widget getAppBarUI() {
    return Column(
      children: <Widget>[
        AnimatedBuilder(
          animation: animationController,
          builder: (BuildContext context, Widget? child) {
            return FadeTransition(
              opacity: topBarAnimation,
              child: Transform(
                transform: Matrix4.translationValues(
                    0.0, 30 * (1.0 - topBarAnimation.value), 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: LushTheme.nearlyDarkBlue.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color:
                              LushTheme.grey.withOpacity(0.4 * topBarOpacity),
                          offset: const Offset(1.1, 1.1),
                          blurRadius: 10.0),
                    ],
                  ),
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: MediaQuery.of(context).padding.top,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16 - 8.0 * topBarOpacity,
                            bottom: 12 - 8.0 * topBarOpacity),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'My Juices',
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontFamily: LushTheme.fontName,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10 + 6 - 6 * topBarOpacity,
                                    letterSpacing: 1.2,
                                    color: LushTheme.darkerText,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(32.0)),
                                onTap: () {},
                                child: const Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_left,
                                    color: LushTheme.grey,
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.only(
                                left: 8,
                                right: 8,
                              ),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(
                                      Icons.calendar_today,
                                      color: LushTheme.grey,
                                      size: 18,
                                    ),
                                  ),
                                  Text(
                                    '15 May',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontFamily: LushTheme.fontName,
                                      fontWeight: FontWeight.normal,
                                      fontSize: 18,
                                      letterSpacing: -0.2,
                                      color: LushTheme.darkerText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              width: 38,
                              child: InkWell(
                                highlightColor: Colors.transparent,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(32.0)),
                                onTap: () {},
                                child: const Center(
                                  child: Icon(
                                    Icons.keyboard_arrow_right,
                                    color: LushTheme.grey,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          },
        )
      ],
    );
  }
}

class _JuicesView extends StatelessWidget {
  _JuicesView({this.JuiceListData, this.animationController, this.animation});

  final Juice? JuiceListData;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final Product p = Product(
      "Juice Name", "Tangy Tangerine", "Rs.129", "assets/ABC.png", 4,
      bgColor: LushTheme.dark_grey, nameColor: LushTheme.dark_grey);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 100 * (1.0 - animation!.value), 0.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, DetailPage.routeName,
                    arguments: DetailScreenArguments(p));
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height / 4 > 165
                    ? MediaQuery.of(context).size.height / 5
                    : 165,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 32, left: 2, right: 2, bottom: 2),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: HexColor(JuiceListData!.endColor)
                                    .withOpacity(0.6),
                                offset: const Offset(1, 4.0),
                                blurRadius: 8.0),
                          ],
                          gradient: LinearGradient(
                            colors: <HexColor>[
                              HexColor(JuiceListData!.startColor),
                              HexColor(JuiceListData!.endColor),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(22.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(69.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 52.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 3,
                                child: Text(
                                  JuiceListData!.titleTxt,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: LushTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    letterSpacing: 0.2,
                                    color: LushTheme.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text(
                                      JuiceListData!.meals!.join('\n'),
                                      style: const TextStyle(
                                        fontFamily: LushTheme.fontName,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        letterSpacing: 0.2,
                                        color: LushTheme.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Column(
                              children: [
                                SizedBox(
                                    height: MediaQuery.of(context).size.height /
                                        13),
                                PopupMenuButton<int>(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 1,
                                      child: Text("Buy Now @Rs.129/-"),
                                    ),
                                    const PopupMenuItem(
                                      value: 2,
                                      child: Text("Subscribe @Rs.79/-"),
                                    ),
                                  ],
                                  initialValue: 2,
                                  onCanceled: () {
                                    print("You have canceled the menu.");
                                  },
                                  onSelected: (value) {
                                    print("value:$value");
                                  },
                                  icon: const Icon(Icons.add_shopping_cart),
                                ),
                              ],
                            )
                            // Column(
                            //   mainAxisAlignment: MainAxisAlignment.end,
                            //   children: [
                            //     Container(
                            //       decoration: BoxDecoration(
                            //         color: LushTheme.nearlyWhite,
                            //         shape: BoxShape.circle,
                            //         boxShadow: <BoxShadow>[
                            //           BoxShadow(
                            //               color: LushTheme.nearlyBlack
                            //                   .withOpacity(0.4),
                            //               offset: const Offset(8.0, 8.0),
                            //               blurRadius: 8.0),
                            //         ],
                            //       ),
                            //       child: IconButton(
                            //         icon: const Icon(Icons.add_shopping_cart),
                            //         color:
                            //         HexColor(JuiceListData!.endColor), onPressed: () {  },
                            //       ),
                            //     ),
                            //     Container(
                            //       decoration: BoxDecoration(
                            //         color: LushTheme.nearlyWhite,
                            //         shape: BoxShape.circle,
                            //         boxShadow: <BoxShadow>[
                            //           BoxShadow(
                            //               color: LushTheme.nearlyBlack
                            //                   .withOpacity(0.4),
                            //               offset: const Offset(8.0, 8.0),
                            //               blurRadius: 8.0),
                            //         ],
                            //       ),
                            //       child: IconButton(
                            //         icon: const Icon(Icons.subscriptions_sharp),
                            //         color:
                            //         HexColor(JuiceListData!.endColor), onPressed: () {  },
                            //       ),
                            //     ),
                            //   ],
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 16,
                      child: Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: LushTheme.nearlyWhite.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 20,
                      child: SizedBox(
                        width: 75,
                        height: 75,
                        child: Image.asset(JuiceListData!.imagePath),
                      ),
                    )
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
