import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/utils/haptic_feedback.dart';

/// FR-DEL-001 to FR-DEL-002: Delivery Slot Selection
/// - Check pincode serviceability
/// - View available slots for a service area
/// - Select a delivery slot
class DeliverySlotSelectionScreen extends StatefulWidget {
  static const routeName = '/delivery-slot-selection';

  const DeliverySlotSelectionScreen({super.key});

  @override
  DeliverySlotSelectionScreenState createState() =>
      DeliverySlotSelectionScreenState();
}

class DeliverySlotSelectionScreenState
    extends State<DeliverySlotSelectionScreen> {
  final UserRepository _userRepo = getIt.get<UserRepository>();

  // Pincode entry
  final _pincodeController = TextEditingController();
  bool _checkingPincode = false;
  bool _pincodeChecked = false;
  bool _isServiceable = false;
  int? _serviceAreaId;
  String? _pincodeError;
  String? _areaName;

  // Slot selection
  bool _loadingSlots = false;
  List<Map<String, dynamic>> _slots = [];
  String? _slotsError;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _checkPincode() async {
    final pincode = _pincodeController.text.trim();
    if (pincode.length != 6) {
      setState(() => _pincodeError = 'Enter a valid 6-digit pincode');
      return;
    }

    HapticFeedbackUtil.lightFeedback();
    setState(() {
      _checkingPincode = true;
      _pincodeError = null;
      _pincodeChecked = false;
      _slots = [];
    });

    final result = await _userRepo.checkServiceability(pincode);

    setState(() {
      _checkingPincode = false;
      _pincodeChecked = true;
    });

    if (result['status'] == 'success') {
      final data = result['data'];
      if (data is Map<String, dynamic>) {
        setState(() {
          _isServiceable = data['serviced'] == true || data['isServiced'] == true;
          _serviceAreaId = data['id'] as int?;
          _areaName = (data['areaName'] ?? data['city'] ?? '') as String?;
        });
        if (_isServiceable && _serviceAreaId != null) {
          _loadSlots();
        }
      } else {
        final serviced = result['serviced'] == true;
        setState(() {
          _isServiceable = serviced;
          _serviceAreaId = null;
        });
      }
    } else {
      setState(() {
        _isServiceable = false;
        _serviceAreaId = null;
        if (result['serviced'] == false) {
          _pincodeError = 'This pincode is not serviceable';
        } else {
          _pincodeError = result['message'] as String? ?? 'Could not check pincode';
        }
      });
    }
  }

  Future<void> _loadSlots() async {
    if (_serviceAreaId == null) return;

    setState(() {
      _loadingSlots = true;
      _slotsError = null;
    });

    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    final result = await _userRepo.getAvailableSlots(_serviceAreaId!, dateStr);

    setState(() {
      _loadingSlots = false;
    });

    if (result['status'] == 'success') {
      final data = result['data'];
      if (data is List) {
        setState(() {
          _slots = data.cast<Map<String, dynamic>>();
        });
      }
    } else {
      setState(() {
        _slotsError =
            result['message'] as String? ?? 'Failed to load delivery slots';
      });
    }
  }

  void _selectSlot(Map<String, dynamic> slot) {
    HapticFeedbackUtil.lightFeedback();
    Navigator.pop(context, {
      'slot': slot,
      'serviceAreaId': _serviceAreaId,
    });
  }

  void _changeDate(int daysOffset) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: daysOffset));
      _slots = [];
    });
    _loadSlots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Slot'),
        backgroundColor: AppColors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pincode entry section
            const Text(
              'Delivery Pincode',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _pincodeController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: InputDecoration(
                      hintText: 'Enter pincode',
                      prefixIcon: const Icon(Icons.pin_drop_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      counterText: '',
                      errorText: _pincodeError,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                ElevatedButton(
                  onPressed: _checkingPincode ? null : _checkPincode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryOrange,
                    foregroundColor: AppColors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _checkingPincode
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : const Text('Check'),
                ),
              ],
            ),

            if (_pincodeChecked) ...[
              SizedBox(height: 16.h),
              if (_isServiceable) ...[
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(25),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.success.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.success),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Delivery Available!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            if (_areaName != null)
                              Text(
                                'We deliver to $_areaName',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.lightTextSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Date and slot selection
                Row(
                  children: [
                    IconButton(
                      onPressed:
                          _selectedDate.subtract(const Duration(days: 1)).isBefore(
                                  DateTime.now().subtract(const Duration(days: 1)))
                              ? null
                              : () => _changeDate(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeDate(1),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Slot list
                if (_loadingSlots)
                  const Center(child: CircularProgressIndicator())
                else if (_slotsError != null)
                  Center(
                    child: Column(
                      children: [
                        Text(
                          _slotsError!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                        SizedBox(height: 8.h),
                        TextButton(
                          onPressed: _loadSlots,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_slots.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'No delivery slots available for this date. Try another date.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.lightTextSecondary),
                      ),
                    ),
                  )
                else
                  ...List.generate(_slots.length, (index) {
                    final slot = _slots[index];
                    final startTime = slot['startTime'] as String? ?? '';
                    final endTime = slot['endTime'] as String? ?? '';
                    final maxOrders = slot['maxOrders'] as int? ?? 0;
                    final currentOrders = slot['currentOrders'] as int? ?? 0;
                    final available = slot['available'] as bool? ?? true;
                    final remaining = maxOrders - currentOrders;

                    return Card(
                      margin: EdgeInsets.only(bottom: 8.h),
                      color: available ? null : AppColors.lightDivider.withAlpha(100),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: available
                              ? AppColors.primaryOrange
                              : AppColors.grey,
                          child: const Icon(Icons.access_time,
                              color: AppColors.white),
                        ),
                        title: Text(
                          '$startTime - $endTime',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        subtitle: Text(
                          available
                              ? '$remaining slots remaining'
                              : 'Fully booked',
                          style: TextStyle(
                            color: available
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                        trailing: available
                            ? const Icon(Icons.check_circle_outline,
                                color: AppColors.success)
                            : const Icon(Icons.cancel, color: AppColors.error),
                        enabled: available,
                        onTap: available ? () => _selectSlot(slot) : null,
                      ),
                    );
                  }),
              ] else ...[
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: AppColors.error.withAlpha(25),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.error.withAlpha(80)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.cancel, color: AppColors.error),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Sorry, we do not deliver to this pincode yet.',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
