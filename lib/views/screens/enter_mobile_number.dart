import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:toastification/toastification.dart';

class MobileNumberPage extends StatefulWidget {
// final UserRepository userRepository;
  const MobileNumberPage({super.key});

// super(key: key);
  @override
  _MobileNumberPageState createState() => _MobileNumberPageState();
}

class _MobileNumberPageState extends State<MobileNumberPage> {
  TextEditingController MobileNoController = TextEditingController(text: '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Enter Phone Number"),
          centerTitle: true,
        ),
        body: BlocListener<AuthenticationBloc, AuthenticationState>(
          listenWhen: (previous, current) =>
              current is OTPSent || current is OTPSendFailed,
          listener: (context, state) {
            if (state is OTPSent) {
              // Navigate to OTP verification screen only after OTP is sent
              Navigator.of(context).pushNamed("/otpSignUpScreen");
            } else if (state is OTPSendFailed) {
              toastification.show(
                title: const Text('Failed to Send OTP'),
                description: Text(state.error),
                type: ToastificationType.error,
              );
            }
          },
          child: SafeArea(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Create Account with Phone Number",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                            keyboardType: TextInputType.number,
                            maxLength: 10,
                            controller: MobileNoController,
                            decoration: const InputDecoration(
                                prefixText: "+91 ",
                                prefixIcon: Icon(Icons.phone),
                                labelText: "Phone Number",
                                hintText: "Enter 10 digit phone number",
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<AuthenticationBloc, AuthenticationState>(
                    builder: (context, state) {
                      final isLoading = state is AuthenticationInProgress;

                      return ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 12),
                            backgroundColor: Colors.amber,
                          ),
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (MobileNoController.text.isEmpty ||
                                      MobileNoController.text.length != 10) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please enter a valid 10-digit phone number"),
                                      ),
                                    );
                                    return;
                                  }
                                  // Set phone number in user repository and send OTP
                                  BlocProvider.of<AuthenticationBloc>(context)
                                      .add(MobileSignUp(
                                          mobileNumber:
                                              MobileNoController.text));

                                  // Send OTP
                                  BlocProvider.of<AuthenticationBloc>(context)
                                      .add(SendOTP(
                                          phoneNumber:
                                              MobileNoController.text));
                                },
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : const Text("Continue"));
                    },
                  )
                ]),
          ),
        ));
  }
}
