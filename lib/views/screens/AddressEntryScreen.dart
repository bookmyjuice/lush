import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:toastification/toastification.dart';

/// Step 3: Address Entry Screen (Common for all signup flows)
/// User enters complete address details
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
  final _addressController = TextEditingController();
  final _extendedAddrController = TextEditingController();
  final _extendedAddr2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isLoading = false;

  String? _email;
  String? _phone;
  String? _firstName;
  String? _lastName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'] as String;
      _phone = args['phone'] as String;
      _firstName = args['firstName'] as String;
      _lastName = args['lastName'] as String;

      // Pre-fill name if available (from Google signup)
      if (_firstName != null && _firstName!.isNotEmpty) {
        _firstNameController.text = _firstName!;
      }
      if (_lastName != null && _lastName!.isNotEmpty) {
        _lastNameController.text = _lastName!;
      }
      // Set default country
      _countryController.text = 'IN';
    } else {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    _extendedAddrController.dispose();
    _extendedAddr2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Store address info
      BlocProvider.of<AuthenticationBloc>(context).add(
        EnterAddress(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          address: _addressController.text.trim(),
          extendedAddr: _extendedAddrController.text.trim(),
          extendedAddr2: _extendedAddr2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zip: _zipController.text.trim(),
          country: _countryController.text.trim().toUpperCase(),
        ),
      );

      // Navigate to password creation screen
      Navigator.pushNamed(
        context,
        '/create-password',
        arguments: {
          'email': _email,
          'phone': _phone,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'address': _addressController.text.trim(),
          'extendedAddr': _extendedAddrController.text.trim(),
          'extendedAddr2': _extendedAddr2Controller.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'zip': _zipController.text.trim(),
          'country': _countryController.text.trim().toUpperCase(),
        },
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Address'),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, state) {
          if (state is AddressEntered) {
            toastification.show(
              title: const Text('Address Saved'),
              type: ToastificationType.success,
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
                  'Delivery Address',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your complete delivery address',
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
                      // First Name
                      TextFormField(
                        controller: _firstNameController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                      // Last Name
                      TextFormField(
                        controller: _lastNameController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
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
                      // Address Line 1
                      TextFormField(
                        controller: _addressController,
                        keyboardType: TextInputType.streetAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Address is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Flat/House No. *',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Society/Locality is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Society/Locality *',
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Sector/Area is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Sector/Area *',
                          prefixIcon: const Icon(Icons.map_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hintText: 'e.g., Sector 15',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _cityController,
                              keyboardType: TextInputType.text,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'City is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'City *',
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'State is required';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'State *',
                                prefixIcon: const Icon(Icons.public),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _zipController,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(6),
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'ZIP code is required';
                                }
                                if (value.length != 6) {
                                  return 'Enter valid 6-digit ZIP code';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'ZIP Code *',
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
                                FilteringTextInputFormatter.allow(
                                    RegExp('[a-zA-Z]')),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Country is required';
                                }
                                if (value.length != 2) {
                                  return 'Enter 2-letter country code';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                labelText: 'Country *',
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
                      ),
                    ],
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
                            'Continue',
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
