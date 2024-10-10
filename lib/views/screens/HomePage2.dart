import 'package:flutter/material.dart';
import 'package:lush/views/models/JuiceListView.dart';
import '../models/SubcriptionView.dart';
import '../models/title_view.dart';
import '../../theme.dart';

class HomePage2 extends StatefulWidget {
  const HomePage2({super.key});

  @override
  HomePage2State createState() => HomePage2State();
}

class HomePage2State extends State<HomePage2> with TickerProviderStateMixin {
  late Animation<double> topBarAnimation;
  late AnimationController animationController;

  List<Widget> listViews = <Widget>[];
  final ScrollController scrollController = ScrollController();
  double topBarOpacity = 0.1;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    topBarAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: const Interval(0, 0.5, curve: Curves.fastOutSlowIn)));
    addAllListData();

    scrollController.addListener(() {
      if (scrollController.offset >= 24) {
        if (topBarOpacity != 1.0) {
          setState(() {
            topBarOpacity = 1.0;
          });
        }
      } else if (scrollController.offset <= 24 &&
          scrollController.offset >= 0) {
        if (topBarOpacity != scrollController.offset / 24) {
          setState(() {
            topBarOpacity = scrollController.offset / 24;
          });
        }
      } else if (scrollController.offset <= 0) {
        if (topBarOpacity != 0.0) {
          setState(() {
            topBarOpacity = 0.0;
          });
        }
      }
    });
    super.initState();
  }

  void addAllListData() {
    const int count = 9;
    listViews.add(
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/subscriptions');
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 19.0),
          child: TitleView(
            titleTxt: 'Subscriptions',
            subTxt: 'Plans',
            animation: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                    parent: animationController,
                    curve: const Interval((1 / count) * 2, 1.0,
                        curve: Curves.fastOutSlowIn))),
            animationController: animationController,
          ),
        ),
      ),
    );
    listViews.add(
      SubscriptionView(
        // titleTxt: 'Mediterranean diet',
        // subTxt: 'Details',
        animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
            parent: animationController,
            curve: const Interval((1 / count) * 0, 1.0,
                curve: Curves.fastOutSlowIn))),
        animationController: animationController,
      ),
    );
    // listViews.add(
    //   MediterranesnDietView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //         Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    listViews.add(
      InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/menu');
        },
        child: TitleView(
          titleTxt: 'All Juices',
          subTxt: 'Menu',
          animation: Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: animationController,
                  curve: const Interval((1 / count) * 2, 1.0,
                      curve: Curves.fastOutSlowIn))),
          animationController: animationController,
        ),
      ),
    );

    listViews.add(
      JuiceListView(
        mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(
                parent: animationController,
                curve: const Interval((1 / count) * 3, 1.0,
                    curve: Curves.fastOutSlowIn))),
        mainScreenAnimationController: animationController,
      ),
    );

    // listViews.add(
    //   TitleView(
    //     titleTxt: 'Body measurement',
    //     subTxt: 'Today',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //         Interval((1 / count) * 4, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );

    // listViews.add(
    //   BodyMeasurementView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //         Interval((1 / count) * 5, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    // listViews.add(
    //   TitleView(
    //     titleTxt: 'Water',
    //     subTxt: 'Aqua SmartBottle',
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:
    //         Interval((1 / count) * 6, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    //
    // listViews.add(
    //   WaterView(
    //     mainScreenAnimation: Tween<double>(begin: 0.0, end: 1.0).animate(
    //         CurvedAnimation(
    //             parent: widget.animationController!,
    //             curve: Interval((1 / count) * 7, 1.0,
    //                 curve: Curves.fastOutSlowIn))),
    //     mainScreenAnimationController: widget.animationController!,
    //   ),
    // );
    // listViews.add(
    //   GlassView(
    //       animation: Tween<double>(begin: 0.0, end: 1.0).animate(
    //           CurvedAnimation(
    //               parent: widget.animationController!,
    //               curve: Interval((1 / count) * 8, 1.0,
    //                   curve: Curves.fastOutSlowIn))),
    //       animationController: widget.animationController!),
    // );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 50));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: LushTheme.background,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: <Widget>[
            getAppBarUI(),
            getMainListViewUI(),
            // Expanded(child: getMainListViewUI()),
            // SizedBox(
            //   height: MediaQuery.of(context).padding.bottom,
            // )
          ],
        ),
      ),
    );
  }

  Widget getMainListViewUI() {
    return FutureBuilder<bool>(
      future: getData(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        } else {
          return ListView.builder(
            controller: scrollController,
            padding: EdgeInsets.only(
              top: AppBar().preferredSize.height +
                  MediaQuery.of(context).padding.top,
              bottom: 1 + MediaQuery.of(context).padding.bottom,
            ),
            itemCount: listViews.length,
            scrollDirection: Axis.vertical,
            itemBuilder: (BuildContext context, int index) {
              animationController.forward();
              return listViews[index];
            },
          );
        }
      },
    );
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
                    color: LushTheme.appbarColor.withOpacity(topBarOpacity),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32.0),
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                          color:
                              LushTheme.grey.withOpacity(0.25),
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
                                child:
                                // Text(
                                //   'My Juices',
                                //   textAlign: TextAlign.left,
                                //   style: TextStyle(
                                //     fontFamily: LushTheme.fontName,
                                //     fontWeight: FontWeight.w700,
                                //     fontSize: 10 + 6 - 6 * topBarOpacity,
                                //     letterSpacing: 1.2,
                                //     color: LushTheme.white,
                                //   ),
                                // )
                                SizedBox(
                                    height: 20,
                                    child: Image.asset('assets/lushlogo.png'))
                              ),
                            ),
                            // SizedBox(
                            //   height: 38,
                            //   width: 38,
                            //   child: InkWell(
                            //     highlightColor: Colors.transparent,
                            //     borderRadius: const BorderRadius.all(
                            //         Radius.circular(32.0)),
                            //     onTap: () {},
                            //     child: const Center(
                            //       child: Icon(
                            //         Icons.keyboard_arrow_left,
                            //         color: LushTheme.grey,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            // Padding(
                            //   padding: const EdgeInsets.only(
                            //     left: 8,
                            //     right: 8,
                            //   ),
                            //   child: Row(
                            //     children: const <Widget>[
                            //       Padding(
                            //         padding: EdgeInsets.only(right: 8),
                            //         child: Icon(
                            //           Icons.calendar_today,
                            //           color: LushTheme.grey,
                            //           size: 18,
                            //         ),
                            //       ),
                            //       Text(
                            //         '15 May',
                            //         textAlign: TextAlign.left,
                            //         style: TextStyle(
                            //           fontFamily: LushTheme.fontName,
                            //           fontWeight: FontWeight.normal,
                            //           fontSize: 18,
                            //           letterSpacing: -0.2,
                            //           color: LushTheme.darkerText,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),
                            // SizedBox(
                            //   height: 38,
                            //   width: 38,
                            //   child: InkWell(
                            //     highlightColor: Colors.transparent,
                            //     borderRadius: const BorderRadius.all(
                            //         Radius.circular(32.0)),
                            //     onTap: () {},
                            //     child: const Center(
                            //       child: Icon(
                            //         Icons.keyboard_arrow_right,
                            //         color: LushTheme.grey,
                            //       ),
                            //     ),
                            //   ),
                            // ),
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
