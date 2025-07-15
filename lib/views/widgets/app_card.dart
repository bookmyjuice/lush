import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;
  final Border? border;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderRadius,
    this.boxShadow,
    this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.symmetric(vertical: 8.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
          child: Container(
            padding: padding ?? EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: backgroundColor ?? LushTheme.white,
              borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: LushTheme.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
              border: border,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class AppCardHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onActionTap;

  const AppCardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: LushTheme.darkerText,
                ),
              ),
              if (subtitle != null) ...[
                SizedBox(height: 4.h),
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: LushTheme.lightText,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
        if (onActionTap != null)
          GestureDetector(
            onTap: onActionTap,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: LushTheme.nearlyBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16.sp,
                color: LushTheme.nearlyBlue,
              ),
            ),
          ),
      ],
    );
  }
}

class AppLoadingCard extends StatefulWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;

  const AppLoadingCard({
    super.key,
    this.height,
    this.margin,
  });

  @override
  State<AppLoadingCard> createState() => _AppLoadingCardState();
}

class _AppLoadingCardState extends State<AppLoadingCard>
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
        return AppCard(
          margin: widget.margin,
          backgroundColor: LushTheme.nearlyWhite,
          child: SizedBox(
            height: widget.height ?? 120.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 20.h,
                  width: 150.w,
                  decoration: BoxDecoration(
                    color: LushTheme.grey.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  height: 16.h,
                  width: 200.w,
                  decoration: BoxDecoration(
                    color: LushTheme.grey.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  height: 16.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: LushTheme.grey.withOpacity(_animation.value),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
