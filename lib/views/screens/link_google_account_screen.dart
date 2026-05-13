import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:toastification/toastification.dart';
import 'package:lush/theme/app_colors.dart';

/// #2 UX: Link Google Account to Existing User
/// Shown when Google Sign-In doesn't find a matching account.
/// User enters phone → OTP → links Google ID to existing account.
class LinkGoogleAccountScreen extends StatefulWidget {
  final String googleEmail;
  final String googleFirstName;
  final String googleLastName;
  final String googleId;
  final String? photoUrl;

  const LinkGoogleAccountScreen({
    super.key,
    required this.googleEmail,
    required this.googleFirstName,
    required this.googleLastName,
    required this.googleId,
    this.photoUrl,
  });

  @override
  _LinkGoogleAccountScreenState createState() => _LinkGoogleAccountScreenState();
}

class _LinkGoogleAccountScreenState extends State<LinkGoogleAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _isLoading = false;
  bool _otpSent = false;
  bool _otpVerified = false;
  int _resendCountdown = 30;
  bool _canResend = false;
  final _userRepository = UserRepository();

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
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

    setState(() {
      _isLoading = false;
      _otpSent = true;
    });

    if (response.contains('Success') || response.contains('sent')) {
      _showToast('OTP Sent', 'Enter the 6-digit code sent to $phone', ToastificationType.success);
      _startResendTimer();
    } else {
      _showToast('Failed', response, ToastificationType.error);
    }
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      _showToast('Invalid OTP', 'Please enter a 6-digit code', ToastificationType.error);
      return;
    }

    setState(() => _isLoading = true);

    final response = await _userRepository.verifyOTP(otp, phone: _phoneController.text.trim());

    setState(() => _isLoading = false);

    if (response.contains('Success') || response.contains('verified')) {
      setState(() => _otpVerified = true);
      _linkAccount();
    } else {
      _showToast('Invalid OTP', response, ToastificationType.error);
    }
  }

  Future<void> _linkAccount() async {
    setState(() => _isLoading = true);

    try {
      final response = await _userRepository.linkGoogleAccount(
        phone: _phoneController.text.trim(),
        otp: _otpController.text.trim(),
        googleId: widget.googleId,
        photoUrl: widget.photoUrl,
      );

      setState(() => _isLoading = false);

      if (response['type'] == 'login_success') {
        _showToast('Account Linked', 'Google account linked successfully', ToastificationType.success);
        // Navigate to dashboard and clear navigation stack
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
        }
      } else {
        _showToast('Link Failed', (response['error'] as String?) ?? 'Failed to link account', ToastificationType.error);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showToast('Error', 'Failed to link Google account: $e', ToastificationType.error);
    }
  }

  Future<void> _resendOTP() async {
    setState(() => _isLoading = true);

    final response = await _userRepository.sendOTP(_phoneController.text.trim());

    setState(() => _isLoading = false);

    if (response.contains('Success') || response.contains('sent')) {
      _showToast('OTP Resent', 'A new code has been sent', ToastificationType.success);
      _startResendTimer();
    } else {
      _showToast('Failed', response, ToastificationType.error);
    }
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) setState(() => _canResend = true);
    });
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
        title: const Text('Link Google Account'),
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
                const SizedBox(height: 30),
                Icon(Icons.link, size: 80, color: AppColors.primaryOrangeDark),
                const SizedBox(height: 20),
                Text(
                  'Link Google Account',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
                ),
                const SizedBox(height: 8),
                Text(
                  'No account found with ${widget.googleEmail}. Enter the phone number of your existing account to link.',
                  style: TextStyle(fontSize: 14, color: AppColors.lightTextSecondary, fontFamily: 'Roboto'),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                
                // Phone input
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  enabled: !_otpSent,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Phone Number *',
                    hintText: 'Enter your registered phone number',
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
                const SizedBox(height: 20),

                // OTP input (shown after OTP sent)
                if (_otpSent) ...[
                  Text(
                    'Enter OTP',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.lightTextPrimary, fontFamily: 'Roboto'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: 'Enter 6-digit OTP',
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
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Didn't receive the code? ", style: TextStyle(color: AppColors.lightTextSecondary)),
                      _canResend
                          ? GestureDetector(
                              onTap: _resendOTP,
                              child: Text('Resend OTP',
                                  style: TextStyle(color: AppColors.primaryOrangeDark, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                            )
                          : Text('Resend in ${_resendCountdown}s', style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_otpSent ? _verifyOTP : _sendOTP),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: AppColors.white)
                        : Text(
                            _otpSent ? 'Verify & Link Account' : 'Send OTP',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
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



