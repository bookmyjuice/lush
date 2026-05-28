import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import '../models/user.dart';

class WelcomeHeader extends StatelessWidget {
  final User user;
  final UserRepository userRepository = getIt.get();

  WelcomeHeader({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        String selfServePageUrl = await userRepository.getSelfServePageUrl();
        Navigator.pushNamed(context, '/myaccount', arguments: selfServePageUrl);
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryOrange,
              AppColors.lightBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30.r,
              backgroundColor: AppColors.white,
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondaryTealDark,
                ),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back,',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user.firstName.isNotEmpty ? user.firstName : 'User',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Ready for your healthy juice today?',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.local_drink,
                color: AppColors.primaryOrange,
                size: 24.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WelcomeHeaderShimmer extends StatefulWidget {
  const WelcomeHeaderShimmer({super.key});

  @override
  State<WelcomeHeaderShimmer> createState() => _WelcomeHeaderShimmerState();
}

class _WelcomeHeaderShimmerState extends State<WelcomeHeaderShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: AppColors.offWhite,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: AppColors.grey.withValues(alpha: _animation.value),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14.h,
                      width: 100.w,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: _animation.value),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 24.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: _animation.value),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 12.h,
                      width: 200.w,
                      decoration: BoxDecoration(
                        color: AppColors.grey.withValues(alpha: _animation.value),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
