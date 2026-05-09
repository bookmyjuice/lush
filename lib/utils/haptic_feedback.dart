import 'package:flutter/services.dart';

/// Utility class for haptic feedback
class HapticFeedbackUtil {
  /// Light haptic feedback for general interactions
  static void lightFeedback() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for button presses
  static void mediumFeedback() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for important actions
  static void heavyFeedback() {
    HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback for item selection
  static void selectionFeedback() {
    HapticFeedback.selectionClick();
  }

  /// Error haptic feedback for failed actions
  static void errorFeedback() {
    HapticFeedback.vibrate();
  }

  /// Success haptic feedback for successful actions
  static void successFeedback() {
    HapticFeedback.mediumImpact();
  }
}
