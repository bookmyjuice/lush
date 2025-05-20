import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';
import 'package:pin_input_text_field/pin_input_text_field.dart';
import 'package:flutter/material.dart';

import '../../bloc/AuthBloc/AuthBloc.dart';
// import 'package:rive/rive.dart';

class OTPLoginPage extends StatefulWidget {
// final UserRepository userRepository;
  const OTPLoginPage({super.key});

// super(key: key);
  @override
  _OTPLoginPageState createState() => _OTPLoginPageState();
}

class _OTPLoginPageState extends State<OTPLoginPage> {
  final TextEditingController _OTP_controller = TextEditingController(text: '');

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
              child: PinInputTextField(
                  autoFocus: true,
                  pinLength: 6,
                  controller: _OTP_controller,
                  decoration: UnderlineDecoration(
                    colorBuilder:
                        PinListenColorBuilder(Colors.cyan, Colors.green),
                    // bgColorBuilder: ColorBuilder.a,
                    obscureStyle: ObscureStyle(
                      isTextObscure: true,
                      obscureText: '*',
                    ),
                  ))),
          // Text(_OTP_controller.text + "=> OK"),
          ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((ModalRoute.withName('/')));
                BlocProvider.of<AuthenticationBloc>(context).add(SignUp());
              },
              child: const Text("Submit"))
        ]));
  }
}
