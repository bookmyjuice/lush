import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:toastification/toastification.dart';

/// Step 4: Create Password Screen (Final step before account creation)
/// User creates password and completes signup
class CreatePasswordScreen extends StatefulWidget {
  static const routeName = '/create-password';

  const CreatePasswordScreen({super.key});

  @override
  CreatePasswordScreenState createState() => CreatePasswordScreenState();
}

class CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _validatorKey = GlobalKey<FlutterPwValidatorState>();
  bool _isLoading = false;
  bool _isPasswordValid = false;

  Map<String, dynamic>? _signupData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _signupData = args;
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignup() {
    if (_formKey.currentState!.validate() && _isPasswordValid) {
      final password = _passwordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();

      if (password != confirmPassword) {
        toastification.show(
          title: const Text('Passwords Do Not Match'),
          description: const Text('Please ensure both passwords match'),
          type: ToastificationType.error,
        );
        return;
      }

      setState(() => _isLoading = true);

      // Complete signup
      BlocProvider.of<AuthenticationBloc>(context).add(
        CompleteSignup(
          password: password,
          confirmPassword: confirmPassword,
        ),
      );

      setState(() => _isLoading = false);
    } else if (!_isPasswordValid) {
      toastification.show(
        title: const Text('Weak Password'),
        description: const Text('Please meet all password requirements'),
        type: ToastificationType.warning,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Password'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listenWhen: (previous, current) =>
            current is SignUpSuccessful ||
            current is SignUpFailed ||
            current is AuthenticationSuccess,
        listener: (context, state) {
          if (state is SignUpSuccessful || state is AuthenticationSuccess) {
            toastification.show(
              title: const Text('Account Created!'),
              description: const Text('Welcome to BookMyJuice'),
              type: ToastificationType.success,
            );
            // Navigate to home/dashboard
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard',
              (route) => false,
            );
          } else if (state is SignUpFailed) {
            toastification.show(
              title: Text(state.error_heading),
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
                  'Create Your Password',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Choose a strong password to secure your account',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password *',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Enter your password',
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Password Validator
                      FlutterPwValidator(
                        key: _validatorKey,
                        controller: _passwordController,
                        minLength: 8,
                        uppercaseCharCount: 1,
                        lowercaseCharCount: 1,
                        numericCharCount: 2,
                        specialCharCount: 1,
                        normalCharCount: 3,
                        width: MediaQuery.of(context).size.width,
                        height: 180,
                        onSuccess: () {
                          setState(() {
                            _isPasswordValid = true;
                          });
                        },
                        onFail: () {
                          setState(() {
                            _isPasswordValid = false;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Confirm Password *',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'Re-enter your password',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (_isLoading || !_isPasswordValid)
                        ? null
                        : _onSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Password Requirements:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                _buildRequirement('At least 8 characters'),
                _buildRequirement('At least 1 uppercase letter'),
                _buildRequirement('At least 1 lowercase letter'),
                _buildRequirement('At least 2 numbers'),
                _buildRequirement('At least 1 special character'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, size: 16, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
