import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/theme/app_colors.dart';
import 'package:lush/utils/back_button_handler.dart';
import 'package:toastification/toastification.dart';

/// Signup step 3: name (mandatory) plus an optional delivery address.
///
/// The email is already verified by the previous step and arrives read-only in
/// the route arguments (as `emailVerificationToken`'s subject). The address is
/// optional — "Skip for now" creates the account and the customer can add an
/// address later from Profile -> Addresses.
class AddressEntryScreen extends StatefulWidget {
  static const routeName = '/address-entry';

  const AddressEntryScreen({super.key});

  @override
  AddressEntryScreenState createState() => AddressEntryScreenState();
}

class AddressEntryScreenState extends State<AddressEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _extendedAddrController = TextEditingController();
  final _extendedAddr2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isLoading = false;

  /// Set while submitting with "Skip for now": the address fields are neither
  /// validated nor sent, so a half-typed address cannot block signup.
  bool _skipAddress = false;

  String? _email;
  String? _signupToken;
  String? _emailVerificationToken;
  bool _isGoogleSignup = false;
  bool _didReadArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didReadArgs) return;
    _didReadArgs = true;

    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args == null) {
      Navigator.pop(context);
      return;
    }

    _email = args['email'] as String?;
    _signupToken = args['signupToken'] as String?;
    _emailVerificationToken = args['emailVerificationToken'] as String?;
    _isGoogleSignup = args['isGoogleSignup'] as bool? ?? false;

    final firstName = args['firstName'] as String?;
    final lastName = args['lastName'] as String?;
    if (_email != null && _email!.isNotEmpty) {
      _emailController.text = _email!;
    }
    if (firstName != null && firstName.isNotEmpty) {
      _firstNameController.text = firstName;
    }
    if (lastName != null && lastName.isNotEmpty) {
      _lastNameController.text = lastName;
    }
    // Sensible default; the customer can change it.
    _countryController.text = 'IN';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _extendedAddrController.dispose();
    _extendedAddr2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  /// True when the customer actually started filling the address block.
  bool get _hasAddressInput => _addressController.text.trim().isNotEmpty;

  void _onContinue() => _submit(skipAddress: false);

  void _onSkipNow() => _submit(skipAddress: true);

  void _submit({required bool skipAddress}) {
    if (_isLoading) return;
    _skipAddress = skipAddress;
    if (skipAddress) {
      // Discard partial input so the request carries a blank address.
      _addressController.clear();
      _extendedAddrController.clear();
      _extendedAddr2Controller.clear();
      _cityController.clear();
      _stateController.clear();
      _zipController.clear();
    }

    if (!(_formKey.currentState?.validate() ?? false)) {
      _skipAddress = false;
      setState(() {});
      return;
    }

    final signupToken = _signupToken;
    if (signupToken == null || signupToken.isEmpty) {
      toastification.show(
        title: const Text('Verify your number again'),
        description: const Text(
          'Your phone verification expired before we could create the account.',
        ),
        type: ToastificationType.error,
      );
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/phone-entry',
        (route) => false,
      );
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final emailVerificationToken = _emailVerificationToken ?? '';
    if (!_isGoogleSignup && (email.isEmpty || emailVerificationToken.isEmpty)) {
      toastification.show(
        title: const Text('Verify your email again'),
        description: const Text(
          'Your email verification expired before we could create the account.',
        ),
        type: ToastificationType.error,
      );
      // The phone proof is still valid for a few minutes: redo only the email.
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/signup-email-verification',
        (route) => false,
        arguments: <String, dynamic>{'signupToken': signupToken},
      );
      return;
    }

    setState(() => _isLoading = true);

    final bloc = BlocProvider.of<AuthenticationBloc>(context);
    if (_isGoogleSignup) {
      bloc.add(
        GoogleSignupRequested(
          signupToken: signupToken,
          address: _addressController.text.trim(),
          extendedAddr: _extendedAddrController.text.trim(),
          extendedAddr2: _extendedAddr2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zip: _zipController.text.trim(),
          country: _countryController.text.trim().toUpperCase(),
        ),
      );
    } else {
      bloc.add(
        PhoneSignupRequested(
          signupToken: signupToken,
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: email,
          emailVerificationToken: emailVerificationToken,
          address: _addressController.text.trim(),
          extendedAddr: _extendedAddrController.text.trim(),
          extendedAddr2: _extendedAddr2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zip: _zipController.text.trim(),
          country: _countryController.text.trim().toUpperCase(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final hasText = _firstNameController.text.isNotEmpty ||
            _lastNameController.text.isNotEmpty ||
            _addressController.text.isNotEmpty ||
            _cityController.text.isNotEmpty;
        final shouldPop = await BackButtonHandler.handleBackPress(
          context: context,
          hasUnsavedChanges: hasText,
          message:
              'Account setup in progress. Are you sure you want to go back?',
        );
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Your Details'),
          backgroundColor: AppColors.primaryOrange,
          centerTitle: true,
        ),
        body: BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state is AuthenticationSuccess) {
              if (!mounted) return;
              toastification.show(
                title: const Text('Account Created!'),
                description: const Text('Welcome to BookMyJuice'),
                type: ToastificationType.success,
              );
              // DP-2: this route is removed by the navigation below, so defer
              // it to the next frame instead of navigating inside the listener.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/dashboard',
                  (route) => false,
                );
              });
            } else if (state is AuthError) {
              if (!mounted) return;
              setState(() => _isLoading = false);
              toastification.show(
                title: const Text('Could Not Create Account'),
                description: Text(
                  state.error.replaceFirst(RegExp(r'^Error:\s*'), ''),
                ),
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
                    'Confirm your name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Your name and verified email are required. The delivery '
                    'address is optional — you can add it later from your profile.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildContinueButton(),
                  const SizedBox(height: 8),
                  _buildSkipButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // First Name (mandatory)
          TextFormField(
            key: const Key('address_first_name_field'),
            controller: _firstNameController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'First name is required';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'First Name *',
              prefixIcon: const Icon(Icons.person_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Last Name (mandatory)
          TextFormField(
            key: const Key('address_last_name_field'),
            controller: _lastNameController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Last name is required';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Last Name *',
              prefixIcon: const Icon(Icons.person_outline_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Email: verified in the previous step, never editable here.
          TextFormField(
            key: const Key('address_email_field'),
            controller: _emailController,
            readOnly: true,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) {
                return 'Email is required';
              }
              if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
                return 'Enter a valid email';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Email (verified) *',
              helperText: 'Verified — used for invoices and receipts',
              prefixIcon: const Icon(Icons.verified_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Delivery address (optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Add it now for faster checkout, or skip and add it later.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          // Address Line 1
          TextFormField(
            key: const Key('address_line1_field'),
            controller: _addressController,
            keyboardType: TextInputType.streetAddress,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Flat/House No.',
              prefixIcon: const Icon(Icons.home_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'e.g., Flat 101, Building Name',
            ),
          ),
          const SizedBox(height: 16),
          // Address Line 2
          TextFormField(
            controller: _extendedAddrController,
            keyboardType: TextInputType.streetAddress,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Society/Locality',
              prefixIcon: const Icon(Icons.location_city_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'e.g., Sunshine Society',
            ),
          ),
          const SizedBox(height: 16),
          // Address Line 3
          TextFormField(
            controller: _extendedAddr2Controller,
            keyboardType: TextInputType.streetAddress,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Sector/Area',
              prefixIcon: const Icon(Icons.map_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'e.g., Sector 15',
            ),
          ),
          const SizedBox(height: 16),
          _buildCityStateRow(),
          const SizedBox(height: 16),
          _buildZipCountryRow(),
        ],
      ),
    );
  }

  Widget _buildCityStateRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: _cityController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (_skipAddress || !_hasAddressInput) return null;
              if (value == null || value.trim().isEmpty) {
                return 'City is required';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'City',
              prefixIcon: const Icon(Icons.location_city),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _stateController,
            keyboardType: TextInputType.text,
            textCapitalization: TextCapitalization.words,
            validator: (value) {
              if (_skipAddress || !_hasAddressInput) return null;
              if (value == null || value.trim().isEmpty) {
                return 'State is required';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'State',
              prefixIcon: const Icon(Icons.map),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZipCountryRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextFormField(
            controller: _zipController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (_skipAddress || !_hasAddressInput) return null;
              if (value == null || value.isEmpty) {
                return 'ZIP is required';
              }
              if (value.length != 6) {
                return 'Enter valid 6-digit ZIP code';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'ZIP Code',
              prefixIcon: const Icon(Icons.pin_drop_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              counterText: '',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _countryController,
            keyboardType: TextInputType.text,
            maxLength: 2,
            inputFormatters: [
              LengthLimitingTextInputFormatter(2),
              FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]')),
            ],
            validator: (value) {
              if (_skipAddress || !_hasAddressInput) return null;
              if (value == null || value.isEmpty) {
                return 'Country is required';
              }
              if (value.length != 2) {
                return 'Enter 2-letter code';
              }
              return null;
            },
            decoration: InputDecoration(
              labelText: 'Country',
              prefixIcon: const Icon(Icons.public),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hintText: 'IN',
              counterText: '',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        key: const Key('address_continue_button'),
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
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        key: const Key('address_skip_now_button'),
        onPressed: _isLoading ? null : _onSkipNow,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryOrange),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Skip for now',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryOrange,
          ),
        ),
      ),
    );
  }
}
