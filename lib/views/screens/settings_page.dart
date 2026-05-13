import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/app_card.dart';
import 'package:lush/theme/app_colors.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationsEnabled = true;
  bool _emailUpdatesEnabled = true;
  bool _smsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: Text(
          'Settings',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.lightTextPrimary,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: AppColors.lightTextPrimary,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Notifications'),
            SizedBox(height: 16.h),
            
            AppCard(
              child: Column(
                children: [
                  _buildSwitchTile(
                    'Push Notifications',
                    'Receive order updates and offers',
                    _notificationsEnabled,
                    (value) => setState(() => _notificationsEnabled = value),
                  ),
                  Divider(color: AppColors.grey.withValues(alpha: 0.3)),
                  _buildSwitchTile(
                    'Email Updates',
                    'Get newsletters and promotions',
                    _emailUpdatesEnabled,
                    (value) => setState(() => _emailUpdatesEnabled = value),
                  ),
                  Divider(color: AppColors.grey.withValues(alpha: 0.3)),
                  _buildSwitchTile(
                    'SMS Alerts',
                    'Delivery notifications via SMS',
                    _smsEnabled,
                    (value) => setState(() => _smsEnabled = value),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            _buildSectionTitle('Account'),
            SizedBox(height: 16.h),
            
            AppCard(
              child: Column(
                children: [
                  _buildActionTile(
                    Icons.person_outline,
                    'Edit Profile',
                    'Update your personal information',
                    () {
                      // Navigate to profile edit
                    },
                  ),
                  Divider(color: AppColors.grey.withValues(alpha: 0.3)),
                  _buildActionTile(
                    Icons.location_on_outlined,
                    'Delivery Address',
                    'Manage your delivery locations',
                    () {
                      // Navigate to address management
                    },
                  ),
                  Divider(color: AppColors.grey.withValues(alpha: 0.3)),
                  _buildActionTile(
                    Icons.payment_outlined,
                    'Payment Methods',
                    'Manage cards and payment options',
                    () {
                      // Navigate to payment methods
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            _buildSectionTitle('Support'),
            SizedBox(height: 16.h),
            
            AppCard(
              child: Column(
                children: [
                  _buildActionTile(
                    Icons.help_outline,
                    'Help Center',
                    'FAQs and support articles',
                    () {
                      // Navigate to help center
                    },
                  ),
                  Divider(color: AppColors.grey.withValues(alpha: 0.3)),
                  _buildActionTile(
                    Icons.chat_outlined,
                    'Contact Us',
                    'Get in touch with our team',
                    () {
                      // Navigate to contact
                    },
                  ),
                  Divider(color: AppColors.grey.withValues(alpha: 0.3)),
                  _buildActionTile(
                    Icons.star_outline,
                    'Rate App',
                    'Share your feedback',
                    () {
                      // Open app store for rating
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),
            _buildSectionTitle('Legal'),
            SizedBox(height: 16.h),
            
            AppCard(
              child: Column(
                children: [
                  _buildActionTile(
                    Icons.description_outlined,
                    'Terms of Service',
                    'View our terms and conditions',
                    () {
                      // Navigate to terms
                    },
                  ),
                  Divider(color: AppColors.grey.withValues(alpha: 0.3)),
                  _buildActionTile(
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    'How we handle your data',
                    () {
                      // Navigate to privacy policy
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.lightTextSecondary,
                ),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.lightTextPrimary,
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.info,
            activeTrackColor: AppColors.info.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: AppColors.info,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: AppColors.lightTextSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
