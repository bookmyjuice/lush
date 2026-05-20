import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/app_theme.dart';
import 'package:lush/widgets/app_text_field.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:toastification/toastification.dart';

/// Step 2a (Email-first): Email Entry Screen
/// User enters email and receives verification code
class EmailSignupScreen extends StatefulWidget {
  static const routeName = '/email-signup';

  const EmailSignupScreen({super.key});

  @override
  EmailSignupScreenState createState() => EmailSignupScreenState();
}

class EmailSignupScreenState extends State<EmailSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final email = _emailController.text.trim().toLowerCase();

      // Send email verification code
      BlocProvider.of<AuthenticationBloc>(context).add(
        EnterEmail(email: email),
      );

      // Navigate to email verification screen
      Navigator.pushNamed(
        context,
        '/email-verification',
        arguments: email,
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final hasText = _emailController.text.isNotEmpty;
        final shouldPop = await BackButtonHandler.handleBackPress(
          context: context,
          hasUnsavedChanges: hasText,
          message: 'Email entry in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Sign up with Email'),
        backgroundColor: AppColors.primaryOrange,
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is EmailEntered) {
            toastification.show(
              title: const Text('Email Entered'),
              description: Text('Verification code sent to ${state.email}'),
              type: ToastificationType.success,
            );
          } else if (state is EmailVerificationFailed) {
            toastification.show(
              title: const Text('Email Verification Failed'),
              description: Text(state.error),
              type: ToastificationType.error,
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Enter your email address',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'We\'ll send you a verification code to confirm your email address.',
                  style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                    color: AppColors.darkGrey,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Form(
                  key: _formKey,
                  child: AppTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'your.email@example.com',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!isValidEmail(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.lg + 6),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: AppColors.white,
                          )
                        : const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
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
