import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:toastification/toastification.dart';

/// Step 2 (Both flows): Phone OTP Verification Screen
/// User enters 6-digit OTP sent to their phone.
/// BR-011: If this is a login flow (not signup), after OTP verification,
/// the screen attempts to login the user. If user doesn't exist, it starts signup flow.
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
  String? _email;
  String? _phone;
  String? _firstName;
  String? _lastName;
  int _resendCountdown = 30;
  bool _canResend = false;
  bool _isGoogleSignup = false;
  bool _isLoginFlow = false;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _email = args['email'] as String?;
      _phone = args['phone'] as String?;
      _firstName = args['firstName'] as String?;
      _lastName = args['lastName'] as String?;
      _isGoogleSignup = args['isGoogleSignup'] as bool? ?? false;
      _isLoginFlow = args['isLoginFlow'] as bool? ?? false;
    }

    if (_phone == null || _phone!.isEmpty) {
      Navigator.pop(context);
    }

    _startResendCountdown();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() {
      _canResend = false;
      _resendCountdown = 30;
    });

    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _resendOTP() {
    if (!_canResend) return;

    BlocProvider.of<AuthenticationBloc>(context).add(
      const ResendOTP(),
    );

    toastification.show(
      title: const Text('OTP Resent'),
      description: Text('A new OTP has been sent to $_phone'),
      type: ToastificationType.success,
    );

    _startResendCountdown();
  }

  Future<void> _verifyOTP() async {
    final otp = _otpController.text.trim();

    if (otp.isEmpty || otp.length != 6) {
      toastification.show(
        title: const Text('Invalid OTP'),
        description: const Text('Please enter the 6-digit OTP'),
        type: ToastificationType.error,
      );
      return;
    }

    if (_isLoginFlow) {
      // BR-011: Login flow - verify OTP and attempt login
      await _attemptPhoneLogin(otp);
    } else {
      // Signup flow - use BLoC for verification
      BlocProvider.of<AuthenticationBloc>(context).add(
        VerifyOTP(otp: otp),
      );
    }
  }

  Future<void> _attemptPhoneLogin(String otp) async {
    setState(() => _isLoading = true);

    final userRepository = UserRepository();
    final result = await userRepository.loginViaPhoneOtp(_phone!, otp);

    setState(() => _isLoading = false);

    if (result['type'] == 'login_success') {
      // User exists - login successful
      toastification.show(
        title: const Text('Login Successful'),
        type: ToastificationType.success,
      );
      // Navigate to dashboard and clear navigation stack
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (route) => false);
      }
    } else if (result['type'] == 'signup_required') {
      // User doesn't exist - start signup with pre-filled phone
      toastification.show(
        title: const Text('Phone Verified'),
        description: const Text('No account found. Please complete signup.'),
        type: ToastificationType.info,
      );
      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/email-entry-after-phone',
          arguments: _phone,
        );
      }
    } else {
      // Error
      toastification.show(
        title: const Text('Login Failed'),
        description: Text((result['error'] as String?) ?? 'Unknown error'),
        type: ToastificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Phone Number'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listenWhen: (previous, current) =>
            current is OTPVerificationSuccess ||
            current is OTPVerificationFailed,
        listener: (context, state) {
          if (state is OTPVerificationSuccess) {
            toastification.show(
              title: const Text('Phone Verified'),
              type: ToastificationType.success,
            );

            if (_isGoogleSignup) {
              // Google signup: both email and phone verified, go to address
              Navigator.pushReplacementNamed(
                context,
                '/address-entry',
                arguments: {
                  'email': _email,
                  'phone': _phone,
                  'firstName': _firstName,
                  'lastName': _lastName,
                },
              );
            } else if (_email != null && _email!.isNotEmpty) {
              // Email-first flow: both verified, go to address
              Navigator.pushReplacementNamed(
                context,
                '/address-entry',
                arguments: {
                  'email': _email,
                  'phone': _phone,
                  'firstName': null,
                  'lastName': null,
                },
              );
            } else {
              // Phone-first flow: phone verified, now collect email
              Navigator.pushReplacementNamed(
                context,
                '/email-entry-after-phone',
                arguments: _phone,
              );
            }
          } else if (state is OTPVerificationFailed) {
            toastification.show(
              title: const Text('Verification Failed'),
              description: Text(state.error),
              type: ToastificationType.error,
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.phone_android,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Verify Your Phone Number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'We\'ve sent a 6-digit OTP to\n$_phone',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Enter OTP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                PinInputTextField(
                  pinLength: 6,
                  controller: _otpController,
                  autoFocus: true,
                  decoration: UnderlineDecoration(
                    textStyle: const TextStyle(fontSize: 20),
                    colorBuilder: PinListenColorBuilder(
                      Colors.amber,
                      Colors.green,
                    ),
                  ),
                  onSubmit: (code) {
                    _verifyOTP();
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
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
                    const Text('Didn\'t receive the code?'),
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
                        onTap: _resendOTP,
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
