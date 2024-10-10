import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[700],
      body: const Center(
        child: SizedBox(
          width: 400,
          child: RiveAnimation.asset('assets/mbox.riv'),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
