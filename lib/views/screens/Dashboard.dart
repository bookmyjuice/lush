import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/widgets/app_drawer.dart';

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
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
      builder: (context, state) {
        final isAuth = state is AuthenticationSuccess;
        final user = state is AuthenticationSuccess ? state.user : null;
        return Scaffold(
          drawer: isAuth ? AppDrawer(user: user!, userRepository: widget.userRepository) : null,
          appBar: AppBar(
            title: const Text('🧃 BookMyJuice',
                style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),),
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          body: IndexedStack(
            index: _navIndex,
            children: [
              _buildHomeTab(isAuth, user),
              Container(color: Colors.orange), // Menu placeholder
              Container(color: Colors.blue),   // Orders placeholder
              Container(color: Colors.grey),   // Profile placeholder
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
                  fontWeight: FontWeight.bold, color: Colors.white,),
            ),
          ),
          SizedBox(height: 16.h),
          // Stats strip
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(children: [
              _statCard(Icons.local_drink, '47', 'Deliveries'),
              SizedBox(width: 8.w), _statCard(Icons.calendar_month, 'Jan 2026', 'Member Since'),
              SizedBox(width: 8.w), _statCard(Icons.recycling, '12', 'Returned'),
            ],),
          ),
          SizedBox(height: 24.h),
          Text('Order Today', style: TextStyle(fontFamily: 'Poppins',
              fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.grey,),),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _statCard(IconData icon, String number, String label) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          child: Column(children: [
            Icon(icon, size: 20, color: const Color(0xFF2E7D32)),
            SizedBox(height: 4.h),
            Text(number, style: TextStyle(fontFamily: 'Poppins', fontSize: 20.sp,
                fontWeight: FontWeight.bold, color: const Color(0xFF2E7D32),),),
            Text(label, style: TextStyle(fontFamily: 'Poppins', fontSize: 11.sp, color: Colors.grey)),
          ],),
        ),
      ),
    );
  }
}