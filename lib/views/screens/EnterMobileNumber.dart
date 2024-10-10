import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/AuthBloc.dart';
import 'package:lush/bloc/AuthBloc/AuthEvents.dart';

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
        // appBar: AppBar(),
        body: SafeArea(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                keyboardType: TextInputType.number,
                  maxLength: 10,
                  controller: MobileNoController,
                  decoration: const InputDecoration(prefixText: "+91-",
                      icon: Icon(Icons.mobile_friendly_outlined))),
            ),
            ElevatedButton(
                onPressed: () {
                  BlocProvider.of<AuthenticationBloc>(context).add(MobileNumberEntered(MobileNoController.text));
                  Navigator.of(context).pushNamed("/otp");
                },
                child: const Text("Submit"))
          ]),
    ));
  }
}
