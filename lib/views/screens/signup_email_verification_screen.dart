import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:toastification/toastification.dart';

/// Signup step 2 (phone-first flow): verify the customer's email.
///
/// Email is mandatory at signup, so after the phone OTP the customer must prove
/// ownership of an address before the account exists. The backend returns a
/// short-lived `emailVerificationToken` on success; it is carried to
/// `/address-entry` and redeemed by `/auth/phone-signup`.
class SignupEmailVerificationScreen extends StatefulWidget {
  static const routeName = '/signup-email-verification';

  const SignupEmailVerificationScreen({super.key});

  @override
  State<SignupEmailVerificationScreen> createState() =>
      SignupEmailVerificationScreenState();
}

class SignupEmailVerificationScreenState
    extends State<SignupEmailVerificationScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  late final UserRepository _userRepository;

  String? _phone;
  String? _signupToken;
  String _codeSentTo = '';
  bool _isSending = false;
  bool _isVerifying = false;

  /// Mirrors the backend resend cooldown so the button cannot fail with a 429.
  static const int _resendCooldownSeconds = 30;
  int _secondsUntilResend = 0;
  Timer? _cooldownTimer;

  bool get _codeStep => _codeSentTo.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _userRepository = getIt.get<UserRepository>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _phone = args?['phone'] as String?;
    _signupToken = args?['signupToken'] as String?;
    final prefillEmail = args?['email'] as String?;
    if (prefillEmail != null && prefillEmail.isNotEmpty) {
      _emailController.text = prefillEmail;
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldownTimer?.cancel();
    setState(() => _secondsUntilResend = _resendCooldownSeconds);
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _secondsUntilResend--;
        if (_secondsUntilResend <= 0) {
          timer.cancel();
          _secondsUntilResend = 0;
        }
      });
    });
  }

  Future<void> _sendCode() async {
    if (_isSending) return;
    if (!_emailFormKey.currentState!.validate()) return;

    final email = _emailController.text.trim().toLowerCase();
    setState(() => _isSending = true);
    final message = await _userRepository.sendEmailVerification(email);
    if (!mounted) return;
    setState(() => _isSending = false);

    if (message.startsWith('Error')) {
      toastification.show(
        title: const Text('Could not send code'),
        description: Text(_cleanMessage(message)),
        type: ToastificationType.error,
      );
      return;
    }

    setState(() {
      _codeSentTo = email;
      _codeController.clear();
    });
    _startCooldown();
    toastification.show(
      title: const Text('Code sent'),
      description: Text('Enter the 6-digit code we sent to $email'),
      type: ToastificationType.success,
    );
  }

  Future<void> _verifyCode() async {
    if (_isVerifying) return;
    final code = _codeController.text.trim();
    if (code.length != 6) {
      toastification.show(
        title: const Text('Enter the 6-digit code'),
        type: ToastificationType.warning,
      );
      return;
    }

    setState(() => _isVerifying = true);
    final result = await _userRepository.verifyEmailCode(_codeSentTo, code);
    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (result['status'] != 'success') {
      toastification.show(
        title: const Text('Email not verified'),
        description: Text(
          _cleanMessage(
              result['error'] as String? ?? 'Invalid or expired code'),
        ),
        type: ToastificationType.error,
      );
      return;
    }

    final verifiedEmail = result['email'] as String? ?? _codeSentTo;
    final emailVerificationToken =
        result['emailVerificationToken'] as String? ?? '';
    if (emailVerificationToken.isEmpty) {
      toastification.show(
        title: const Text('Email not verified'),
        description: const Text('Please request a new code and try again.'),
        type: ToastificationType.error,
      );
      return;
    }

    toastification.show(
      title: const Text('Email verified'),
      description: Text('$verifiedEmail is confirmed'),
      type: ToastificationType.success,
    );

    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/address-entry',
      arguments: <String, dynamic>{
        'phone': _phone,
        'signupToken': _signupToken,
        'email': verifiedEmail,
        'emailVerificationToken': emailVerificationToken,
        'isGoogleSignup': false,
      },
    );
  }

  /// Server messages are prefixed with "Error: "; keep the user-facing part.
  String _cleanMessage(String message) =>
      message.replaceFirst(RegExp(r'^Error:\s*'), '');

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await BackButtonHandler.handleBackPress(
          context: context,
          hasUnsavedChanges: _emailController.text.isNotEmpty,
          message:
              'Email verification in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Email'),
          backgroundColor: AppColors.primaryOrange,
          centerTitle: true,
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 16),
              const Text(
                'Add your email address',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                _codeStep
                    ? 'Enter the 6-digit code we emailed to $_codeSentTo.'
                    : 'Your email is required for invoices and receipts. '
                        'We will send a 6-digit code to confirm it.',
                style: const TextStyle(fontSize: 14, color: AppColors.darkGrey),
              ),
              const SizedBox(height: 24),
              Form(
                key: _emailFormKey,
                child: TextFormField(
                  key: const Key('signup_email_field'),
                  controller: _emailController,
                  enabled: !_codeStep,
                  keyboardType: TextInputType.emailAddress,
                  autofocus: !_codeStep,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'you@example.com',
                    prefixIcon: const Icon(Icons.mail_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) {
                      return 'Email is required';
                    }
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                        .hasMatch(email)) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) {
                    if (!_codeStep) _sendCode();
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (!_codeStep) _buildSendButton(),
              if (_codeStep) ..._buildCodeStep(),
              const SizedBox(height: 16),
              const Text(
                'We only use this address for order receipts, invoices and '
                'important account notices.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        key: const Key('send_email_code_button'),
        onPressed: _isSending ? null : _sendCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isSending
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Send code',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  List<Widget> _buildCodeStep() {
    return [
      TextField(
        key: const Key('signup_email_code_field'),
        controller: _codeController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        autofocus: true,
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
          fontSize: 24,
          letterSpacing: 12,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          labelText: 'Verification code',
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (_) => _verifyCode(),
      ),
      const SizedBox(height: 16),
      SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          key: const Key('verify_email_code_button'),
          onPressed: _isVerifying ? null : _verifyCode,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryOrange,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isVerifying
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  'Verify email',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
            key: const Key('resend_email_code_button'),
            onPressed: _secondsUntilResend > 0 || _isSending ? null : _sendCode,
            child: Text(
              _secondsUntilResend > 0
                  ? 'Resend in ${_secondsUntilResend}s'
                  : 'Resend code',
            ),
          ),
          TextButton(
            key: const Key('change_email_button'),
            onPressed: () => setState(() {
              _codeSentTo = '';
              _codeController.clear();
              _cooldownTimer?.cancel();
              _secondsUntilResend = 0;
            }),
            child: const Text('Change email'),
          ),
        ],
      ),
    ];
  }
}
