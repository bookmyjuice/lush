/// User Profile Screen
///
/// Shows full user details including personal info, and all saved addresses
/// with the ability to select a default address.
library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_radius.dart';
import 'package:lush/views/models/user_address.dart';
import 'package:lush/widgets/glass_card.dart';

/// Screen showing the full user profile with personal details and addresses.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserRepository _userRepo = getIt.get<UserRepository>();
  List<UserAddress> _addresses = [];
  bool _isLoadingAddresses = true;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() => _isLoadingAddresses = true);
    try {
      final result = await _userRepo.getUserAddresses();
      if (result['status'] == 'success') {
        final data = result['data'];
        if (data is List) {
          setState(() {
            _addresses = data
                .map((e) => UserAddress.fromJson(e as Map<String, dynamic>))
                .toList();
          });
        }
      }
    } catch (_) {
      // Silently handle — addresses will show as empty
    } finally {
      if (mounted) setState(() => _isLoadingAddresses = false);
    }
  }

  void _navigateToAddressEntry() {
    Navigator.pushNamed(
      context,
      '/address-entry',
      arguments: {
        'email': _userRepo.user.email,
        'phone': _userRepo.user.phone,
        'firstName': _userRepo.user.firstName,
        'lastName': _userRepo.user.lastName,
      },
    ).then((_) => _loadAddresses());
  }

  Future<void> _setDefaultAddress(UserAddress addr) async {
    final result = await _userRepo.setDefaultAddress(addr.id);
    if (result['status'] == 'success') {
      await _loadAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default address updated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(result['message'] as String? ?? 'Failed to update'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _userRepo.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.glassBg : AppColors.glassBgLight,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Personal Details Section ──
            GlassCard(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
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
                        ),
                        child: Center(
                          child: Text(
                            (user.firstName.isNotEmpty
                                    ? user.firstName[0]
                                    : 'U')
                                .toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                              '${user.firstName} ${user.lastName}'.trim(),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.glassText
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              user.email,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.sp,
                                color: AppColors.glassTextDim,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _infoRow(Icons.phone_outlined, 'Phone', user.phone, isDark),
                  if (user.referralCode != null && user.referralCode!.isNotEmpty)
                    _infoRow(
                        Icons.card_giftcard_outlined,
                        'Referral Code',
                        user.referralCode!,
                        isDark),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            // ── Addresses Section ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved Addresses',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.glassText
                        : AppColors.lightTextPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: _navigateToAddressEntry,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add'),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            if (_isLoadingAddresses)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_addresses.isEmpty)
              _emptyAddresses(isDark)
            else
              ..._addresses.map(
                (addr) => _addressCard(addr, isDark),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.glassAccent),
          SizedBox(width: 12.w),
          Text(
            '$label: ',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.glassTextDim,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: isDark
                    ? AppColors.glassText
                    : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyAddresses(bool isDark) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      child: Column(
        children: [
          Icon(Icons.location_off,
              size: 48, color: AppColors.glassTextDim),
          SizedBox(height: 12.h),
          Text(
            'No addresses saved yet',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              color: AppColors.glassTextDim,
            ),
          ),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: _navigateToAddressEntry,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.glassAccent.withAlpha(30),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Add Address',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.glassAccent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _addressCard(UserAddress addr, bool isDark) {
    return GestureDetector(
      onTap: addr.isDefault
          ? null
          : () => _setDefaultAddress(addr),
      child: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.glassSurface
              : AppColors.glassSurfaceLight,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: addr.isDefault
                ? AppColors.glassAccent
                : (isDark
                    ? AppColors.glassBorderSubtle
                    : AppColors.glassBorderLight),
            width: addr.isDefault ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (addr.label.isNotEmpty)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.glassAccent.withAlpha(25),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            addr.label,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.glassAccent,
                            ),
                          ),
                        ),
                      if (addr.label.isNotEmpty) SizedBox(width: 8.w),
                      if (addr.isDefault)
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(25),
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'DEFAULT',
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (!addr.isDefault)
                  GestureDetector(
                    onTap: () => _setDefaultAddress(addr),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.glassAccent.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star_outline,
                        size: 16,
                        color: AppColors.glassAccent,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              addr.addressLine1,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.glassText
                    : AppColors.lightTextPrimary,
              ),
            ),
            if (addr.addressLine2.isNotEmpty) SizedBox(height: 2.h),
            if (addr.addressLine2.isNotEmpty)
              Text(
                addr.addressLine2,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13.sp,
                  color: isDark
                      ? AppColors.glassText
                      : AppColors.lightTextPrimary,
                ),
              ),
            SizedBox(height: 2.h),
            Text(
              '${addr.city}${addr.state.isNotEmpty ? ', ${addr.state}' : ''} - ${addr.pincode}',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.sp,
                color: isDark
                    ? AppColors.glassText
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}