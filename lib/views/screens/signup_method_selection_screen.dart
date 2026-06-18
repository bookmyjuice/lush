import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/theme/app_spacing.dart';
import 'package:lush/theme/app_text_styles.dart';
import 'package:lush/theme/app_theme.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:lush/views/models/google_sign_in.dart';

/// Step 1: Signup Method Selection Screen
/// User chooses between Email, Phone, or Google signup
class SignupMethodSelectionScreen extends StatefulWidget {
  static const routeName = '/signup-method-selection';

  const SignupMethodSelectionScreen({super.key});

  @override
  SignupMethodSelectionScreenState createState() =>
      SignupMethodSelectionScreenState();
}

class SignupMethodSelectionScreenState
    extends State<SignupMethodSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await BackButtonHandler.confirmExit(
          context,
          message: 'Signup in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.xl),
              // App Logo
              Image.asset(
                'assets/bmjlogo.png',
                height: 120,
                width: 240,
              ),
              const SizedBox(height: AppSpacing.lg + 6),
              // Title
              Text(
                'Create Your Account',
                style: AppTextStyles.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Choose your preferred signup method',
                style: AppTextStyles.textTheme.bodyLarge?.copyWith(
                  color: AppColors.darkGrey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl + 18),
              // Email Signup Button
              _buildSignupButton(
                iconData: Icons.email_outlined,
                label: 'Sign up with Email',
                subtitle: 'Enter your email address',
                color: AppColors.info,
                onTap: () {
                  BlocProvider.of<AuthenticationBloc>(context).add(
                    const ChooseSignupMethod(method: 'email'),
                  );
                  Navigator.pushNamed(context, '/email-signup');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              // Phone Signup Button
              _buildSignupButton(
                iconData: Icons.phone_outlined,
                label: 'Sign up with Phone',
                subtitle: 'Enter your mobile number',
                color: AppColors.success,
                onTap: () {
                  BlocProvider.of<AuthenticationBloc>(context).add(
                    const ChooseSignupMethod(method: 'phone'),
                  );
                  Navigator.pushNamed(context, '/phone-signup');
                },
              ),
              const SizedBox(height: AppSpacing.md),
              // Google Signup Button
              _buildGoogleSignupButton(
                label: 'Sign up with Google',
                subtitle: 'Quick signup with your Google account',
                color: AppColors.error,
                onTap: () async {
                  // 1. Show loading indicator
                  if (!context.mounted) return;
                  showDialog<bool?>(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  );

                  // 2. Attempt Google Login using the helper
                  final googleUser = await GoogleSignInHelper.instance.signIn();

                  // 3. Remove loading indicator
                  if (!context.mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();

                  // 4. Handle Result
                  if (googleUser != null) {
                    // Success: Send event and navigate with the user data
                    BlocProvider.of<AuthenticationBloc>(context).add(
                      const ChooseSignupMethod(method: 'google'),
                    );

                    // Pass the user object to the next screen
                    Navigator.pushNamed(
                      context,
                      '/google-signup',
                      arguments: googleUser,
                    );
                  } else {
                    // Failed/Cancelled
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              // Already have account
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/login');
                    },
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        color: AppColors.primaryOrange,
                        fontWeight: FontWeight.bold,
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

  Widget _buildSignupButton({
    required IconData iconData,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightDivider),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            Icon(iconData, size: 32, color: color),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.darkGrey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleSignupButton({
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightDivider),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Row(
          children: [
            const FaIcon(FontAwesomeIcons.google, size: 32, color: AppColors.error),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTextStyles.textTheme.bodyMedium?.copyWith(
                      color: AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: AppColors.darkGrey,
            ),
          ],
        ),
      ),
    );
  }

}
