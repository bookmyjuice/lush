import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import '../screens/detail.dart';
import '../../theme.dart';
import 'Juice.dart';
import 'model.dart';

class JuicesView extends StatelessWidget {
  JuicesView(
      {super.key,
      this.JuiceListData,
      this.animationController,
      this.animation});

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
                100 * (1.0 - animation!.value), 0.0, 0.0),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(context, DetailPage.routeName,
                    arguments: p);
              },
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2.6,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 42, left: 1, right: 5, bottom: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: HexColor(JuiceListData!.endColor)
                                    .withOpacity(0.6),
                                offset: const Offset(1.1, 4.0),
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
                            bottomRight: Radius.circular(8.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(69.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 50, left: 2, right: 2, bottom: 2),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                JuiceListData!.titleTxt,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: LushTheme.fontName,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                  color: LushTheme.white,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(top: 8, bottom: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        JuiceListData!.meals!.join('\n'),
                                        style: const TextStyle(
                                          fontFamily: LushTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 8,
                                          letterSpacing: 0.2,
                                          color: LushTheme.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Row(
                              //   mainAxisAlignment: MainAxisAlignment.center,
                              //   children: [
                              //     Container(
                              //       decoration: BoxDecoration(
                              //         backgroundBlendMode: BlendMode.luminosity,
                              //         color: HexColor(JuiceListData!.endColor),
                              //         shape: BoxShape.rectangle,
                              //         borderRadius: BorderRadius.circular(10.0),
                              //         border: Border.all(),
                              //         boxShadow: <BoxShadow>[
                              //           BoxShadow(
                              //               color: HexColor(
                              //                       JuiceListData!.startColor)
                              //                   .withOpacity(0.95),
                              //               offset: const Offset(0.0, 0.0),
                              //               blurRadius: 2.0),
                              //         ],
                              //       ),
                              //       child: IconButton(
                              //         color: Colors.black,
                              //         onPressed: () {},
                              //         icon: const Icon(Icons.add_shopping_cart,
                              //             size: 24),
                              //       ),
                              //     ),
                              //     Container(
                              //       decoration: BoxDecoration(
                              //         backgroundBlendMode: BlendMode.modulate,
                              //         borderRadius: BorderRadius.circular(39.0),
                              //         color:
                              //             HexColor(JuiceListData!.startColor),
                              //         shape: BoxShape.rectangle,
                              //         border: Border.all(),
                              //         boxShadow: <BoxShadow>[
                              //           BoxShadow(
                              //               color: HexColor(
                              //                       JuiceListData!.startColor)
                              //                   .withOpacity(0.95),
                              //               offset: const Offset(0.0, 0.0),
                              //               blurRadius: 1.0),
                              //         ],
                              //       ),
                              //       child: MaterialButton(
                              //         // fillColor: HexColor(JuiceListData!.startColor),
                              //         onPressed: () {},
                              //         child: Text("Subscribe!",
                              //             style: TextStyle(
                              //                 // backgroundColor: HexColor(JuiceListData!.endColor),
                              //                 fontSize: 12,
                              //                 color: Colors.black,
                              //                 fontWeight: FontWeight.w700,
                              //                 fontStyle: FontStyle.italic)),
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              PopupMenuButton<int>(
                                color: HexColor(JuiceListData!.startColor),
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
                                icon: const Icon(Icons.add_shopping_cart,
                                    color: Colors.white),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
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
                      left: 8,
                      child: SizedBox(
                        width: 80,
                        height: 80,
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
