import 'package:flutter/material.dart';
import 'package:lush/theme.dart';
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
      backgroundColor: LushTheme.background,
      body: Center(
        child: SizedBox(
          height: 76.35,
          width: 76.35,
          child: RiveAnimation.asset(
            'assets/BOOKMYJUICE_LOGO.riv',
            artboard: 'Artboard',
            speedMultiplier: 0.5,
            fit: BoxFit.fitHeight,
            alignment: Alignment.center,
            placeHolder: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
