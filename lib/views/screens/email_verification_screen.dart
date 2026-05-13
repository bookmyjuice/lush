import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:toastification/toastification.dart';

/// Step 2a (Email-first): Email Verification Screen
/// User enters 6-digit verification code sent to their email
class EmailVerificationScreen extends StatefulWidget {
  static const routeName = '/email-verification';

  const EmailVerificationScreen({super.key});

  @override
  EmailVerificationScreenState createState() => EmailVerificationScreenState();
}

class EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _otpController = TextEditingController(text: '');
  late String _email;
  int _resendCountdown = 30;
  bool _canResend = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get email from arguments
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      _email = args;
    } else {
      Navigator.pop(context);
    }

    // Start resend countdown
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

  void _resendCode() {
    if (!_canResend) return;

    // Resend verification code
    BlocProvider.of<AuthenticationBloc>(context).add(
      EnterEmail(email: _email),
    );

    toastification.show(
      title: const Text('Verification Code Resent'),
      description: Text('A new code has been sent to $_email'),
      type: ToastificationType.success,
    );

    _startResendCountdown();
  }

  void _verifyCode() {
    final code = _otpController.text.trim();

    if (code.isEmpty || code.length != 6) {
      toastification.show(
        title: const Text('Invalid Code'),
        description: const Text('Please enter the 6-digit verification code'),
        type: ToastificationType.error,
      );
      return;
    }

    // Verify email code
    BlocProvider.of<AuthenticationBloc>(context).add(
      VerifyEmail(email: _email, verificationCode: code),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final hasOtp = _otpController.text.isNotEmpty;
        final shouldPop = await BackButtonHandler.handleBackPress(
          context: context,
          hasUnsavedChanges: hasOtp,
          message: 'Email verification in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listenWhen: (previous, current) =>
            current is EmailVerified || current is EmailVerificationFailed,
        listener: (context, state) {
          if (state is EmailVerified) {
            toastification.show(
              title: const Text('Email Verified'),
              type: ToastificationType.success,
            );
            // Navigate to phone entry screen
            Navigator.pushReplacementNamed(
              context,
              '/phone-entry-after-email',
              arguments: _email,
            );
          } else if (state is EmailVerificationFailed) {
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
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: Colors.amber,
                ),
                const SizedBox(height: 30),
                const Text(
                  'Verify Your Email',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'We\'ve sent a 6-digit verification code to\n$_email',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                const Text(
                  'Enter Verification Code',
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
                    _verifyCode();
                  },
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _verifyCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Verify Email',
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
                        onTap: _resendCode,
                        child: const Text(
                          'Resend Code',
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
      ),
    );
  }
}
