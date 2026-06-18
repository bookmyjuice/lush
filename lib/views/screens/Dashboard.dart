/// Glassmorphism Dashboard Shell
///
/// Preserves all existing Bloc wiring — only UI/UX changes.
/// Contains the glass top bar, IndexedStack with 4 tabs, and glass bottom nav.
library;

import 'dart:ui';

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
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/screens/home_tab.dart';
import 'package:lush/views/screens/menu_tab.dart';
import 'package:lush/views/screens/orders_tab.dart';
import 'package:lush/views/screens/profile_tab.dart';
import 'package:lush/widgets/cart_badge_icon.dart';

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

    // Show toast notification if provided by widget parent
    if (widget.toastHeading != null || widget.toastMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${widget.toastHeading ?? ''} ${widget.toastMessage ?? ''}'.trim(),
              ),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final bgColor = isDark ? AppColors.glassBg : AppColors.glassBgLight;

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final isAuth = state is AuthenticationSuccess;
        final user = state is AuthenticationSuccess ? state.user : null;
        return Scaffold(
          extendBody: true,
          backgroundColor: bgColor,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.h),
            child: _buildTopBar(isDark),
          ),
          body: IndexedStack(
            index: _navIndex,
            children: [
              HomeTab(
                isAuth: isAuth,
                user: user,
                onNavigateToMenu: (i) => setState(() => _navIndex = i),
              ),
              const MenuTab(),
              OrdersTab(isAuth: isAuth),
              ProfileTab(
                isAuth: isAuth,
                user: user,
                onNavigateToOrders: () => setState(() => _navIndex = 2),
              ),
            ],
          ),
          bottomNavigationBar: _buildGlassNav(isDark),
        );
      },
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Container(
      padding: EdgeInsets.only(top: 48.h, left: 20.w, right: 12.w, bottom: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF0A0F0D), const Color(0xFF0F1613)]
              : [const Color(0xFFE8F5E9), const Color(0xFFF0F5F2)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.eco, color: AppColors.primaryGreen, size: 28.sp),
          SizedBox(width: 8.w),
          Text(
            'BookMyJuice',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const Spacer(),
          const CartBadgeIcon(),
        ],
      ),
    );
  }

  Widget _buildGlassNav(bool isDark) {
    final navBg = isDark ? AppColors.glassElevated : AppColors.glassElevatedLight;
    final borderColor = isDark ? AppColors.glassBorder : AppColors.glassBorderLight;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: borderColor),
        gradient: LinearGradient(
          colors: [navBg.withValues(alpha: 0.85), navBg.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: NavigationBar(
            selectedIndex: _navIndex,
            onDestinationSelected: (i) => setState(() => _navIndex = i),
            backgroundColor: Colors.transparent,
            indicatorColor: isDark
                ? AppColors.glassAccent.withValues(alpha: 0.2)
                : const Color(0xFFE8F5E9),
            elevation: 0,
            shadowColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            height: 64.h,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: ExcludeSemantics(
                  child: Semantics(
                    label: 'home_tab',
                    button: true,
                    container: true,
                    child: Icon(Icons.home_outlined,
                        color: isDark ? AppColors.glassTextDim : Colors.grey,),
                  ),
                ),
                selectedIcon: ExcludeSemantics(
                  child: Semantics(
                    label: 'home_tab',
                    button: true,
                    container: true,
                    child: const Icon(Icons.home, color: AppColors.primaryGreen),
                  ),
                ),
                label: 'Home',
              ),
              NavigationDestination(
                icon: ExcludeSemantics(
                  child: Semantics(
                    label: 'catalog_tab',
                    button: true,
                    container: true,
                    child: Icon(Icons.local_drink_outlined,
                        color: isDark ? AppColors.glassTextDim : Colors.grey,),
                  ),
                ),
                selectedIcon: ExcludeSemantics(
                  child: Semantics(
                    label: 'catalog_tab',
                    button: true,
                    container: true,
                    child: const Icon(Icons.local_drink, color: AppColors.primaryGreen),
                  ),
                ),
                label: 'Catalog',
              ),
              NavigationDestination(
                icon: ExcludeSemantics(
                  child: Semantics(
                    label: 'subscription_tab',
                    button: true,
                    container: true,
                    child: Icon(Icons.receipt_long_outlined,
                        color: isDark ? AppColors.glassTextDim : Colors.grey,),
                  ),
                ),
                selectedIcon: ExcludeSemantics(
                  child: Semantics(
                    label: 'subscription_tab',
                    button: true,
                    container: true,
                    child: const Icon(Icons.receipt_long, color: AppColors.primaryGreen),
                  ),
                ),
                label: 'Subscription',
              ),
              NavigationDestination(
                icon: ExcludeSemantics(
                  child: Semantics(
                    label: 'profile_tab',
                    button: true,
                    container: true,
                    child: Icon(Icons.person_outline,
                        color: isDark ? AppColors.glassTextDim : Colors.grey,),
                  ),
                ),
                selectedIcon: ExcludeSemantics(
                  child: Semantics(
                    label: 'profile_tab',
                    button: true,
                    container: true,
                    child: const Icon(Icons.person, color: AppColors.primaryGreen),
                  ),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}