import 'package:flutter/material.dart';

/// Centralized back button handler for screens.
///
/// Provides reusable [PopScope] wrappers for:
/// - Confirmation dialogs before navigating back
/// - Unsaved changes warnings
/// - State cleanup on back press
class BackButtonHandler {
  BackButtonHandler._();

  /// Shows a confirmation dialog before allowing back navigation.
  ///
  /// Returns `true` if the user confirmed they want to exit.
  static Future<bool> confirmExit(
    BuildContext context, {
    String title = 'Exit?',
    String message = 'Are you sure you want to go back?',
    String confirmLabel = 'Yes, go back',
    String cancelLabel = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Handles back press with optional state cleanup callback.
  ///
  /// Use this when the screen has forms or in-progress operations.
  /// [onCleanup] is called before navigating back if confirmed.
  static Future<bool> handleBackPress({
    required BuildContext context,
    required bool hasUnsavedChanges,
    VoidCallback? onCleanup,
    String title = 'Unsaved Changes',
    String message = 'You have unsaved changes. Are you sure you want to go back?',
  }) async {
    if (!hasUnsavedChanges) {
      onCleanup?.call();
      return true;
    }
    final confirmed = await confirmExit(
      context,
      title: title,
      message: message,
    );
    if (confirmed) {
      onCleanup?.call();
      return true;
    }
    return false;
  }

  /// Wraps a screen's build method with PopScope for back button handling.
  ///
  /// [canPop] should be true when there's nothing to protect (default).
  /// [onPopInvoked] is called when the back button is pressed.
  /// [child] is the screen content.
  static Widget wrapWithPopScope({
    required bool canPop,
    required PopInvokedWithResultCallback onPopInvokedWithResult,
    required Widget child,
  }) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvokedWithResult,
      child: child,
    );
  }
}
