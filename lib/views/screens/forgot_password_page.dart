import 'package:flutter/material.dart';
// import 'package:rive/rive.dart';

class ForgotPasswordPage extends StatefulWidget {
// final UserRepository userRepository;
  const ForgotPasswordPage({super.key});

// super(key: key);
  @override
  ForgotPasswordPageState createState() => ForgotPasswordPageState();
}

class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController usernameController =
      TextEditingController(text: '');

  // get decoration => PinDecoration;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
          Padding(
              padding: const EdgeInsets.all(30.0),
              child: TextField(
                keyboardType: TextInputType.phone,
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Enter your phone number (10 digits)',
                  hintText: 'e.g. 9234567890',
                  prefixIcon: const Icon(Icons.phone),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      usernameController.clear();
                    },
                  ),
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  ),
                ),
              )),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // BlocProvider.of<AuthenticationBloc>(context).add(SignUp());
              },
              child: const Text("Submit"))
        ]));
  }
}
