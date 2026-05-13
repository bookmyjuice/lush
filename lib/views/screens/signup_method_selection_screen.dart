import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
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
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // App Logo
              Image.asset(
                'assets/bmjlogo.png',
                height: 120,
                width: 240,
              ),
              const SizedBox(height: 30),
              // Title
              const Text(
                'Create Your Account',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose your preferred signup method',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              // Email Signup Button
              _buildSignupButton(
                iconData: Icons.email_outlined,
                label: 'Sign up with Email',
                subtitle: 'Enter your email address',
                color: Colors.blue,
                onTap: () {
                  BlocProvider.of<AuthenticationBloc>(context).add(
                    const ChooseSignupMethod(method: 'email'),
                  );
                  Navigator.pushNamed(context, '/email-signup');
                },
              ),
              const SizedBox(height: 16),
              // Phone Signup Button
              _buildSignupButton(
                iconData: Icons.phone_outlined,
                label: 'Sign up with Phone',
                subtitle: 'Enter your mobile number',
                color: Colors.green,
                onTap: () {
                  BlocProvider.of<AuthenticationBloc>(context).add(
                    const ChooseSignupMethod(method: 'phone'),
                  );
                  Navigator.pushNamed(context, '/phone-signup');
                },
              ),
              const SizedBox(height: 16),
              // Google Signup Button
              _buildGoogleSignupButton(
                label: 'Sign up with Google',
                subtitle: 'Quick signup with your Google account',
                color: Colors.red,
                onTap: () async {
                  // 1. Show loading indicator
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (ctx) => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF8C42),
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
              const SizedBox(height: 40),
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
                        color: Colors.amber,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(iconData, size: 32, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const FaIcon(FontAwesomeIcons.google, size: 32, color: Colors.red),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

}
