import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_text_styles.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<NotificationItem> notifications = [
    NotificationItem(
      title: "Welcome to BookMyJuice!",
      message: "Thanks for joining us. Enjoy fresh juices delivered daily.",
      time: DateTime.now().subtract(Duration(hours: 2)),
      isRead: false,
      type: NotificationType.welcome,
    ),
    NotificationItem(
      title: "Order Confirmed",
      message:
          "Your order #BMJ001 has been confirmed and will be delivered tomorrow.",
      time: DateTime.now().subtract(Duration(hours: 5)),
      isRead: true,
      type: NotificationType.order,
    ),
    NotificationItem(
      title: "New Juice Available",
      message: "Try our new Superfood Green Smoothie - packed with nutrients!",
      time: DateTime.now().subtract(Duration(days: 1)),
      isRead: true,
      type: NotificationType.promotion,
    ),
    NotificationItem(
      title: "Subscription Reminder",
      message: "Your premium plan will be renewed in 3 days.",
      time: DateTime.now().subtract(Duration(days: 2)),
      isRead: false,
      type: NotificationType.subscription,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        shadowColor: AppColors.grey.withAlpha(50),
        title: Text(
          'Notifications',
          style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTextPrimary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all read',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.info, fontFamily: 'Roboto'),
            ),
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return _buildNotificationItem(notification, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80.sp,
            color: AppColors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'We\'ll notify you about orders, deliveries, and special offers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationItem notification, int index) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: notification.isRead
            ? AppColors.white
            : AppColors.info.withAlpha(25),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: notification.isRead
              ? AppColors.grey.withAlpha(50)
              : AppColors.info.withAlpha(50),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _markAsRead(index),
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color:
                        _getNotificationColor(notification.type).withAlpha(25),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    _getNotificationIcon(notification.type),
                    size: 20.sp,
                    color: _getNotificationColor(notification.type),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8.w,
                              height: 8.w,
                              decoration: BoxDecoration(
                                color: AppColors.info,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.grey,
                          height: 1.4,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _formatTime(notification.time),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag_outlined;
      case NotificationType.delivery:
        return Icons.local_shipping_outlined;
      case NotificationType.promotion:
        return Icons.local_offer_outlined;
      case NotificationType.subscription:
        return Icons.subscriptions_outlined;
      case NotificationType.welcome:
        return Icons.celebration_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return AppColors.success;
      case NotificationType.delivery:
        return AppColors.info;
      case NotificationType.promotion:
        return AppColors.primaryOrange;
      case NotificationType.subscription:
        return AppColors.info;
      case NotificationType.welcome:
        return Colors.purple;
      default:
        return AppColors.info;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _markAsRead(int index) {
    setState(() {
      notifications[index].isRead = true;
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification.isRead = true;
      }
    });
  }
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  bool isRead;
  final NotificationType type;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.type,
  });
}

enum NotificationType {
  order,
  delivery,
  promotion,
  subscription,
  welcome,
  general,
}
