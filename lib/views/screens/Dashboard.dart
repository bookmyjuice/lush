import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/get_it.dart';
// import 'package:lush/main.dart';
import 'package:lush/services/subscription_service.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/views/widgets/shimmer_subscription_card.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/cart_icon.dart';
import '../widgets/my_bottles_widget.dart';
import '../widgets/subscription_info_card.dart';


/// Defines the display mode of the Dashboard.
///
/// - [full]: Shows all user-specific content (subscriptions, profile drawer, cart).
/// - [public]: Shows public content only (promotions, plans, login prompts).
enum DashboardMode { full, public }

class Dashboard extends StatefulWidget {
  final UserRepository userRepository = getIt.get();
  final DashboardMode mode;
  final String? toastHeading;
  final String? toastMessage;

  Dashboard({
    super.key,
    this.mode = DashboardMode.full,
    this.toastHeading,
    this.toastMessage,
  });


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

  // Subscription data (v1 — injected via get_it, per docs/subscription_service_map.md)
  final SubscriptionService _subscriptionService = getIt.get<SubscriptionService>();
  Map<String, dynamic>? _subscription;
  bool _isLoadingSubscription = false;

  // Track current carousel index
  int _currentCarouselIndex = 0;

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

    // Load subscription data
    _loadSubscriptionData();

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

    // Show toast if widget has toastHeading/toastMessage (from AuthWrapper)
    if (widget.toastHeading != null && widget.toastMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          toastification.show(
            context: context,
            title: Text(widget.toastHeading!,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            description: Text(widget.toastMessage!),
            type: ToastificationType.info,
            style: ToastificationStyle.flatColored,
            autoCloseDuration: const Duration(seconds: 4),
            icon: const Icon(Icons.notifications_active,
                color: AppColors.primaryOrange),
            primaryColor: AppColors.primaryOrange,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.lightTextPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
            showProgressBar: true,
            closeOnClick: true,
          );
        }
      });
    }

    super.initState();
  }


  // Load subscription data from backend (v1 — token handled by SecureStorageService internally)
  Future<void> _loadSubscriptionData() async {
    setState(() {
      _isLoadingSubscription = true;
    });

    try {
      final subscriptions =
          await _subscriptionService.getMySubscriptions();
      setState(() {
        _subscription = subscriptions.isNotEmpty ? subscriptions.first : null;
        _isLoadingSubscription = false;
      });
    } catch (e) {
      print('Error loading subscription data: $e');
      setState(() {
        _subscription = null;
        _isLoadingSubscription = false;
      });
    }
  }

  void _navigateToSubscriptions() {
    if (mounted) {
      Navigator.pushNamed(context, '/subscription-family');
    }
  }

  void addAllListData() {
    listViews.clear();

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
                          '🍊 Featured Offers',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.lightTextPrimary,
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
                                          ? AppColors.primaryOrange
                                          : AppColors.grey,
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
                        AppColors.secondaryTeal,
                        Icons.local_offer,
                      ),
                      _buildPromotionCard(
                        'Healthy Combo',
                        'Buy any 3 juices and get 1 free',
                        'Limited time offer',
                        AppColors.success,
                        Icons.shopping_basket,
                      ),
                      _buildPromotionCard(
                        'Free Delivery',
                        'On all orders above ₹500',
                        'No coupon needed',
                        AppColors.info,
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
                child: _isLoadingSubscription
                    ? const ShimmerSubscriptionCard()
                    : SubscriptionInfoCard(
                        subscription: _subscription,
                        onTap: () {
                          if (_subscription != null) {
                            // Navigate to details
                          }
                        },
                        onManageTap: () async {
                          // BUG-007 FIX: Navigate to native subscription management
                          if (mounted) {
                            Navigator.pushNamed(context, '/manage-subscriptions');
                          }
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
                                AppColors.primaryOrange
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            '✨ Choose Your Experience',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        Container(
                          width: 30.w,
                          height: 3.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryOrange,
                                Colors.transparent
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
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
                                  AppColors.primaryOrange,
                                  AppColors.gradientEnd,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.primaryOrange.withValues(alpha: 0.4),
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
                                    color:
                                        Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.shopping_cart_outlined,
                                    color: AppColors.white,
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'One-Time',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'order',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Browse & buy juices instantly',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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
                                  AppColors.secondaryTeal,
                                  AppColors.gradientStart,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      AppColors.secondaryTeal.withValues(alpha: 0.4),
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
                                    color:
                                        Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Icon(
                                    Icons.auto_awesome_outlined,
                                    color: AppColors.white,
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'subscription',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  'Plans',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  'Regular delivery, better prices',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.white.withValues(alpha: 0.9),
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

  /// Shows a login prompt bottom sheet for unauthenticated users.
  void _showLoginPrompt(BuildContext context) {
    showModalBottomSheet<dynamic>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 24.h),
            Icon(
              Icons.local_cafe_outlined,
              size: 64.sp,
              color: AppColors.primaryOrange,
            ),
            SizedBox(height: 16.h),
            Text(
                      '🧃 Welcome to BookMyJuice!',
              style: AppTextStyles.textTheme.titleLarge?.copyWith(
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Sign in or create an account to start ordering fresh juices.',
              textAlign: TextAlign.center,
              style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                color: AppColors.lightTextSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: AppColors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Sign In / Sign Up',
                  style: AppTextStyles.textTheme.labelLarge?.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Continue browsing',
                style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ),
            SizedBox(height: 8.h),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode == DashboardMode.public) {
      return Container(
        color: AppColors.lightBackground,
        child: Scaffold(
          bottomNavigationBar: buildBottomNavigationBarPublic(),
          backgroundColor: Colors.transparent,
          appBar: getAppBarUIPublic(),
          body: Stack(
            children: <Widget>[
              getMainListViewUI(),
            ],
          ),
        ),
      );
    }

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        if (state is AuthenticationSuccess) {
          return Container(
            color: AppColors.lightBackground,
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
          return const Center(child: CircularProgressIndicator());
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
                      AlwaysStoppedAnimation<Color>(AppColors.primaryOrange),
                ),
                SizedBox(height: 16.h),
                Text(
                  '🍹 Loading your fresh juices...',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          );
        } else {
          return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  listViews.clear();
                  addAllListData();
                });
                animationController.reset();
                animationController.forward();
              },
              color: AppColors.primaryOrange,
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

  /// Public mode AppBar with login button
  AppBar getAppBarUIPublic() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: topBarOpacity * 4.0,
      shadowColor: AppColors.grey,
      centerTitle: true,
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: topBarOpacity,
        child: Text(
          'BookMyJuice',
          style: AppTextStyles.textTheme.titleLarge?.copyWith(
            color: AppColors.primaryOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        TextButton.icon(
          onPressed: () => _showLoginPrompt(context),
          icon:
              Icon(Icons.login, color: AppColors.primaryOrange, size: 18.sp),
          label: Text(
            'Login',
            style: AppTextStyles.textTheme.labelLarge?.copyWith(
              color: AppColors.primaryOrange,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(topBarOpacity > 0.6 ? 1.0 : 0.0),
        child: topBarOpacity > 0.6
            ? Container(
                height: 1.0,
                color: AppColors.grey,
              )
            : Container(),
      ),
      automaticallyImplyLeading: false,
    );
  }

  /// Public mode bottom nav with login prompt on auth-gated tabs
  Widget buildBottomNavigationBarPublic() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey,
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
                onTap: () => Navigator.pushNamed(context, '/subscription-family'),
              ),
              _buildNavItem(
                icon: Icons.menu_book_rounded,
                label: 'menu',
                isSelected: false,
                onTap: () => Navigator.pushNamed(context, '/menu'),
              ),
              _buildNavItem(
                icon: Icons.account_circle_rounded,
                label: 'Account',
                isSelected: false,
                onTap: () => _showLoginPrompt(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Enhanced AppBar with better visual design and user experience
  AppBar getAppBarUI() {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: topBarOpacity * 4.0,
      shadowColor: AppColors.grey,
      titleSpacing: 0,
      title: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: topBarOpacity,
        child: Text(
          '🧃 BookMyJuice',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryOrange,
          ),
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: IconButton(
            icon: Icon(
              Icons.menu_rounded,
              color: AppColors.primaryOrange,
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
                iconColor: AppColors.primaryOrange,
                backgroundColor: AppColors.primaryOrange.withValues(alpha: 0.1),
              ),
              SizedBox(width: 8.w),
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert,
                    color: AppColors.primaryOrange, size: 22.sp),
                onSelected: (value) {
                  switch (value) {
                    case 'subscriptions':
                      Navigator.pushNamed(context, '/manage-subscriptions');
                      break;
                    case 'orders':
                      Navigator.pushNamed(context, '/order-history');
                      break;
                    case 'invoices':
                      Navigator.pushNamed(context, '/invoices');
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'subscriptions',
                    child: Text('Manage Subscriptions'),
                  ),
                  const PopupMenuItem(
                    value: 'orders',
                    child: Text('Order History'),
                  ),
                  const PopupMenuItem(
                    value: 'invoices',
                    child: Text('View Invoices'),
                  ),
                ],
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
                color: AppColors.grey,
              )
            : Container(),
      ),
      automaticallyImplyLeading: false,
    );
  }

  // Enhanced drawer with better visual design and user experience
  Widget buildDrawer(User user) {
    return Drawer(
      backgroundColor: AppColors.white,
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
                  AppColors.primaryOrange,
                  AppColors.gradientEnd,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryOrange.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.nearlyBlack.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 40.r,
                    backgroundColor: AppColors.white,
                    child: Text(
                      user.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  '🍊 ${user.getFirstName} ${user.getLastName}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                    shadows: [
                      Shadow(
                        color: AppColors.nearlyBlack.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Logged in as ${user.getEmail}",
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.phone_android,
                      size: 16.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      user.getPhone,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        size: 14.sp,
                        color: AppColors.primaryOrange,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'Premium Member',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 8.h),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'ACCOUNT',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary,
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
              if (!context.mounted) return;
              Navigator.pushNamed(context, '/myaccount',
                  arguments: selfServePageUrl);
            },
          ),

          _buildDrawerItem(
            icon: Icons.subscriptions_outlined,
            title: "Subscriptions",
            subtitle: "Manage your plans",
            onTap: () {
              // BUG-007 FIX: Redirect to native subscription management screen
              // instead of deprecated Chargebee hosted pricing pages.
              Navigator.pushNamed(context, '/manage-subscriptions');
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

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'SHOPPING',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),

          _buildDrawerItem(
            icon: Icons.restaurant_menu_outlined,
            title: "menu",
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

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'PREFERENCES',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary,
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
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Text(
              'BOTTLES',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary,
                letterSpacing: 1.2,
              ),
            ),
          ),

          _buildDrawerItem(
            icon: Icons.recycling,
            title: "My Bottles",
            subtitle: "Track reusable bottles",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => const MyBottlesScreen(),
                ),
              );
            },
          ),

          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Divider(color: AppColors.grey),
          ),

          _buildDrawerItem(
            icon: Icons.logout,
            title: "Logout",
            subtitle: "Sign out",
            onTap: () {
              showDialog<bool?>(
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
                        backgroundColor: AppColors.error,
                        foregroundColor: AppColors.white,
                      ),
                      child: Text('LOGOUT'),
                    ),
                  ],
                ),
              );
            },
            iconColor: AppColors.error,
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
                        ? AppColors.error.withValues(alpha: 0.1)
                        : AppColors.primaryOrange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    icon,
                    size: 20.sp,
                    color: iconColor ??
                        (isDestructive ? AppColors.error : AppColors.primaryOrange),
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
                          color: isDestructive
                              ? AppColors.error
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16.sp,
                  color: AppColors.lightTextSecondary,
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

  Widget _buildPromotionCard(String title, String description,
      String subtitle, Color color, IconData icon) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
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
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
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
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: () {
                      if (title == 'Special Offer') {
                        _navigateToSubscriptions();
                      } else {
                        Navigator.pushNamed(context, '/menu');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.white,
                      foregroundColor: color,
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 0),
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
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.grey,
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
                  onTap: () => Navigator.pushNamed(context, '/subscription-family'),
                ),
              _buildNavItem(
                icon: Icons.menu_book_rounded,
                label: 'menu',
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
                  const String phoneNumber = '+919650606820';
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
              ? AppColors.primaryOrange.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryOrange : AppColors.grey,
              size: 24.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryOrange : AppColors.grey,
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
