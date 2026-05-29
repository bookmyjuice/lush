import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/UserRepository/user_repository.dart';

class AppDrawer extends StatelessWidget {
  final User user;
  final UserRepository userRepository;

  const AppDrawer({
    super.key,
    required this.user,
    required this.userRepository,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Gradient Header ──
          Container(
            height: 280.h,
            padding: EdgeInsets.fromLTRB(20.w, 40.h, 20.w, 20.h),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: Colors.white,
                  child: Text(
                    user.firstName.isNotEmpty
                        ? user.firstName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2E7D32),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  '${user.getFirstName} ${user.getLastName}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  user.getEmail,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 12.h),
                // ── Referral Chip ──
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: 'BMJ123'));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Referral code copied!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
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
                        const Icon(Icons.card_giftcard, size: 14, color: Colors.white),
                        SizedBox(width: 4.w),
                        Text(
                          'BMJ123  📋',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // ── MY ORDERS ──
          _sectionLabel('MY ORDERS'),
          _drawerItem(
            icon: Icons.receipt_long_outlined,
            title: 'Order History',
            onTap: () => Navigator.pushNamed(context, '/order-history'),
          ),
          _drawerItem(
            icon: Icons.replay,
            title: 'Reorder Last',
            onTap: () => Navigator.pushNamed(context, '/cart'),
          ),
          // ── SUBSCRIPTION ──
          _sectionLabel('SUBSCRIPTION'),
          _drawerItem(
            icon: Icons.card_membership_outlined,
            title: 'Active Subscription',
            onTap: () => Navigator.pushNamed(context, '/manage-subscriptions'),
          ),
          _drawerItem(
            icon: Icons.pause_circle_outlined,
            title: 'Pause / Modify',
            onTap: () => Navigator.pushNamed(context, '/manage-subscriptions'),
          ),
          _drawerItem(
            icon: Icons.upgrade_outlined,
            title: 'Upgrade Plan',
            onTap: () => Navigator.pushNamed(context, '/subscription-family'),
          ),
          _drawerItem(
            icon: Icons.card_giftcard_outlined,
            title: 'Refer & Earn',
            onTap: () => Navigator.pushNamed(context, '/referral'),
          ),
          // ── ACCOUNT ──
          _sectionLabel('ACCOUNT'),
          _drawerItem(
            icon: Icons.person_outline,
            title: 'Profile & Address',
            onTap: () {
              Navigator.pushNamed(context, '/myaccount',
                  arguments: 'profile');
            },
          ),
          _drawerItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () => Navigator.pushNamed(context, '/notifications'),
          ),
          const Divider(height: 1),
          _drawerItem(
            icon: Icons.logout,
            title: 'Logout',
            iconColor: Colors.red,
            textColor: Colors.red,
            onTap: () {
              showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('CANCEL'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        context.read<AuthenticationBloc>().add(LogOut());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('LOGOUT'),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.lightTextSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? const Color(0xFF2E7D32)),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          color: textColor ?? AppColors.lightTextPrimary,
        ),
      ),
      trailing: Icon(Icons.chevron_right, size: 18, color: AppColors.lightTextSecondary),
      onTap: onTap,
    );
  }
}