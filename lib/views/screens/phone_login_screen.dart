import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/views/models/firebase_phone_auth.dart';
import 'package:toastification/toastification.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_text_styles.dart';

/// BR-011: Phone Sign-In Screen
/// User enters phone number, receives OTP via backend or Firebase, then either logs in or starts signup
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoadingBackend = false;
  bool _isLoadingFirebase = false;
  late final UserRepository _userRepository;
  final _firebasePhoneAuth = FirebasePhoneAuth.instance;

  @override
  void initState() {
    super.initState();
    _userRepository = getIt.get<UserRepository>();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Send OTP via backend (existing flow)
  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    if (!isValidPhone(phone)) {
      _showToast('Invalid Phone', 'Enter a valid 10-digit Indian number', ToastificationType.error);
      return;
    }

    setState(() => _isLoadingBackend = true);

    final response = await _userRepository.sendOTP(phone);

    setState(() => _isLoadingBackend = false);

    if (response == "OTP_SENT" || response.contains('Success') || response.contains('sent')) {
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/phone-otp-verification',
          arguments: {
            'phone': phone,
            'isLoginFlow': true,
          },
        );
      }
    } else {
      _showToast('Failed to Send OTP', response, ToastificationType.error);
    }
  }

  /// Send OTP via Firebase Phone Auth (alternative flow)
  Future<void> _sendFirebaseOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    if (!isValidPhone(phone)) {
      _showToast('Invalid Phone', 'Enter a valid 10-digit Indian number', ToastificationType.error);
      return;
    }

    // Format phone to E.164 for Firebase
    final e164Phone = '+91$phone';

    setState(() => _isLoadingFirebase = true);

    await _firebasePhoneAuth.initiatePhoneVerification(
      phone: e164Phone,
      onCodeSent: (verificationId) {
        setState(() => _isLoadingFirebase = false);
        // Navigate to the same OTP screen but pass Firebase verification ID
        if (mounted) {
          Navigator.pushNamed(
            context,
            '/phone-otp-verification',
            arguments: {
              'phone': phone,
              'isLoginFlow': true,
              'isFirebaseAuth': true,
              'verificationId': verificationId,
            },
          );
        }
      },
      onError: (error) {
        setState(() => _isLoadingFirebase = false);
        _showToast('Firebase Verification Failed', error, ToastificationType.error);
      },
      onTimeout: () {
        setState(() => _isLoadingFirebase = false);
        _showToast('Timeout', 'SMS delivery timed out. Please try again.', ToastificationType.error);
      },
    );
  }

  bool isValidPhone(String phone) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone);
  }

  void _showToast(String title, String message, ToastificationType type) {
    toastification.show(
      title: Text(title),
      description: Text(message),
      type: type,
      closeButton: ToastCloseButton(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In with Phone'),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Icon(Icons.phone_android, size: 80, color: AppColors.primaryOrangeDark),
                const SizedBox(height: 24),
                Text(
                  'Enter Your Phone Number',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how to verify your number',
                  style: TextStyle(fontSize: 14, color: AppColors.lightTextSecondary, fontFamily: 'Roboto'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: 'Enter 10-digit mobile number',
                    prefixIcon: Icon(Icons.phone, color: AppColors.primaryOrangeDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.lightDivider!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primaryOrange, width: 2),
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Phone number is required';
                    }
                    if (!isValidPhone(value)) {
                      return 'Enter a valid 10-digit Indian number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                // Backend OTP button (existing flow)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoadingBackend || _isLoadingFirebase ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoadingBackend
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : const Text(
                            'Send OTP via SMS',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Firebase Phone Auth button (alternative flow)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingBackend || _isLoadingFirebase ? null : _sendFirebaseOTP,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.info,
                      side: const BorderSide(color: AppColors.info),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: _isLoadingFirebase
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.verified_user),
                    label: Text(
                      _isLoadingFirebase ? 'Sending...' : 'Verify via Firebase',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryOrangeDark, fontFamily: 'Roboto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
