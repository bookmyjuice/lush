import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:lush/widgets/AppTextField.dart';
import 'package:toastification/toastification.dart';

/// Google Signup Screen - Pre-fills email/name/photo from Google (READ-ONLY)
/// User enters phone, address, password (EDITABLE)
class GoogleSignupScreen extends StatefulWidget {
  static const routeName = '/google-signup';

  const GoogleSignupScreen({super.key});

  @override
  GoogleSignupScreenState createState() => GoogleSignupScreenState();
}

class GoogleSignupScreenState extends State<GoogleSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  // Google-fetched data (READ-ONLY)
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String? _photoUrl;
  String? _googleId;

  // User-entered data (EDITABLE)
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _extendedAddrController = TextEditingController();
  final _extendedAddr2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isPasswordValid = false;

  @override
  void initState() {
    super.initState();
    // We get data from Navigator arguments in didChangeDependencies
    // so we don't trigger a login here.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Get the Google user passed from the previous screen
    final googleUser = ModalRoute.of(context)?.settings.arguments as GoogleSignInAccount?;

    if (googleUser == null) {
      // If no user data, go back to selection screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.pop(context);
      });
      return;
    }

    // Populate fields with Google data
    setState(() {
      _emailController.text = googleUser.email;
      _firstNameController.text = googleUser.displayName ?? '';
      // Google doesn't provide separate lastName, so we leave it empty for user to fill
      _lastNameController.text = '';
      _photoUrl = googleUser.photoUrl;
      _googleId = googleUser.id;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _extendedAddrController.dispose();
    _extendedAddr2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    if (!_formKey.currentState!.validate()) {
      toastification.show(
        title: const Text('Validation Error'),
        description: const Text('Please fill all required fields correctly'),
        type: ToastificationType.error,
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      toastification.show(
        title: const Text('Password Mismatch'),
        description: const Text('Passwords do not match'),
        type: ToastificationType.error,
      );
      return;
    }

    if (!_isPasswordValid) {
      toastification.show(
        title: const Text('Weak Password'),
        description: const Text('Password does not meet security requirements'),
        type: ToastificationType.warning,
      );
      return;
    }

    setState(() => _isLoading = true);

    // Dispatch signup event to AuthBloc with all fields
    context.read<AuthenticationBloc>().add(
      GoogleSignUpEnterPhone(
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        // Additional fields for complete signup
        address: _addressController.text.trim(),
        extendedAddr: _extendedAddrController.text.trim(),
        extendedAddr2: _extendedAddr2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        zip: _zipController.text.trim(),
        country: 'IN', // Default to India
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        googleId: _googleId,
        photoUrl: _photoUrl,
      ),
    );

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: Colors.amber,
        centerTitle: true,
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
          if (_isLoading || state is AuthenticationInProgress) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'Google Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Google Profile Photo (if available)
                    if (_photoUrl != null && _photoUrl!.isNotEmpty)
                      Center(
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(_photoUrl!),
                          backgroundColor: Colors.grey[200],
                        ),
                      ),
                    const SizedBox(height: 16),
                    
                    // READ-ONLY: Email (from Google)
                    AppTextField(
                      label: 'Email (from Google)',
                      controller: _emailController,
                      readOnly: true,
                      prefixIcon: Icons.email_outlined,
                      suffixIcon: Icons.lock_outlined,
                    ),
                    const SizedBox(height: 16),
                    
                    // READ-ONLY: First Name (from Google)
                    AppTextField(
                      label: 'First Name (from Google)',
                      controller: _firstNameController,
                      readOnly: true,
                      prefixIcon: Icons.person_outline,
                      suffixIcon: Icons.lock_outlined,
                    ),
                    const SizedBox(height: 16),
                    
                    // READ-ONLY: Last Name (from Google)
                    AppTextField(
                      label: 'Last Name (from Google)',
                      controller: _lastNameController,
                      // readOnly: false,
                      prefixIcon: Icons.person_outline,
                      suffixIcon: Icons.lock_outlined,
                    ),
                    const SizedBox(height: 24),
                    
                    // Divider
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // EDITABLE: User-entered fields
                    const Text(
                      'Additional Information',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // EDITABLE: Phone Number
                    AppTextField(
                      label: 'Phone Number *',
                      hint: 'Enter 10-digit mobile number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(10),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      prefixIcon: Icons.phone_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Phone number is required';
                        }
                        if (value.length != 10) {
                          return 'Enter a valid 10-digit number';
                        }
                        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                          return 'Phone must start with 6-9';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // EDITABLE: Address
                    AppTextField(
                      label: 'Address Line 1 *',
                      hint: 'Flat/House No.',
                      controller: _addressController,
                      prefixIcon: Icons.home_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Address is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      label: 'Address Line 2 *',
                      hint: 'Society/Locality',
                      controller: _extendedAddrController,
                      prefixIcon: Icons.location_city_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Society/Locality is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    AppTextField(
                      label: 'Address Line 3 *',
                      hint: 'Sector/Area',
                      controller: _extendedAddr2Controller,
                      prefixIcon: Icons.map_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Sector/Area is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // City and State
                    Row(
                      children: [
                        Expanded(
                          child: AppTextField(
                            label: 'City *',
                            controller: _cityController,
                            prefixIcon: Icons.location_city,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'City is required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppTextField(
                            label: 'State *',
                            controller: _stateController,
                            prefixIcon: Icons.public,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'State is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // ZIP Code
                    AppTextField(
                      label: 'ZIP Code *',
                      hint: '6-digit PIN',
                      controller: _zipController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      prefixIcon: Icons.pin_drop_outlined,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ZIP code is required';
                        }
                        if (value.length != 6) {
                          return 'Enter valid 6-digit ZIP code';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Divider
                    const Divider(),
                    const SizedBox(height: 24),
                    
                    // Password Section
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // EDITABLE: Password
                    AppTextField(
                      label: 'Password *',
                      hint: 'Create a strong password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefixIcon: Icons.lock_outlined,
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
                      onChanged: (value) {
                        setState(() {
                          _isPasswordValid = isValidPassword(value);
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
                    const SizedBox(height: 16),
                    
                    // Password Requirements
                    _buildPasswordRequirements(),
                    const SizedBox(height: 16),
                    
                    // EDITABLE: Confirm Password
                    AppTextField(
                      label: 'Confirm Password *',
                      hint: 'Re-enter your password',
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      prefixIcon: Icons.lock_outlined,
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
                    const SizedBox(height: 32),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _handleSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF8C42),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Cancel Button
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
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
      {'text': '1 special character', 'met': _passwordController.text.contains(RegExp(r'[@$!%*?&]'))},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...requirements.map((req) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Row(
            children: [
              Icon(
                req['met'] as bool? ?? false
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                size: 16,
                color: req['met'] as bool? ?? false
                    ? const Color(0xFF4CAF50)
                    : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                req['text'] as String,
                style: TextStyle(
                  fontSize: 12,
                  color: req['met'] as bool? ?? false
                      ? const Color(0xFF4CAF50)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  bool isValidPassword(String password) {
    return RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
        .hasMatch(password);
  }
}
