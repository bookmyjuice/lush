import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:lush/views/models/firebase_phone_auth.dart';
import 'package:toastification/toastification.dart';

/// Step 2b (Phone-first): Phone Entry Screen
/// User enters phone number and receives OTP via backend or Firebase
class PhoneSignupScreen extends StatefulWidget {
  static const routeName = '/phone-signup';

  const PhoneSignupScreen({super.key});

  @override
  PhoneSignupScreenState createState() => PhoneSignupScreenState();
}

class PhoneSignupScreenState extends State<PhoneSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoadingBackend = false;
  bool _isLoadingFirebase = false;
  final _firebasePhoneAuth = FirebasePhoneAuth.instance;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  /// Send OTP via backend (existing flow)
  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoadingBackend = true);

      final phone = _phoneController.text.trim();

      // Send OTP to phone via backend
      BlocProvider.of<AuthenticationBloc>(context).add(
        SendOTP(phoneNumber: phone),
      );

      // Navigate to OTP verification screen
      Navigator.pushNamed(
        context,
        '/phone-otp-verification',
        arguments: {
          'email': null,
          'phone': phone,
        },
      );

      setState(() => _isLoadingBackend = false);
    }
  }

  /// Send OTP via Firebase Phone Auth (alternative flow)
  Future<void> _onFirebaseVerify() async {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text.trim();
      if (phone.length != 10) return;

      // Format to E.164 for Firebase
      final e164Phone = '+91$phone';

      setState(() => _isLoadingFirebase = true);

      await _firebasePhoneAuth.initiatePhoneVerification(
        phone: e164Phone,
        onCodeSent: (verificationId) {
          setState(() => _isLoadingFirebase = false);
          // Navigate to OTP verification screen with Firebase flag
          Navigator.pushNamed(
            context,
            '/phone-otp-verification',
            arguments: {
              'email': null,
              'phone': phone,
              'isFirebaseAuth': true,
              'verificationId': verificationId,
            },
          );
        },
        onError: (error) {
          setState(() => _isLoadingFirebase = false);
          toastification.show(
            title: const Text('Firebase Verification Failed'),
            description: Text(error),
            type: ToastificationType.error,
          );
        },
        onTimeout: () {
          setState(() => _isLoadingFirebase = false);
          toastification.show(
            title: const Text('Timeout'),
            description: const Text('SMS delivery timed out. Please try again.'),
            type: ToastificationType.error,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final hasText = _phoneController.text.isNotEmpty;
        final shouldPop = await BackButtonHandler.handleBackPress(
          context: context,
          hasUnsavedChanges: hasText,
          message: 'Phone entry in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Sign up with Phone'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is OTPSent) {
            toastification.show(
              title: const Text('OTP Sent'),
              description: const Text('Check your phone for the verification code'),
              type: ToastificationType.success,
            );
          } else if (state is OTPSendFailed) {
            toastification.show(
              title: const Text('Failed to Send OTP'),
              description: Text(state.error),
              type: ToastificationType.error,
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Enter your phone number',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose a verification method for your phone number.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    maxLength: 10,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(10),
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone number is required';
                      }
                      if (value.length != 10) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: const Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: '9876543210',
                      counterText: '',
                    ),
                    onFieldSubmitted: (_) => _onContinue(),
                  ),
                ),
                const SizedBox(height: 24),
                // Backend OTP button (existing flow)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoadingBackend || _isLoadingFirebase ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoadingBackend
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send OTP',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                // Firebase Phone Auth button (alternative flow)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: _isLoadingBackend || _isLoadingFirebase ? null : _onFirebaseVerify,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
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
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Back to signup methods'),
                  ),
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
