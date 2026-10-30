import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:toastification/toastification.dart';

/// Single OTP verification step for every phone-based journey.
///
/// Verification always calls `/auth/login-otp`:
/// * account exists  -> `AuthenticationSuccess` -> dashboard
/// * account missing -> `PhoneSignupRequired` (carries `signupToken`) -> address
///
/// Google-first signups pass their Google identity through as arguments so the
/// address step can create the account with `/auth/google-signup`.
class PhoneOtpVerificationScreen extends StatefulWidget {
  static const routeName = '/phone-otp-verification';

  const PhoneOtpVerificationScreen({super.key});

  @override
  PhoneOtpVerificationScreenState createState() =>
      PhoneOtpVerificationScreenState();
}

class PhoneOtpVerificationScreenState
    extends State<PhoneOtpVerificationScreen> {
  final _otpController = TextEditingController(text: '');

  String? _phone;
  String? _googleEmail;
  String? _googleId;
  String? _photoUrl;
  bool _isGoogleSignup = false;
  bool _isVerifying = false;
  bool _canResend = false;
  int _resendCountdown = 30;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _phone = args['phone'] as String?;
      _googleEmail = args['googleEmail'] as String?;
      _googleId = args['googleId'] as String?;
      _photoUrl = args['photoUrl'] as String?;
      _isGoogleSignup = args['isGoogleSignup'] as bool? ?? false;
    }

    if (_phone == null || _phone!.isEmpty) {
      Navigator.pop(context);
      return;
    }

    _startResendCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    if (!mounted) return;
    setState(() {
      _canResend = false;
      _resendCountdown = 30;
    });

    Future<void>.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() => _canResend = true);
      }
    });
  }

  void _resendOtp() {
    if (!_canResend) return;

    context.read<AuthenticationBloc>().add(const ResendOTP());
    toastification.show(
      title: const Text('OTP Resent'),
      description: Text('A new OTP has been sent to $_phone'),
      type: ToastificationType.success,
    );
    _startResendCountdown();
  }

  void _verifyOtp() {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      toastification.show(
        title: const Text('Invalid OTP'),
        description: const Text('Please enter the 6-digit OTP'),
        type: ToastificationType.error,
      );
      return;
    }

    setState(() => _isVerifying = true);
    context.read<AuthenticationBloc>().add(
          PhoneOtpLogin(phone: _phone ?? '', otp: otp),
        );
  }

  void _onAuthState(AuthenticationState state) {
    if (state is AuthenticationSuccess) {
      setState(() => _isVerifying = false);
      toastification.show(
        title: const Text('Login Successful'),
        type: ToastificationType.success,
      );
      Navigator.pushNamedAndRemoveUntil(
          context, '/dashboard', (route) => false);
      return;
    }

    if (state is PhoneSignupRequired) {
      setState(() => _isVerifying = false);
      toastification.show(
        title: const Text('Phone Verified'),
        description: const Text('Now confirm your email address to finish.'),
        type: ToastificationType.success,
      );
      // Google signup already has a verified email from Google; the phone-first
      // flow must prove the email as well (email is mandatory at signup).
      Navigator.pushReplacementNamed(
        context,
        _isGoogleSignup ? '/address-entry' : '/signup-email-verification',
        arguments: <String, dynamic>{
          'phone': state.phone,
          'signupToken': state.signupToken,
          'isGoogleSignup': _isGoogleSignup,
          if (_googleEmail != null) 'email': _googleEmail,
          if (_googleId != null) 'googleId': _googleId,
          if (_photoUrl != null) 'photoUrl': _photoUrl,
        },
      );
      return;
    }

    if (state is AuthError) {
      setState(() => _isVerifying = false);
      toastification.show(
        title: const Text('Verification Failed'),
        description: Text(state.error),
        type: ToastificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await BackButtonHandler.handleBackPress(
          context: context,
          hasUnsavedChanges: _otpController.text.isNotEmpty,
          message:
              'Phone verification in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verify Phone Number'),
          backgroundColor: Colors.amber,
          centerTitle: true,
        ),
        body: BlocListener<AuthenticationBloc, AuthenticationState>(
          listenWhen: (previous, current) =>
              current is AuthenticationSuccess ||
              current is PhoneSignupRequired ||
              current is AuthError,
          listener: (context, state) => _onAuthState(state),
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Verify Your Phone Number',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "We've sent a 6-digit OTP to\n$_phone",
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Enter OTP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                PinInputTextField(
                  controller: _otpController,
                  autoFocus: true,
                  decoration: UnderlineDecoration(
                    textStyle: const TextStyle(fontSize: 20),
                    colorBuilder: PinListenColorBuilder(
                      Colors.amber,
                      Colors.green,
                    ),
                  ),
                  onSubmit: (_) => _verifyOtp(),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('otp_verify_button'),
                    onPressed: _isVerifying ? null : _verifyOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isVerifying
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Verify OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive the code?"),
                    const SizedBox(width: 8),
                    if (!_canResend)
                      Text(
                        'Resend in ${_resendCountdown}s',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _resendOtp,
                        child: const Text(
                          'Resend OTP',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
