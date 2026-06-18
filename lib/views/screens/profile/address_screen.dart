import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/utils/serviceability_checker.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _flatController = TextEditingController();
  final _buildingController = TextEditingController();
  final _streetController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _instructionsController = TextEditingController();
  bool _isSaving = false;
  bool _isPincodeValid = true;

  @override
  void initState() {
    super.initState();
    _prefillFromProfile();
  }

  void _prefillFromProfile() {
    final userRepo = getIt.get<UserRepository>();
    final user = userRepo.user;
    _flatController.text = user.extendedAddr ?? '';
    _buildingController.text = user.extendedAddr2 ?? '';
    _streetController.text = user.address ?? '';
    _cityController.text = user.city ?? '';
    _pincodeController.text = user.zip ?? '';
  }

  void _checkPincode() {
    final pincode = _pincodeController.text.trim();
    setState(() {
      _isPincodeValid = pincode.isEmpty || ServiceabilityChecker.isServiceable(pincode);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isPincodeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ServiceabilityChecker.notServiceableMessage),
            backgroundColor: AppColors.error,),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      // TODO: dispatch UpdateUserProfile to UserBloc when B5 handler is wired
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _flatController.dispose(); _buildingController.dispose();
    _streetController.dispose(); _areaController.dispose();
    _cityController.dispose(); _pincodeController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.white, elevation: 0,
        title: const Text('Delivery Address',
            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),),
        iconTheme: const IconThemeData(color: AppColors.lightTextPrimary),
      ),
      body: _isSaving
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Form(key: _formKey, child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                _buildField('Flat / House No. *', _flatController, Icons.home_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,),
                SizedBox(height: 16.h),
                _buildField('Building Name *', _buildingController, Icons.apartment_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,),
                SizedBox(height: 16.h),
                _buildField('Street / Locality *', _streetController, Icons.location_on_outlined,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,),
                SizedBox(height: 16.h),
                _buildField('Area / Sector', _areaController, Icons.map_outlined),
                SizedBox(height: 16.h),
                _buildField('City *', _cityController, Icons.location_city,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,),
                SizedBox(height: 16.h),
                _buildField('Pincode *', _pincodeController, Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number, maxLength: 6,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (v.trim().length != 6) return 'Enter 6-digit pincode';
                      if (!RegExp(r'^\d{6}$').hasMatch(v.trim())) return 'Digits only';
                      if (!ServiceabilityChecker.isServiceable(v.trim())) {
                        return ServiceabilityChecker.notServiceableMessage;
                      }
                      return null;
                    },
                    onChanged: (_) => _checkPincode(),),
                SizedBox(height: 16.h),
                _buildField('Delivery Instructions (optional)', _instructionsController,
                    Icons.note_alt_outlined, maxLines: 3,),
                SizedBox(height: 24.h),
                SizedBox(width: double.infinity, height: 50.h,
                  child: ElevatedButton(
                    onPressed: _isPincodeValid ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      disabledBackgroundColor: AppColors.lightDivider,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text('Save Address',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.white),),
                  ),
                ),
                SizedBox(height: 24.h),
              ],),),
            ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData icon, {
    String? Function(String?)? validator, TextInputType? keyboardType,
    int? maxLength, int maxLines = 1, void Function(String)? onChanged,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary)),
      SizedBox(height: 8.h),
      TextFormField(
        controller: controller, keyboardType: keyboardType,
        maxLength: maxLength, maxLines: maxLines,
        validator: validator, onChanged: onChanged,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20.sp, color: AppColors.lightTextSecondary),
          filled: true, fillColor: AppColors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.lightDivider)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: AppColors.lightDivider)),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          counterText: '',
        ),
      ),
    ],);
  }
}