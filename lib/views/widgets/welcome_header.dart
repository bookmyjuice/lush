import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import '../models/user.dart';
import '../../theme.dart';

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
              LushTheme.orangeAccent,
              LushTheme.background,
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
              backgroundColor: LushTheme.white,
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName[0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: LushTheme.nearlyDarkBlue,
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
                      color: LushTheme.lightText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user.firstName.isNotEmpty ? user.firstName : 'User',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: LushTheme.darkerText,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Ready for your healthy juice today?',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: LushTheme.lightText,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: LushTheme.nearlyBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.local_drink,
                color: LushTheme.orangeAccent,
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
            color: LushTheme.nearlyWhite,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundColor: LushTheme.grey.withValues(alpha: _animation.value),
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
                        color: LushTheme.grey.withValues(alpha: _animation.value),
                        borderRadius: BorderRadius.circular(7.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 24.h,
                      width: 150.w,
                      decoration: BoxDecoration(
                        color: LushTheme.grey.withValues(alpha: _animation.value),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      height: 12.h,
                      width: 200.w,
                      decoration: BoxDecoration(
                        color: LushTheme.grey.withValues(alpha: _animation.value),
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
