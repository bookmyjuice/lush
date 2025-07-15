import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/userRepository.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/bloc/CartBloc/CartBloc.dart';
import 'package:lush/bloc/CartBloc/cartEvent.dart';
import 'package:lush/getIt.dart';
import 'package:lush/main.dart';
import 'package:lush/views/models/user.dart';
import '../widgets/dashboard_components.dart';
import '../widgets/cart_icon.dart';
import '../../theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Dashboard extends StatefulWidget {
  final UserRepository userRepository = getIt.get();

  Dashboard({super.key});

  @override
  HomePage2State createState() => HomePage2State();
}

class HomePage2State extends State<Dashboard> with TickerProviderStateMixin {
  late Animation<double> topBarAnimation;
  late AnimationController animationController;
  late CarouselSliderController carouselController;

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
    carouselController = CarouselSliderController();
    addAllListData();

    // Load cart data
    context.read<CartBloc>().add(LoadCart());

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

  // Track current carousel index
  int _currentCarouselIndex = 0;

  void _navigateToSubscriptions() async {
    try {
      Map<String, String> urls =
          await widget.userRepository.getSubscriptionPageUrl();
      if (mounted) {
        Navigator.pushNamed(context, '/subscriptions',
            arguments: SubscriptionPageUrlArgument(
                premium_page_url: urls["premium"]!,
                signature_page_url: urls["signature"]!,
                delight_page_url: urls["delight"]!));
      }
    } catch (e) {
      // Handle error silently or show user-friendly message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Unable to load subscriptions. Please try again.')),
        );
      }
    }
  }

  void addAllListData() {
    listViews.clear(); // Clear previous views

    // Add Welcome Header with improved animation
    // listViews.add(
    //   Padding(
    //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
    //     child: AnimatedBuilder(
    //       animation: animationController,
    //       builder: (context, child) {
    //         return SlideTransition(
    //           position: Tween<Offset>(
    //             begin: const Offset(0, -0.5),
    //             end: Offset.zero,
    //           ).animate(CurvedAnimation(
    //             parent: animationController,
    //             curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic),
    //           )),
    //           child: FadeTransition(
    //             opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
    //               CurvedAnimation(
    //                 parent: animationController,
    //                 curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic),
    //               ),
    //             ),
    //             child: WelcomeHeader(user: widget.userRepository.user),
    //           ),
    //         );
    //       },
    //     ),
    //   ),
    // );

    // Add Featured Promotions Carousel
    listViews.add(
      Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animationController,
                  curve: const Interval(0.1, 0.3, curve: Curves.easeOutCubic),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      children: [
                        Text(
                          'Featured Offers',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: LushTheme.darkerText,
                            fontFamily: LushTheme.fontName,
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: List.generate(
                              3,
                              (index) => Container(
                                    width: 8.w,
                                    height: 8.w,
                                    margin: EdgeInsets.only(right: 4.w),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentCarouselIndex == index
                                          ? LushTheme.orangeAccent
                                          : LushTheme.grey.withOpacity(0.3),
                                    ),
                                  )),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12.h),
                  CarouselSlider(
                    carouselController: carouselController,
                    options: CarouselOptions(
                      height: 160.h,
                      viewportFraction: 0.92,
                      enlargeCenterPage: true,
                      enableInfiniteScroll: true,
                      autoPlay: true,
                      autoPlayInterval: const Duration(seconds: 5),
                      autoPlayAnimationDuration:
                          const Duration(milliseconds: 800),
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentCarouselIndex = index;
                        });
                      },
                    ),
                    items: [
                      _buildPromotionCard(
                        'Special Offer',
                        'Get 20% off on your first subscription',
                        'Use code: NEWJUICE20',
                        Colors.deepPurple,
                        Icons.local_offer,
                      ),
                      _buildPromotionCard(
                        'Healthy Combo',
                        'Buy any 3 juices and get 1 free',
                        'Limited time offer',
                        Colors.green,
                        Icons.shopping_basket,
                      ),
                      _buildPromotionCard(
                        'Free Delivery',
                        'On all orders above ₹500',
                        'No coupon needed',
                        Colors.blue,
                        Icons.delivery_dining,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    // Add Current Subscription Status with improved design
    listViews.add(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.5),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animationController,
                curve: const Interval(0.2, 0.4, curve: Curves.easeOutCubic),
              )),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animationController,
                    curve: const Interval(0.2, 0.4, curve: Curves.easeOutCubic),
                  ),
                ),
                child: SubscriptionCard(
                  title: 'Premium Plan',
                  subtitle: 'Daily fresh juice delivery',
                  status: 'Active',
                  nextDelivery: DateTime.now().add(Duration(days: 1)),
                  deliveriesLeft: 12,
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
                ),
              ),
            );
          },
        ),
      ),
    );

    // Add Fancy Navigation Cards
    listViews.add(
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: AnimatedBuilder(
          animation: animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: animationController,
                  curve: const Interval(0.3, 0.5, curve: Curves.easeOutCubic),
                ),
              ),
              child: Column(
                children: [
                  // Section Title
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 30.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                LushTheme.orangeAccent
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            'Choose Your Experience',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: LushTheme.darkerText,
                              fontFamily: LushTheme.fontName,
                            ),
                          ),
                        ),
                        Container(
                          width: 30.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                LushTheme.orangeAccent,
                                Colors.transparent
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Navigation Cards
                  Row(
                    children: [
                      // One-Time Order Card
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/menu');
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.only(right: 8.w),
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF667eea),
                                  Color(0xFF764ba2),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF667eea).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'One-Time',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Order',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Browse & buy juices instantly',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Subscription Plans Card
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            _navigateToSubscriptions();
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.only(left: 8.w),
                            padding: EdgeInsets.all(20.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF11998e),
                                  Color(0xFF38ef7d),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF11998e).withOpacity(0.4),
                                  blurRadius: 12,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome_outlined,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'Subscription',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Plans',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Regular delivery, better prices',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
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
                  getMainListViewUI(),
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(LushTheme.nearlyBlue),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Loading your fresh juices...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: LushTheme.lightText,
                  ),
                ),
              ],
            ),
          );
        } else {
          return RefreshIndicator(
              onRefresh: () async {
                // Add refresh logic here
                setState(() {
                  listViews.clear();
                  addAllListData();
                });
                animationController.reset();
                animationController.forward();
              },
              color: LushTheme.orangeAccent,
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.only(
                  top: 10.h,
                  bottom: 20.h + MediaQuery.of(context).padding.bottom,
                ),
                itemCount: listViews.length,
                scrollDirection: Axis.vertical,
                physics: const AlwaysScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) {
                  if (index == 0) {
                    animationController.forward();
                  }
                  return listViews[index];
                },
              ));
        }
      },
    );
  }

  // Enhanced AppBar with better visual design and user experience
  AppBar getAppBarUI() {
    return AppBar(
      backgroundColor: LushTheme.white,
      elevation: topBarOpacity * 4.0,
      shadowColor: LushTheme.grey.withOpacity(0.2),
      titleSpacing: 0,
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: topBarOpacity,
        child: Text(
          'BookMyJuice',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: LushTheme.nearlyBlue,
            fontFamily: LushTheme.fontName,
          ),
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: LushTheme.nearlyBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: LushTheme.nearlyBlue,
              size: 24.sp,
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
            iconSize: 24.sp,
          ),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.only(right: 16.w),
          child: Row(
            children: [
              CartIcon(
                onTap: () => _handleCartTap(context),
                iconColor: LushTheme.nearlyBlue,
                backgroundColor: LushTheme.nearlyBlue.withOpacity(0.1),
              ),
            ],
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(topBarOpacity > 0.6 ? 1.0 : 0.0),
        child: topBarOpacity > 0.6
            ? Container(
                height: 1.0,
                color: LushTheme.grey.withOpacity(0.2),
              )
            : Container(),
      ),
      automaticallyImplyLeading: false,
    );
  }

  // Enhanced drawer with better visual design and user experience
  Widget buildDrawer(User user) {
    return Drawer(
      backgroundColor: LushTheme.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // Enhanced header with gradient and user info
          Container(
            height: 280.h,
            padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  LushTheme.nearlyBlue,
                  Color(0xFF3F51B5),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: LushTheme.nearlyBlue.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                // Enhanced avatar with shadow
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundColor: LushTheme.white,
                    child: Text(
                      user.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: LushTheme.nearlyBlue,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                // User name with better formatting
                Text(
                  user.getFirstName.toString().length +
                              user.getLastName.toString().length >
                          8
                      ? "Welcome ${user.getFirstName}!"
                      : "Welcome ${user.getFirstName} ${user.getLastName}!",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: LushTheme.fontName,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 8.h),
                // User phone with icon
                Row(
                  children: [
                    Icon(
                      Icons.phone_android,
                      size: 16.sp,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      user.getPhone,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(0.9),
                        fontFamily: LushTheme.fontName,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                // Premium badge with enhanced design
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 14.sp,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Premium Member',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: LushTheme.fontName,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Enhanced menu items with better spacing and visual feedback
          SizedBox(height: 8.h),

          // Account section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'ACCOUNT',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: LushTheme.lightText,
                letterSpacing: 1.2,
              ),
            ),
          ),

          _buildDrawerItem(
            icon: Icons.account_circle_outlined,
            title: "My Account",
            subtitle: "Profile & settings",
            onTap: () async {
              String selfServePageUrl =
                  await widget.userRepository.getSelfServePageUrl();
              Navigator.pushNamed(context, '/myaccount',
                  arguments: selfServePageUrl);
            },
          ),

          _buildDrawerItem(
            icon: Icons.subscriptions_outlined,
            title: "Subscriptions",
            subtitle: "Manage your plans",
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
          ),

          _buildDrawerItem(
            icon: Icons.history,
            title: "Order History",
            subtitle: "Past orders",
            onTap: () {
              Navigator.pushNamed(context, '/orders');
            },
          ),

          // Shopping section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'SHOPPING',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: LushTheme.lightText,
                letterSpacing: 1.2,
              ),
            ),
          ),

          _buildDrawerItem(
            icon: Icons.restaurant_menu_outlined,
            title: "Menu",
            subtitle: "Browse juices",
            onTap: () {
              Navigator.pushNamed(context, '/menu');
            },
          ),

          _buildDrawerItem(
            icon: Icons.shopping_cart_outlined,
            title: "My Cart",
            subtitle: "Review & checkout",
            onTap: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),

          // Preferences section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: LushTheme.lightText,
                letterSpacing: 1.2,
              ),
            ),
          ),

          _buildDrawerItem(
            icon: Icons.notifications_outlined,
            title: "Notifications",
            subtitle: "Alerts & updates",
            onTap: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),

          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: "Settings",
            subtitle: "App preferences",
            onTap: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Divider(color: LushTheme.grey.withOpacity(0.3)),
          ),

          _buildDrawerItem(
            icon: Icons.logout,
            title: "Logout",
            subtitle: "Sign out",
            onTap: () {
              // Show confirmation dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(LogOut());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('LOGOUT'),
                    ),
                  ],
                ),
              );
            },
            iconColor: Colors.red,
            isDestructive: true,
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : LushTheme.nearlyBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: iconColor ??
                        (isDestructive ? Colors.red : LushTheme.nearlyBlue),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color:
                              isDestructive ? Colors.red : LushTheme.darkerText,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: LushTheme.lightText,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: LushTheme.lightText,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Handle cart button tap - Navigate to cart screen
  void _handleCartTap(BuildContext context) {
    Navigator.pushNamed(context, '/cart');
  }

  // Build promotion card for carousel
  Widget _buildPromotionCard(String title, String description, String subtitle,
      Color color, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              icon,
              size: 120.sp,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min, // Use minimum space needed
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle promotion action
                      if (title == 'Special Offer') {
                        // Navigate to subscription screen
                        _navigateToSubscriptions();
                      } else if (title == 'Healthy Combo') {
                        // Navigate to menu
                        Navigator.pushNamed(context, '/menu');
                      } else {
                        // Navigate to menu for all products
                        Navigator.pushNamed(context, '/menu');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: color,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Get Now',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced bottom navigation bar with visual feedback
  Widget buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: true,
                onTap: () => Navigator.pushNamed(context, '/home'),
              ),
              _buildNavItem(
                  icon: Icons.subscriptions_rounded,
                  label: 'Plans',
                  isSelected: false,
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
                  }),
              _buildNavItem(
                icon: Icons.menu_book_rounded,
                label: 'Menu',
                isSelected: false,
                onTap: () => Navigator.pushNamed(context, '/menu'),
              ),
              _buildNavItem(
                icon: Icons.help_rounded,
                label: 'Help',
                isSelected: false,
                onTap: () async {
                  final user =
                      context.read<AuthenticationBloc>().userRepository.user;
                  final String phoneNumber = '+919650606820';
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
                    await launchUrl(whatsappUrl,
                        mode: LaunchMode.externalApplication);
                  } else {
                    debugPrint("Could not launch WhatsApp");
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom navigation item with better visual feedback
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected
              ? LushTheme.orangeAccent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? LushTheme.orangeAccent : Colors.grey,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? LushTheme.orangeAccent : Colors.grey,
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
