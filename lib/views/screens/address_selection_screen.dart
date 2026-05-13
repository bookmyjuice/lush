import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/utils/haptic_feedback.dart';

/// FR-DEL-003 to FR-DEL-007: Address Selection Screen
/// - View saved addresses
/// - Select an address for delivery
/// - Set default address
/// - Delete address
class AddressSelectionScreen extends StatefulWidget {
  static const routeName = '/address-selection';

  const AddressSelectionScreen({super.key});

  @override
  AddressSelectionScreenState createState() => AddressSelectionScreenState();
}

class AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final UserRepository _userRepo = getIt.get<UserRepository>();
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await _userRepo.getUserAddresses();
      if (result['status'] == 'success') {
        final data = result['data'];
        if (data is List) {
          setState(() {
            _addresses = data.cast<Map<String, dynamic>>();
          });
        } else {
          setState(() => _addresses = []);
        }
      } else {
        setState(() => _error = result['message'] as String? ?? 'Failed to load addresses');
      }
    } catch (e) {
      setState(() => _error = 'Error loading addresses: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setDefault(int addressId) async {
    HapticFeedbackUtil.lightFeedback();
    final result = await _userRepo.setDefaultAddress(addressId);
    if (result['status'] == 'success') {
      _loadAddresses();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Default address updated'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] as String? ?? 'Failed to update'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteAddress(int addressId) async {
    HapticFeedbackUtil.mediumFeedback();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _userRepo.deleteUserAddress(addressId);
      if (result['status'] == 'success') {
        _loadAddresses();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Address deleted'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] as String? ?? 'Failed to delete'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _selectAddress(Map<String, dynamic> address) {
    HapticFeedbackUtil.lightFeedback();
    Navigator.pop(context, address);
  }

  Future<void> _navigateToAddAddress() async {
    // Navigate to address entry screen for adding a new delivery address
    final result = await Navigator.pushNamed(
      context,
      '/address-entry',
      arguments: {
        'email': '',
        'phone': '',
        'firstName': '',
        'lastName': '',
      },
    );

    // Refresh addresses after adding a new one
    if (result != null) {
      _loadAddresses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Address'),
        backgroundColor: AppColors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddAddress,
        backgroundColor: AppColors.primaryOrange,
        foregroundColor: AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add New Address'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              SizedBox(height: 16.h),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: _loadAddresses,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off, size: 64.r, color: AppColors.grey),
            SizedBox(height: 16.h),
            Text(
              'No saved addresses',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add a delivery address to proceed',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAddresses,
      child: ListView.builder(
        padding: EdgeInsets.all(16.r),
        itemCount: _addresses.length,
        itemBuilder: (context, index) {
          final address = _addresses[index];
          final isDefault = address['default'] == true || address['isDefault'] == true;
          final addressId = address['id'] as int? ?? 0;
          final fullName = address['fullName'] as String? ?? '';
          final phone = address['phone'] as String? ?? '';
          final line1 = address['addressLine1'] as String? ?? '';
          final line2 = address['addressLine2'] as String? ?? '';
          final landmark = address['landmark'] as String? ?? '';
          final city = address['city'] as String? ?? '';
          final state = address['state'] as String? ?? '';
          final pincode = address['pincode'] as String? ?? '';
          final label = address['label'] as String? ?? '';

          return Card(
            margin: EdgeInsets.only(bottom: 12.h),
            elevation: isDefault ? 3 : 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
              side: isDefault
                  ? const BorderSide(color: AppColors.primaryOrange, width: 2)
                  : BorderSide.none,
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12.r),
              onTap: () => _selectAddress(address),
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (label.isNotEmpty)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryOrange.withAlpha(30),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryOrangeDark,
                              ),
                            ),
                          ),
                        if (label.isNotEmpty) SizedBox(width: 8.w),
                        if (isDefault)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.success.withAlpha(30),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              'DEFAULT',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'default') {
                              _setDefault(addressId);
                            } else if (value == 'delete') {
                              _deleteAddress(addressId);
                            }
                          },
                          itemBuilder: (context) => [
                            if (!isDefault)
                              const PopupMenuItem(
                                value: 'default',
                                child: Row(
                                  children: [
                                    Icon(Icons.star_outline, size: 18),
                                    SizedBox(width: 8),
                                    Text('Set as Default'),
                                  ],
                                ),
                              ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                                  SizedBox(width: 8),
                                  Text('Delete', style: TextStyle(color: AppColors.error)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    if (fullName.isNotEmpty)
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    if (fullName.isNotEmpty) SizedBox(height: 4.h),
                    Text(
                      line1,
                      style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextPrimary),
                    ),
                    if (line2.isNotEmpty)
                      Text(
                        line2,
                        style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextPrimary),
                      ),
                    if (landmark.isNotEmpty)
                      Text(
                        'Near: $landmark',
                        style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                      ),
                    Text(
                      '$city, $state - $pincode',
                      style: TextStyle(fontSize: 14.sp, color: AppColors.lightTextPrimary),
                    ),
                    if (phone.isNotEmpty) SizedBox(height: 4.h),
                    if (phone.isNotEmpty)
                      Text(
                        'Phone: $phone',
                        style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
