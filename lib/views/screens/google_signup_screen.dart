import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_theme.dart';
import 'package:lush/widgets/app_text_field.dart';
import 'package:toastification/toastification.dart';

/// Google signup, step 1 of 2: collect the delivery phone number.
///
/// The Google identity (email, name, id, photo) is carried to the OTP screen
/// and then to the address screen, which creates the account with
/// `/auth/google-signup`. There is no password and no address field here.
class GoogleSignupScreen extends StatefulWidget {
  static const routeName = '/google-signup';

  const GoogleSignupScreen({super.key});

  @override
  GoogleSignupScreenState createState() => GoogleSignupScreenState();
}

class GoogleSignupScreenState extends State<GoogleSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String? _googleId;
  String? _photoUrl;
  bool _awaitingOtp = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is GoogleSignInAccount) {
      final displayName = args.displayName ?? '';
      final parts = displayName.contains(' ') ? displayName.split(' ') : null;
      _email = args.email;
      _firstName = parts != null ? parts.first : displayName;
      _lastName =
          parts != null && parts.length > 1 ? parts.sublist(1).join(' ') : '';
      _googleId = args.id;
      _photoUrl = args.photoUrl;
    } else if (args is Map) {
      _email = args['googleEmail'] as String? ?? '';
      _firstName = args['firstName'] as String? ?? '';
      _lastName = args['lastName'] as String? ?? '';
      _googleId = args['googleId'] as String?;
      _photoUrl = args['photoUrl'] as String?;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _sendOtp() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _awaitingOtp = true);
    context.read<AuthenticationBloc>().add(
          SendOTP(phoneNumber: _phoneController.text.trim()),
        );
  }

  void _onAuthState(AuthenticationState state) {
    if (!_awaitingOtp) return;

    if (state is OTPSent) {
      setState(() => _awaitingOtp = false);
      Navigator.pushNamed(
        context,
        '/phone-otp-verification',
        arguments: <String, dynamic>{
          'phone': state.phoneNumber,
          'isGoogleSignup': true,
          'googleEmail': _email,
          'firstName': _firstName,
          'lastName': _lastName,
          if (_googleId != null) 'googleId': _googleId,
          if (_photoUrl != null) 'photoUrl': _photoUrl,
        },
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
        title: const Text('Sign up with Google'),
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
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const SizedBox(height: AppSpacing.md),
                const Text(
                  'Almost there',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'We use your phone number to deliver orders and to let you '
                  'sign in next time. We will text a 6-digit code.',
                  style: TextStyle(fontSize: 14, color: AppColors.darkGrey),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_email.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border.all(color: AppColors.lightDivider),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          color: AppColors.darkGrey,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            _email,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const Icon(
                          Icons.verified,
                          color: AppColors.success,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: AppSpacing.lg),
                TextFormField(
                  key: const Key('google_signup_phone_field'),
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
                      borderRadius: BorderRadius.circular(AppRadius.md),
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
                const SizedBox(height: AppSpacing.lg),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    key: const Key('google_signup_send_otp'),
                    onPressed: _awaitingOtp ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
