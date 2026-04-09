import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:lush/bloc/AuthBloc/AuthState.dart';
import 'package:toastification/toastification.dart';

/// Step 2b (Phone-first): Email Entry Screen after Phone Verification
/// User enters email and receives verification code
class EmailEntryAfterPhoneScreen extends StatefulWidget {
  static const routeName = '/email-entry-after-phone';

  const EmailEntryAfterPhoneScreen({super.key});

  @override
  EmailEntryAfterPhoneScreenState createState() =>
      EmailEntryAfterPhoneScreenState();
}

class EmailEntryAfterPhoneScreenState
    extends State<EmailEntryAfterPhoneScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  late String _phone;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      _phone = args;
    } else {
      Navigator.pop(context);
    }
  }

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
        '/email-verification-after-phone',
        arguments: {
          'email': email,
          'phone': _phone,
        },
      );

      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Email Address'),
        backgroundColor: Colors.amber,
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
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Enter your email address',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'We\'ll send you a verification code to confirm your email address.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: 'your.email@example.com',
                    ),
                    onFieldSubmitted: (_) => _onContinue(),
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
