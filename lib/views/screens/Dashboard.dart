import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/bloc/CartBloc/cart_bloc.dart';
import 'package:lush/bloc/CartBloc/cart_event.dart';
import 'package:lush/bloc/ProductCatalogBloc/product_catalog_bloc.dart';
import 'package:lush/bloc/SubscriptionBloc/subscription_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_bloc.dart';
import 'package:lush/bloc/OrderBloc/order_event.dart';
import 'package:lush/bloc/OrderBloc/order_state.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/views/screens/product_catalog_screen.dart';
import 'package:lush/views/screens/order/order_history_screen.dart';
import 'package:lush/views/screens/my_account_page.dart';
import 'package:lush/widgets/app_drawer.dart';
import 'package:lush/widgets/subscription_card.dart';
import 'package:lush/widgets/stats_strip.dart';

/// Dashboard mode enum
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

class HomePage2State extends State<Dashboard> {
  int _navIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load all data needed by dashboard tabs
    context.read<CartBloc>().add(LoadCart());
    context.read<ProductCatalogBloc>().add(const LoadProductCatalog());
    context.read<SubscriptionBloc>().add(const LoadActiveSubscriptions());
    // OrderBloc is created locally by OrderHistoryScreen — not globally provided
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final isAuth = state is AuthenticationSuccess;
        final user = state is AuthenticationSuccess ? state.user : null;
        return Scaffold(
          drawer: isAuth ? AppDrawer(user: user!, userRepository: widget.userRepository) : null,
          appBar: AppBar(
            title: const Text('🧃 BookMyJuice',
                style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: IndexedStack(
            index: _navIndex,
            children: [
              _buildHomeTab(isAuth, user),
              const ProductCatalogScreen(),
              isAuth ? const OrderHistoryScreen() : const Center(child: Text('Sign in to view orders')),
              isAuth ? _buildProfileTab(user!) : const Center(child: Text('Sign in to view profile')),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _navIndex,
            onDestinationSelected: (i) => setState(() => _navIndex = i),
            backgroundColor: Colors.white,
            indicatorColor: const Color(0xFFE8F5E9),
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: Color(0xFF2E7D32)),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.local_drink_outlined),
                selectedIcon: Icon(Icons.local_drink, color: Color(0xFF2E7D32)),
                label: 'Menu',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long, color: Color(0xFF2E7D32)),
                label: 'Orders',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person, color: Color(0xFF2E7D32)),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHomeTab(bool isAuth, User? user) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        children: [
          // Hero Header
          Container(
            height: 160.h,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 40.h, 12.w, 0),
            child: Text(
              isAuth && user != null
                  ? 'Good morning, ${user.firstName} 👋'
                  : 'Welcome to BookMyJuice!',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 22.sp,
                  fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          // Subscription card
          BlocBuilder<SubscriptionBloc, SubscriptionState>(
            builder: (context, subState) {
              String planName = '';
              bool isActive = false;
              String nextDelivery = '';

              if (subState is SubscriptionLoaded) {
                planName = subState.subscription.plan.name;
                isActive = subState.subscription.isActive;
                nextDelivery = subState.subscription.nextDeliveryDate != null
                    ? 'Tomorrow, 7-9 AM'
                    : '';
              }

              return SubscriptionCard(
                planName: planName.isNotEmpty ? planName : 'Premium Plan',
                isActive: isActive,
                nextDelivery: nextDelivery,
                onPause: () => Navigator.pushNamed(context, '/manage-subscriptions'),
                onModify: () => Navigator.pushNamed(context, '/manage-subscriptions'),
                onHistory: () => Navigator.pushNamed(context, '/order-history'),
              );
            },
          ),
          SizedBox(height: 8.h),
          // Stats strip (static for now — OrderBloc not globally provided)
          const StatsStrip(),
          SizedBox(height: 24.h),
          // Order Today section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text('Order Today',
                  style: TextStyle(fontFamily: 'Poppins', fontSize: 15.sp,
                      fontWeight: FontWeight.w600, color: Colors.grey)),
                const Spacer(),
                TextButton(
                  onPressed: () => setState(() => _navIndex = 1),
                  child: const Text('View Menu →'),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildProfileTab(User user) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40.r,
            backgroundColor: const Color(0xFF2E7D32),
            child: Text(
              user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : 'U',
              style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          SizedBox(height: 16.h),
          Text('${user.firstName} ${user.lastName}',
              style: TextStyle(fontFamily: 'Poppins', fontSize: 20.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 4.h),
          Text(user.email, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          SizedBox(height: 24.h),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            child: Column(children: [
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined, color: Color(0xFF2E7D32)),
                title: const Text('Order History'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => setState(() => _navIndex = 2),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.card_giftcard_outlined, color: Color(0xFF2E7D32)),
                title: const Text('Refer & Earn'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.pushNamed(context, '/referral'),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () => context.read<AuthenticationBloc>().add(LogOut()),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}