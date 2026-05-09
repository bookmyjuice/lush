import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:toastification/toastification.dart';

class OTPSignUpScreen extends StatefulWidget {
  static const routeName = '/otpSignUpScreen';

  const OTPSignUpScreen({super.key});

  @override
  OTPSignUpScreenState createState() => OTPSignUpScreenState();
}

class OTPSignUpScreenState extends State<OTPSignUpScreen> {
  final TextEditingController otpController = TextEditingController(text: '');
  int resendCountdown = 0;

  @override
  void initState() {
    super.initState();
    // Start resend countdown (30 seconds)
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          resendCountdown = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  void _resendOTP() {
    BlocProvider.of<AuthenticationBloc>(context).add(ResendOTP());
    setState(() {
      resendCountdown = 30;
    });
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        setState(() {
          resendCountdown = 0;
        });
      }
    });
  }

  void _verifyOTP() {
    if (otpController.text.isEmpty || otpController.text.length != 6) {
      toastification.show(
        title: const Text('Invalid OTP'),
        description: const Text('Please enter a valid 6-digit OTP'),
        type: ToastificationType.error,
      );
      return;
    }

    BlocProvider.of<AuthenticationBloc>(context).add(
      VerifyOTP(otp: otpController.text),
    );
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
            current is OTPVerificationFailed ||
            current is OTPVerificationSuccess,
        listener: (context, state) {
          if (state is OTPVerificationFailed) {
            toastification.show(
              title: const Text('Verification Failed'),
              description: Text(state.error),
              type: ToastificationType.error,
            );
          } else if (state is OTPVerificationSuccess) {
            // Navigate to SignUpScreen with phone prefilled
            Navigator.of(context).pushReplacementNamed("/signUpScreen");
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
                  Icons.verified_user,
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
                const Text(
                  'We have sent a 6-digit OTP to your phone number.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                Text(
                  'Enter OTP',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 20),
                PinInputTextField(
                  pinLength: 6,
                  controller: otpController,
                  autoFocus: true,
                  decoration: UnderlineDecoration(
                    textStyle: const TextStyle(fontSize: 20),
                    colorBuilder: PinListenColorBuilder(
                      Colors.amber,
                      Colors.green,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Didn't receive the code?"),
                    const SizedBox(width: 8),
                    if (resendCountdown > 0)
                      Text(
                        'Resend in ${resendCountdown}s',
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
