import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/widgets/app_text_field.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:toastification/toastification.dart';

/// Single phone entry point for both sign-in and sign-up.
///
/// Replaces `/phone-login` and `/phone-signup`. There is exactly one backend
/// OTP path (`/auth/send-otp` -> `/auth/login-otp`); whether the number belongs
/// to an existing account is decided after verification, not here.
class PhoneEntryScreen extends StatefulWidget {
  static const routeName = '/phone-entry';

  const PhoneEntryScreen({super.key});

  @override
  PhoneEntryScreenState createState() => PhoneEntryScreenState();
}

class PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  /// True only while this screen waits for its own `SendOTP` result. Prevents
  /// a resend on the OTP screen from stacking a second route here.
  bool _awaitingOtp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    setState(() => _awaitingOtp = true);
    context.read<AuthenticationBloc>().add(SendOTP(phoneNumber: phone));
  }

  void _onAuthState(AuthenticationState state) {
    if (!_awaitingOtp) return;

    if (state is OTPSent) {
      setState(() => _awaitingOtp = false);
      Navigator.pushNamed(
        context,
        '/phone-otp-verification',
        arguments: {'phone': state.phoneNumber},
      );
      return;
    }

    if (state is OTPSendFailed) {
      setState(() => _awaitingOtp = false);
      toastification.show(
        title: const Text('Could not send OTP'),
        description: Text(state.error),
        type: ToastificationType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Continue with Phone'),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listenWhen: (previous, current) =>
            current is OTPSent || current is OTPSendFailed,
        listener: (context, state) => _onAuthState(state),
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Enter your mobile number',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'We will text you a 6-digit code. New numbers create an '
                  'account; existing numbers sign you in.',
                  style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  key: const Key('phone_entry_field'),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  autofocus: true,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '9876543210',
                    prefixText: '+91 ',
                    counterText: '',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
                  onFieldSubmitted: (_) => _sendOtp(),
                ),
                const SizedBox(height: 24),
                _buildSendButton(),
                const SizedBox(height: 16),
                const Text(
                  'By continuing you agree to receive a one-time verification '
                  'code on this number.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppColors.darkGrey),
                ),
              ],
            ),
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
        key: const Key('phone_entry_send_otp'),
        onPressed: _awaitingOtp ? null : _sendOtp,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryOrange,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _awaitingOtp
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              )
            : const Text(
                'Send OTP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
