import 'package:flutter/material.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/utils/font_utils.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:toastification/toastification.dart';

/// BR-009 Method 1: Reset password via mobile OTP
/// Flow: Enter OTP → Verify → Enter new password → Submit
class ResetPasswordMobileScreen extends StatefulWidget {
  @override
  _ResetPasswordMobileScreenState createState() => _ResetPasswordMobileScreenState();
}

class _ResetPasswordMobileScreenState extends State<ResetPasswordMobileScreen> {
  final UserRepository userRepository = UserRepository();
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _phone = '';
  String _otp = '';
  bool _isOtpVerified = false;
  bool _isLoading = false;
  bool _isPasswordValid = false;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null && args['phone'] != null) {
        setState(() => _phone = args['phone'].toString());
      }
    });
    _startResendTimer();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendCountdown = 30;
      _canResend = false;
    });
    Future.delayed(Duration(seconds: 30), () {
      if (mounted) setState(() => _canResend = true);
    });
  }

  Future<void> _verifyOtp() async {
    if (_otp.length != 6) {
      _showToast('Invalid OTP', 'Please enter a 6-digit code', ToastificationType.error);
      return;
    }

    setState(() => _isLoading = true);

    final response = await userRepository.verifyOTP(_otp, phone: _phone);

    setState(() => _isLoading = false);

    if (response.contains('Success') || response.contains('verified')) {
      _showToast('OTP Verified', 'You can now set a new password', ToastificationType.success);
      setState(() => _isOtpVerified = true);
    } else {
      _showToast('Invalid OTP', response, ToastificationType.error);
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isLoading = true);

    final response = await userRepository.sendOTP(_phone);

    setState(() => _isLoading = false);

    if (response.contains('Success') || response.contains('sent')) {
      _showToast('OTP Resent', 'A new code has been sent to your phone', ToastificationType.success);
      _startResendTimer();
    } else {
      _showToast('Failed', response, ToastificationType.error);
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showToast('Password Mismatch', 'Passwords do not match', ToastificationType.error);
      return;
    }

    setState(() => _isLoading = true);

    final response = await userRepository.resetPasswordViaMobile(
      phone: _phone,
      otp: _otp,
      newPassword: password,
    );

    setState(() => _isLoading = false);

    if (response.contains('Success') || response.contains('reset')) {
      _showToast('Password Reset', 'Your password has been updated successfully', ToastificationType.success);
      Future.delayed(Duration(seconds: 1), () {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      });
    } else {
      _showToast('Failed', response, ToastificationType.error);
    }
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
        title: Text(_isOtpVerified ? 'Set New Password' : 'Verify OTP'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.0),
          child: _isOtpVerified ? _buildPasswordSection() : _buildOtpSection(),
        ),
      ),
    );
  }

  Widget _buildOtpSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 30),
        Icon(Icons.phone_android, size: 80, color: Colors.amber),
        SizedBox(height: 20),
        Text(
          'Verify Your Phone',
          style: FontUtils.heading1(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          _phone.isNotEmpty ? 'Code sent to $_phone' : 'Enter the 6-digit code',
          style: FontUtils.bodyText(color: Colors.grey[600], fontSize: 14),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 30),
        Text('Enter OTP', style: FontUtils.bodyText(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 16),
        PinInputTextField(
          pinLength: 6,
          autoFocus: true,
          decoration: UnderlineDecoration(
            colorBuilder: PinListenColorBuilder(Colors.amber, Colors.green),
            textStyle: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          onSubmit: (pin) {
            setState(() => _otp = pin);
            _verifyOtp();
          },
        ),
        SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _verifyOtp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text('Verify OTP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Didn't receive the code? ", style: TextStyle(color: Colors.grey[600])),
            _canResend
                ? GestureDetector(
                    onTap: _resendOtp,
                    child: Text('Resend OTP',
                        style: TextStyle(color: Colors.amber[700], fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  )
                : Text('Resend in ${_resendCountdown}s', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create New Password',
            style: FontUtils.heading1(color: Colors.black87, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Your new password must meet all requirements below',
            style: FontUtils.bodyText(color: Colors.grey[600], fontSize: 14),
          ),
          SizedBox(height: 24),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'New Password *',
              prefixIcon: Icon(Icons.lock_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Password is required' : null,
          ),
          SizedBox(height: 16),
          FlutterPwValidator(
            controller: _passwordController,
            minLength: 8,
            uppercaseCharCount: 1,
            lowercaseCharCount: 1,
            numericCharCount: 2,
            specialCharCount: 1,
            normalCharCount: 3,
            width: MediaQuery.of(context).size.width,
            height: 180,
            onSuccess: () => setState(() => _isPasswordValid = true),
            onFail: () => setState(() => _isPasswordValid = false),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: 'Confirm Password *',
              prefixIcon: Icon(Icons.lock_outlined),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (value) => value!.isEmpty ? 'Please confirm your password' : null,
          ),
          SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (_isLoading || !_isPasswordValid) ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Reset Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Password Requirements:',
            style: FontUtils.bodyText(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          _buildRequirement('At least 8 characters'),
          _buildRequirement('At least 1 uppercase letter'),
          _buildRequirement('At least 1 lowercase letter'),
          _buildRequirement('At least 2 numbers'),
          _buildRequirement('At least 1 special character'),
          _buildRequirement('No spaces'),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, size: 16, color: Colors.grey),
          SizedBox(width: 8),
          Text(text, style: FontUtils.captionText(color: Colors.grey[600]!, fontSize: 13)),
        ],
      ),
    );
  }
}
