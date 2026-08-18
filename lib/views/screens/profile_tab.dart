/// Glassmorphism Profile Tab
///
/// Replaces the old _buildProfileTab in dashboard.dart.
/// Preserves all existing Bloc wiring — only UI/UX changes.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/widgets/glass_card.dart';

/// Profile tab — glassmorphism version.
class ProfileTab extends StatelessWidget {
  final User? user;
  final bool isAuth;
  final VoidCallback? onNavigateToOrders;

  const ProfileTab({
    super.key,
    this.user,
    required this.isAuth,
    this.onNavigateToOrders,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.resolvedThemeMode == ThemeMode.dark;
    final bgColor = isDark ? AppColors.glassBg : AppColors.glassBgLight;

    return Container(
      color: bgColor,
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: isAuth && user != null
              ? _buildAuthenticatedProfile(context, isDark)
              : _buildPublicProfile(context, isDark),
        ),
      ),
    );
  }

  Widget _buildPublicProfile(BuildContext context, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 60.h),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.glassAccent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.glassAccent.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.person_outline,
            size: 40,
            color: AppColors.glassAccent,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Welcome to BookMyJuice!',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Sign in to manage your account',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            color: AppColors.glassTextDim,
          ),
        ),
        SizedBox(height: 24.h),
        Semantics(
          label: 'Sign In',
          child: GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 14),
            borderRadius: AppRadius.lg,
            onTap: () => Navigator.pushNamed(context, '/login'),
            child: Text(
              'Sign In',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.glassAccent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthenticatedProfile(BuildContext context, bool isDark) {
    return Column(
      children: [
        SizedBox(height: 16.h),

        // ── Avatar + Name ──
        _buildProfileHeader(context, isDark),

        SizedBox(height: 24.h),

        // ── Menu Items ──
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: AppRadius.lg,
          child: Column(
            children: [
              Semantics(
                label: 'Order History',
                child: _profileMenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Order History',
                  isDark: isDark,
                  onTap: () {
                    if (onNavigateToOrders != null) {
                      onNavigateToOrders!();
                    } else {
                      Navigator.pushNamed(context, '/order-history');
                    }
                  },
                ),
              ),
              _glassDivider(isDark),
              Semantics(
                label: 'Refer & Earn',
                child: _profileMenuItem(
                  icon: Icons.card_giftcard_outlined,
                  label: 'Refer & Earn',
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/referral'),
                ),
              ),
              _glassDivider(isDark),
              Semantics(
                label: 'Invoices',
                child: _profileMenuItem(
                  icon: Icons.description_outlined,
                  label: 'Invoices',
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/invoices'),
                ),
              ),
              _glassDivider(isDark),
              Semantics(
                label: 'Manage Subscriptions',
                child: _profileMenuItem(
                  icon: Icons.subscriptions_outlined,
                  label: 'Manage Subscriptions',
                  isDark: isDark,
                  onTap: () => Navigator.pushNamed(context, '/manage-subscriptions'),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 16.h),

        // ── Theme Toggle ──
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: AppRadius.lg,
          child: _buildThemeToggle(context, isDark),
        ),

        SizedBox(height: 16.h),

        // ── Logout ──
        GlassCard(
          padding: EdgeInsets.zero,
          borderRadius: AppRadius.lg,
          child: _profileMenuItem(
            icon: Icons.logout,
            label: 'Logout',
            isDark: isDark,
            isDestructive: true,
            onTap: () => _confirmLogout(context, isDark),
          ),
        ),

        SizedBox(height: 32.h),

        // ── Version ──
        Text(
          'BookMyJuice v1.0.0',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12.sp,
            color: AppColors.glassTextDim,
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isDark) {
    final initial = user!.firstName.isNotEmpty
        ? user!.firstName[0].toUpperCase()
        : 'U';

    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/user-profile'),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: Row(
          children: [
            // Avatar
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreenLight,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Semantics(
                  label: 'View Profile',
                  button: true,
                  child: Text(
                    initial,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${user!.firstName} ${user!.lastName}',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user!.email,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                      color: AppColors.glassAccent,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: AppColors.glassTextDim),
          ],
        ),
      ),
    );
  }

  Widget _profileMenuItem({
    required IconData icon,
    required String label,
    required bool isDark,
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.glassText : AppColors.lightTextPrimary);
    final iconColor = isDestructive ? AppColors.error : AppColors.glassAccent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.glassTextDim,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glassDivider(bool isDark) {
    return Container(
      height: 0.5,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      color: isDark ? AppColors.glassBorder : AppColors.glassBorderLight,
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    final themeCubit = context.read<ThemeCubit>();
    final currentMode = context.watch<ThemeCubit>().state.themeMode;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.glassOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              currentMode == AppThemeMode.dark
                  ? Icons.dark_mode
                  : currentMode == AppThemeMode.light
                      ? Icons.light_mode
                      : Icons.brightness_auto,
              size: 20,
              color: AppColors.glassOrange,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Theme',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
              ),
            ),
          ),
          // Theme mode chips
          _themeChip('System', AppThemeMode.system, currentMode, themeCubit, isDark),
          SizedBox(width: 4.w),
          _themeChip('Light', AppThemeMode.light, currentMode, themeCubit, isDark),
          SizedBox(width: 4.w),
          _themeChip('Dark', AppThemeMode.dark, currentMode, themeCubit, isDark),
        ],
      ),
    );
  }

  Widget _themeChip(
    String label,
    AppThemeMode mode,
    AppThemeMode current,
    ThemeCubit cubit,
    bool isDark,
  ) {
    final isSelected = mode == current;
    return GestureDetector(
      onTap: () {
        switch (mode) {
          case AppThemeMode.system:
            cubit.setSystemTheme();
          case AppThemeMode.light:
            cubit.setLightTheme();
          case AppThemeMode.dark:
            cubit.setDarkTheme();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.glassAccent.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected
                ? AppColors.glassAccent.withValues(alpha: 0.5)
                : (isDark ? AppColors.glassBorderSubtle : AppColors.glassBorderLight),
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppColors.glassAccent
                : AppColors.glassTextDim,
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, bool isDark) {
    showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          margin: EdgeInsets.all(16.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.glassElevated : AppColors.glassElevatedLight,
            borderRadius: BorderRadius.circular(AppRadius.xl),
            border: Border.all(
              color: isDark ? AppColors.glassBorder : AppColors.glassBorderLight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout,
                  size: 28,
                  color: AppColors.error,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Logout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.glassText : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Are you sure you want to logout?',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: AppColors.glassTextDim,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.glassSurface
                              : AppColors.glassSurfaceLight,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: isDark
                                ? AppColors.glassBorderSubtle
                                : AppColors.glassBorderLight,
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.glassTextDim,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        context.read<AuthenticationBloc>().add(LogOut());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          'Logout',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
    );
  }
}