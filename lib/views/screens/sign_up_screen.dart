import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/widgets/app_text_field.dart';
import 'package:toastification/toastification.dart';

/// Sign Up Screen - FR-AUTH-001 Implementation
///
/// Collects and validates:
/// - Email (required, validated)
/// - Password (required, validated with strength requirements)
/// - First Name (required)
/// - Last Name (required)
/// - Phone (required, 10-digit Indian number validated)
///
/// On successful validation, dispatches CompleteSignup event to AuthBloc
class SignUpScreen extends StatefulWidget {
  static const routeName = '/signup';
  final User user;
  const SignUpScreen({super.key, required this.user});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();

  // Password visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Password strength
  bool _passwordMeetsRequirements = false;

  @override
  void initState() {
    super.initState();
    _emailController.text = widget.user.email;
    _firstNameController.text = widget.user.firstName;
    _lastNameController.text = widget.user.lastName;
    _phoneController.text = widget.user.phone;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.nearlyBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocConsumer<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is SignUpSuccessful) {
            toastification.show(
              title: const Text('Account Created!'),
              description: const Text('Welcome to BookMyJuice'),
              type: ToastificationType.success,
              autoCloseDuration: const Duration(seconds: 3),
            );
            // Navigate to dashboard or login
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (state is SignUpFailed) {
            toastification.show(
              title: Text(state.error_heading),
              description: Text(state.error),
              type: ToastificationType.error,
              autoCloseDuration: const Duration(seconds: 5),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthenticationInProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.nearlyBlack,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Create your account to get started',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.darkGrey,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Email Field
                    AppTextField(
                      label: 'Email',
                      hint: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!isValidEmail(value)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // First Name Field
                    AppTextField(
                      label: 'First Name',
                      hint: 'Enter your first name',
                      prefixIcon: Icons.person_outline,
                      controller: _firstNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'First name is required';
                        }
                        if (value.length < 2) {
                          return 'First name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Last Name Field
                    AppTextField(
                      label: 'Last Name',
                      hint: 'Enter your last name',
                      prefixIcon: Icons.person_outline,
                      controller: _lastNameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Last name is required';
                        }
                        if (value.length < 2) {
                          return 'Last name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Phone Field
                    AppTextField(
                      label: 'Phone Number',
                      hint: 'Enter 10-digit mobile number',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                      maxLength: 10,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (!isValidPhone(value)) {
                          return 'Enter a valid 10-digit number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Password Section Divider
                    const Divider(),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.nearlyBlack,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Password Field
                    AppTextField(
                      label: 'Password',
                      hint: 'Create a strong password',
                      prefixIcon: Icons.lock_outlined,
                      obscureText: _obscurePassword,
                      suffixIcon: _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      suffixWidget: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      controller: _passwordController,
                      onChanged: (value) {
                        setState(() {
                          _passwordMeetsRequirements = isValidPassword(value);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        if (!isValidPassword(value)) {
                          return 'Password does not meet requirements';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),

                    // Password Requirements
                    _buildPasswordRequirements(),
                    const SizedBox(height: AppSpacing.md),

                    // Confirm Password Field
                    AppTextField(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      prefixIcon: Icons.lock_outlined,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: _obscureConfirmPassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      suffixWidget: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSignUp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryOrange,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // Login Link
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
          );
        },
      ),
    );
  }

  Widget _buildPasswordRequirements() {
    final requirements = [
      {'text': 'At least 8 characters', 'met': _passwordController.text.length >= 8},
      {'text': '1 uppercase letter', 'met': _passwordController.text.contains(RegExp(r'[A-Z]'))},
      {'text': '1 lowercase letter', 'met': _passwordController.text.contains(RegExp(r'[a-z]'))},
      {'text': '1 number', 'met': _passwordController.text.contains(RegExp(r'\d'))},
      {
        'text': '1 special character',
        'met': _passwordController.text.contains(RegExp(r'[@$!%*?&]'))
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...requirements.map((req) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Row(
                children: [
                  Icon(
                    req['met'] as bool? ?? false ? Icons.check_circle : Icons.circle_outlined,
                    size: 16,
                    color: req['met'] as bool? ?? false ? AppColors.success : AppColors.darkGrey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    req['text'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: req['met'] as bool? ?? false ? AppColors.success : AppColors.darkGrey,
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  void _handleSignUp() {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      toastification.show(
        title: const Text('Validation Error'),
        description: const Text('Please fill all required fields correctly'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    // Check password match
    if (_passwordController.text != _confirmPasswordController.text) {
      toastification.show(
        title: const Text('Password Mismatch'),
        description: const Text('Passwords do not match'),
        type: ToastificationType.error,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    // Check password strength
    if (!isValidPassword(_passwordController.text)) {
      toastification.show(
        title: const Text('Weak Password'),
        description: const Text('Password does not meet security requirements'),
        type: ToastificationType.warning,
        autoCloseDuration: const Duration(seconds: 3),
      );
      return;
    }

    // Dispatch signup event to AuthBloc
    context.read<AuthenticationBloc>().add(CompleteSignup(
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        ));

    // Note: Email, phone, name, address are collected in previous steps
    // of the unified signup flow and stored in AuthBloc state
  }
}
