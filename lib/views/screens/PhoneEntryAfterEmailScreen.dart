import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:toastification/toastification.dart';

/// Step 2a (Email-first): Phone Entry Screen after Email Verification
/// User enters phone number to receive OTP
class PhoneEntryAfterEmailScreen extends StatefulWidget {
  static const routeName = '/phone-entry-after-email';

  const PhoneEntryAfterEmailScreen({super.key});

  @override
  PhoneEntryAfterEmailScreenState createState() =>
      PhoneEntryAfterEmailScreenState();
}

class PhoneEntryAfterEmailScreenState
    extends State<PhoneEntryAfterEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  late String _email;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      _email = args;
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final phone = _phoneController.text.trim();

      // Send OTP to phone
      BlocProvider.of<AuthenticationBloc>(context).add(
        SendOTP(phoneNumber: phone),
      );

      // Navigate to OTP verification screen
      Navigator.pushNamed(
        context,
        '/phone-otp-verification',
        arguments: {
          'email': _email,
          'phone': phone,
        },
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Phone Number'),
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
                  'We\'ll send you an OTP to verify your phone number.',
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
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onContinue,
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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
