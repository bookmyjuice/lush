import 'package:flutter/material.dart';
import 'package:lush/theme.dart';
import 'package:rive/rive.dart' as rive;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  rive.RiveWidgetController? _controller;

  @override
  void initState() {
    super.initState();
    _initRive();
  }

  Future<void> _initRive() async {
    try {
      // Load the asset using the new static factory
      final riveFile = await rive.File.asset(
        'assets/BOOKMYJUICE_LOGO.riv',
        // Factory.rive is the high-performance C++ renderer
        riveFactory: rive.Factory.rive, 
      );

      if (riveFile != null && mounted) {
        setState(() {
          // Initialize controller with the correct Artboard selector
          _controller = rive.RiveWidgetController(
            riveFile,
            artboardSelector: const rive.ArtboardNamed('Artboard'),
          );
          
        });
      }
    } catch (e) {
      debugPrint('Rive Load Error: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose(); // Vital to prevent memory leaks in the native runtime
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LushTheme.background,
      body: Center(
        child: SizedBox(
          height: 76.35,
          width: 76.35,
          child: _controller == null
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : rive.RiveWidget(
                  controller: _controller!,
                  // Fit and Alignment are now handled by the Widget, not Controller
                  fit: rive.Fit.fitHeight,
                  alignment: Alignment.center,
                ),
        ),
      ),
    );
  }
}
