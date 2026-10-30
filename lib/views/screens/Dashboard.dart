/// BMJ dashboard shell (vibrant_zest).
///
/// Four tabs behind the glass header and the glass bottom nav. All BLoC wiring
/// from the previous shell is preserved - only the chrome changed, so tab state,
/// deep links and each tab's own refresh logic keep working.
library;

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
import 'package:lush/theme/bmj_tokens.dart';
import 'package:lush/views/screens/home_tab.dart';
import 'package:lush/views/screens/orders_tab.dart';
import 'package:lush/views/screens/profile_tab.dart';
import 'package:lush/views/screens/subscription_tab.dart';
import 'package:lush/widgets/bmj_glass_bottom_nav.dart';
import 'package:lush/widgets/bmj_glass_header.dart';

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

  /// Semantics labels are unchanged so the existing navigation contract holds.
  static const List<BMJNavDestination> _destinations = <BMJNavDestination>[
    BMJNavDestination(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      semanticLabel: 'home_tab',
    ),
    BMJNavDestination(
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long,
      label: 'Orders',
      semanticLabel: 'orders_tab',
    ),
    BMJNavDestination(
      icon: Icons.autorenew_outlined,
      selectedIcon: Icons.autorenew,
      label: 'Subscription',
      semanticLabel: 'subscription_tab',
    ),
    BMJNavDestination(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
      semanticLabel: 'profile_tab',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Load all data needed by dashboard tabs
    context.read<CartBloc>().add(LoadCart());
    context.read<ProductCatalogBloc>().add(const LoadProductCatalog());
    // DP-1: subscriptions are authenticated - do not call the endpoint while
    // signed out, otherwise the dashboard fires a guaranteed 401.
    final signedIn = getIt.get<UserRepository>().userLoggedIn;
    if (signedIn) {
      context.read<SubscriptionBloc>().add(const LoadActiveSubscriptions());
    }

    // Show toast notification if provided by widget parent
    if (widget.toastHeading != null || widget.toastMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "${widget.toastHeading ?? ''} ${widget.toastMessage ?? ''}"
                    .trim(),
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
    final palette = BMJPalette.of(context);

    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final isAuth = state is AuthenticationSuccess;
        final user = state is AuthenticationSuccess ? state.user : null;

        return Scaffold(
          extendBody: true,
          backgroundColor: palette.surface,
          body: Column(
            children: <Widget>[
              // Stitch puts a 48 dp round brand glyph in the header's left slot
              // (`w-12 h-12 rounded-full` with the bubble_chart symbol). It is the
              // same header, with the leading slot filled — not a Home variant.
              BMJGlassHeader(
                leading: Semantics(
                  button: true,
                  label: 'BookMyJuice home',
                  child: GestureDetector(
                    onTap: () => _selectTab(0),
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(
                        Icons.bubble_chart_outlined,
                        size: 22,
                        color: palette.primaryEmphasis,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: IndexedStack(
                  index: _navIndex,
                  children: <Widget>[
                    HomeTab(
                      isAuth: isAuth,
                      user: user,
                      onNavigateToMenu: (_) =>
                          Navigator.pushNamed(context, '/catalog'),
                    ),
                    OrdersTab(isAuth: isAuth),
                    const SubscriptionTab(),
                    ProfileTab(
                      isAuth: isAuth,
                      user: user,
                      onNavigateToOrders: () => _selectTab(1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: BMJGlassBottomNav(
            destinations: _destinations,
            index: _navIndex,
            onSelect: _selectTab,
          ),
        );
      },
    );
  }

  void _selectTab(int index) {
    if (index == _navIndex) return;
    setState(() => _navIndex = index);
  }
}
