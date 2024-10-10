import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:lush/main.dart';
import 'package:lush/theme.dart';
import 'package:no_context_navigation/no_context_navigation.dart';
import '../models/subscriptionPlan.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  SubscriptionState createState() => SubscriptionState();
}

class SubscriptionState extends State<Subscription>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  List<subscriptionPlan> subscriptionPlans = subscriptionPlan.tabIconsList;

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
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
        body: SafeArea(
      child: Container(
        decoration: const BoxDecoration(color: LushTheme.background),
        child: ListView.builder(
          padding: const EdgeInsets.all(6),
          itemCount: subscriptionPlans.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            final int count =
                subscriptionPlans.length > 10 ? 10 : subscriptionPlans.length;
            final Animation<double> animation =
                Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
                    parent: animationController,
                    curve: Interval((1 / count) * index, 1.0,
                        curve: Curves.fastOutSlowIn)));
            animationController.forward();
            return _SubscriptionPlanView(
              subscripPlan: subscriptionPlans[index],
              animation: animation,
              animationController: animationController,
            );
          },
        ),
      ),
    ));
  }
}

class _SubscriptionPlanView extends StatelessWidget {
  const _SubscriptionPlanView(
      {this.subscripPlan, this.animationController, this.animation});
  final subscriptionPlan? subscripPlan;
  final AnimationController? animationController;
  final Animation<double>? animation;

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
                // Navigator.pushNamed(context, DetailPage.routeName,
                //     arguments: DetailScreenArguments(p));
              },
              child: SizedBox(
                // width: 20,
                height: MediaQuery.of(context).size.height / 4 > 165
                    ? MediaQuery.of(context).size.height / 4
                    : 165,
                child: Stack(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: HexColor(subscripPlan!.endColor)
                                    .withOpacity(0.6),
                                offset: const Offset(1, 4.0),
                                blurRadius: 8.0),
                          ],
                          gradient: LinearGradient(
                            colors: <HexColor>[
                              HexColor(subscripPlan!.startColor),
                              HexColor(subscripPlan!.endColor),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(26.0),
                            bottomLeft: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0),
                            topRight: Radius.circular(69.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              // const Text("test", style: LushTheme.headline),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 7,
                                child: Text(
                                  subscripPlan!.titleTxt,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: LushTheme.fontName,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    letterSpacing: 0.2,
                                    color: LushTheme.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Text(
                                    subscripPlan!.text!.join('\n'),
                                    style: const TextStyle(
                                      fontFamily: LushTheme.fontName,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                      color: LushTheme.white,
                                    ),
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 0.0,
                                            top: 50.0,
                                            right: 0.0,
                                            bottom: 0.0),
                                        child: Text(
                                          'Rs.',
                                          style: TextStyle(
                                              fontFamily: LushTheme.fontName,
                                              fontWeight: FontWeight.w500,
                                              fontSize: 5,
                                              letterSpacing: 0.2,
                                              color: LushTheme.lightText,
                                              decoration:
                                                  TextDecoration.lineThrough),
                                        ),
                                      ),
                                      Text(
                                        subscripPlan!.price.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            fontFamily: LushTheme.fontName,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 12,
                                            letterSpacing: 0.2,
                                            color: LushTheme.lightText,
                                            decoration:
                                                TextDecoration.lineThrough),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      const Text(
                                        'Rs.',
                                        style: TextStyle(
                                          fontFamily: LushTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 10,
                                          letterSpacing: 0.2,
                                          color: LushTheme.white,
                                        ),
                                      ),
                                      Text(
                                        subscripPlan!.price.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontFamily: LushTheme.fontName,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 22,
                                          letterSpacing: 0.2,
                                          color: LushTheme.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  FloatingActionButton.extended(
                                    // key: UniqueKey(),
                                    onPressed: () {
                                      navService.pushNamed("/paymentRoute",
                                          args: PaymentScreenArguments(
                                              subscripPlan!.price,
                                              subscripPlan!.text!.first));
                                    },
                                    elevation: 20,
                                    backgroundColor: LushTheme.background,
                                    icon: const Icon(
                                        Icons.add_shopping_cart_outlined,
                                        size: 14,
                                        color: Colors.black45),
                                    label: const Text(
                                      "Buy Now!",
                                      style: LushTheme.subtitle,
                                    ),
                                    // child: const Text("Subscribe Now!",style: LushTheme.subscribeNow)
                                  ),
                                ],
                              )
                            ],
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
