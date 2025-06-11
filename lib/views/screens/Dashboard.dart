import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/UserRepository/userRepository.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/getIt.dart';
import 'package:lush/main.dart';
import 'package:lush/views/models/JuiceListView.dart';
import 'package:lush/views/models/user.dart';
import 'package:toggle_switch/toggle_switch.dart';
import '../models/SubcriptionView.dart';
import '../models/title_view.dart';
import '../../theme.dart';
import 'package:url_launcher/url_launcher.dart';

class Dashboard extends StatefulWidget {
  final UserRepository userRepository = getIt.get();

  Dashboard({super.key});

  @override
  HomePage2State createState() => HomePage2State();
}

class HomePage2State extends State<Dashboard> with TickerProviderStateMixin {
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
        onTap: () async {
          Map<String, String> urls =
              await widget.userRepository.getSubscriptionPageUrl();
          mounted
              ? Navigator.pushNamed(context, '/subscriptions',
                  arguments: SubscriptionPageUrlArgument(
                      premium_page_url: urls["premium"]!,
                      signature_page_url: urls["signature"]!,
                      delight_page_url: urls["delight"]!))
              : Future.delayed(Duration(seconds: 1));
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 19.0),
          child: TitleView(
            titleTxt: 'My subscriptions',
            subTxt: 'All plans',
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
    listViews.add(
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: ToggleSwitch(
          borderColor: [Colors.black45],
          borderWidth: 2.0,
          fontSize: 14.0,
          customWidths: [110, 110, 110],
          dividerColor: Colors.orangeAccent,
          centerText: true,
          dividerMargin: 10.0,
          animate: true,
          animationDuration: 300,
          cornerRadius: 20.0,
          activeBgColor: [Colors.orange.shade400],
          activeFgColor: Colors.black,
          inactiveBgColor: Colors.grey[300],
          initialLabelIndex: 0,
          totalSwitches: 3,
          labels: const ['Premium', 'Signature', 'Delight'],
          onToggle: (index) {
            switch (index) {
              case 0:
                // _controller.loadRequest(Uri.parse(
                //     'https://www.example.com/subscription/premium'));
                break;
              case 1:
                // _controller.loadRequest(Uri.parse(
                //     'https://www.example.com/subscription/signature'));
                break;
              case 2:
                // _controller.loadRequest(Uri.parse(
                //     'https://www.example.com/subscription/delight'));
                break;
            }
            // if (index == 0) {
            //   _controller.loadRequest(Uri.parse(
            //       'https://www.example.com/subscription/monthly'));
            // } else {
            //   _controller.loadRequest(Uri.parse(
            //       'https://www.example.com/subscription/yearly'));
            // }
          },
        ),
      ),
    );
    // listViews.add(
    //   MediterranesnDietView(
    //     animation: Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
    //         parent: widget.animationController!,
    //         curve:F
    //         Interval((1 / count) * 1, 1.0, curve: Curves.fastOutSlowIn))),
    //     animationController: widget.animationController!,
    //   ),
    // );
    // listViews.add(
    //   InkWell(
    //     onTap: () {
    //       Navigator.pushNamed(context, '/menu');
    //     },
    //     child: TitleView(
    //       titleTxt: 'Menu',
    //       subTxt: 'All options',
    //       animation: Tween<double>(begin: 0.0, end: 1.0).animate(
    //           CurvedAnimation(
    //               parent: animationController,
    //               curve: const Interval((1 / count) * 2, 1.0,
    //                   curve: Curves.fastOutSlowIn))),
    //       animationController: animationController,
    //     ),
    //   ),
    // );

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
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          return Container(
            color: LushTheme.background,
            child: Scaffold(
              bottomNavigationBar: buildBottomNavigationBar(),
              drawer: buildDrawer(widget.userRepository.user),
              backgroundColor: Colors.transparent,
              appBar: getAppBarUI(),
              body: Stack(
                children: <Widget>[
                  // Image.asset(
                  //   'assets/ABC.png',
                  //   fit: BoxFit.fill,
                  // ),

                  getMainListViewUI(),

                  // Expanded(child: getMainListViewUI()),
                  // SizedBox(
                  //   height: MediaQuery.of(context).padding.bottom,
                  // )
                ],
              ),
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
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
              top: MediaQuery.of(context).padding.top,
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

  AppBar getAppBarUI() {
    return AppBar(
      backgroundColor: Colors.orangeAccent,
      elevation: 4,
      title: SizedBox(
        height: 40,
        child: Image.asset(
          'assets/bmjlogo.png', // Make sure this path is correct
          fit: BoxFit.contain,
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
    );
  }

  Widget buildDrawer(User user) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.orangeAccent,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child:
                      Icon(Icons.person, size: 40, color: Colors.orangeAccent),
                ),
                const SizedBox(height: 10),
                Text(
                  user.getFirstName.toString().length +
                              user.getLastName.toString().length >
                          8
                      ? "Welcome ${user.getFirstName}!"
                      : "Welcome ${user.getFirstName} ${user.getLastName}!",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user.getPhone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home, color: Colors.orangeAccent),
            title: const Text("My Account"),
            onTap: () async {
              String selfServePageUrl =
                  await widget.userRepository.getSelfServePageUrl();
              Navigator.pushNamed(context, '/myaccount',
                  arguments: selfServePageUrl);
              // Navigator.pop(context);
            },
          ),
          ListTile(
            leading:
                const Icon(Icons.subscriptions, color: Colors.orangeAccent),
            title: const Text("Subscriptions"),
            onTap: () {
              Navigator.pushNamed(context, '/subscriptions');
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.orangeAccent),
            title: const Text("Menu"),
            onTap: () {
              Navigator.pushNamed(context, '/menu');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.orangeAccent),
            title: const Text("Settings"),
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text("Logout"),
            onTap: () {
              // Navigator.pushNamed(context, '/login');
              BlocProvider.of<AuthenticationBloc>(context).add(LogOut());
            },
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.subscriptions),
          label: 'Subscriptions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.menu),
          label: 'Menu',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.help_sharp),
          label: 'Help',
        ),
      ],
      currentIndex: 0,
      selectedItemColor: Colors.orange[400],
      unselectedItemColor: Colors.grey,
      onTap: (index) async {
        // Handle bottom navigation tap
        if (index == 0) {
          Navigator.pushNamed(context, '/home');
        } else if (index == 1) {
          Navigator.pushNamed(context, '/subscriptions');
        } else if (index == 2) {
          Navigator.pushNamed(context, '/menu');
        } else if (index == 3) {
           final user=context.read<AuthenticationBloc>().userRepository.user;
           final String phoneNumber = '6397033207';
           final String message = 
            'Hello, I need help with my account. \n'
            'Customer ID: ${user.id}\n'
            'Name: ${user.firstName} ${user.lastName}\n'
            'Phone: ${user.phone}\n'
            'Email: ${user.email}';

          final Uri whatsappUrl = Uri.parse(
            "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}",
          );
          if (await canLaunchUrl(whatsappUrl)) {
            await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
          } else {
            debugPrint("Could not launch WhatsApp");
          }
        }
      },
    );
  }
}
