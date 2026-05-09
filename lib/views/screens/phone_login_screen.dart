import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/utils/font_utils.dart';
import 'package:toastification/toastification.dart';

/// BR-011: Phone Sign-In Screen
/// User enters phone number, receives OTP, then either logs in or starts signup
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  _PhoneLoginScreenState createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  final _userRepository = UserRepository();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    if (!isValidPhone(phone)) {
      _showToast('Invalid Phone', 'Enter a valid 10-digit Indian number', ToastificationType.error);
      return;
    }

    setState(() => _isLoading = true);

    final response = await _userRepository.sendOTP(phone);

    setState(() => _isLoading = false);

    if (response.contains('Success') || response.contains('sent')) {
      // Navigate to OTP verification with login flow flag
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
        backgroundColor: Colors.amber,
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
                Icon(Icons.phone_android, size: 80, color: Colors.amber[700]),
                const SizedBox(height: 24),
                Text(
                  'Enter Your Phone Number',
                  style: FontUtils.heading1(
                    color: Colors.black87,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'We\'ll send a 6-digit OTP to verify your number',
                  style: FontUtils.bodyText(color: Colors.grey[600], fontSize: 14),
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
                    prefixIcon: Icon(Icons.phone, color: Colors.amber[700]),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.amber, width: 2),
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
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send OTP',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Back to Login',
                    style: FontUtils.bodyText(
                      color: Colors.amber[700],
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
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
