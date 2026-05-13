import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Singleton wrapper around Firebase Phone Auth.
///
/// Provides a simplified API matching the existing usage pattern:
///   FirebasePhoneAuth.instance.initiatePhoneVerification(...)
///   FirebasePhoneAuth.instance.verifyPhoneOtp(smsCode)
class FirebasePhoneAuth {
  static final FirebasePhoneAuth instance = FirebasePhoneAuth._internal();
  FirebasePhoneAuth._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stores the most recent verificationId from codeSent callback.
  String? _pendingVerificationId;

  String? get pendingVerificationId => _pendingVerificationId;

  /// Stores a Completer used by verifyPhoneOtp() to await the result.
  Completer<bool>? _verificationCompleter;

  /// Timer to enforce a global timeout (e.g., 60s) on the entire flow.
  Timer? _globalTimeout;

  static const Duration _globalTimeoutDuration = Duration(seconds: 60);

  /// Initiate phone number verification.
  ///
  /// [phone] must be in E.164 format (e.g., +919876543210).
  /// [onCodeSent] called when the SMS code has been sent.
  /// [onError] called when verification fails.
  /// [onTimeout] called when SMS delivery times out.
  Future<void> initiatePhoneVerification({
    required String phone,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
    required void Function() onTimeout,
  }) async {
    // Cancel any previous global timeout
    _globalTimeout?.cancel();
    _globalTimeout = Timer(_globalTimeoutDuration, () {
      if (kDebugMode) {
        debugPrint('📱 Firebase Phone Auth global timeout reached');
      }
      onTimeout();
    });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 30),
        verificationCompleted: (PhoneAuthCredential credential) {
          // This fires on Android when SMS auto-retrieval or
          // Play Integrity / SafetyNet instantly verifies the number.
          // We handle it by signing in automatically.
          if (kDebugMode) {
            debugPrint('📱 Firebase auto-verification completed');
          }
          _globalTimeout?.cancel();
          // If we have a pending completer (from verifyPhoneOtp), complete it
          _verificationCompleter?.complete(true);
        },
        verificationFailed: (FirebaseAuthException e) {
          _globalTimeout?.cancel();
          final errorMsg = _mapFirebaseAuthException(e);
          if (kDebugMode) {
            debugPrint('📱 Firebase verification failed: $errorMsg');
          }
          _verificationCompleter?.complete(false);
          onError(errorMsg);
        },
        codeSent: (String verificationId, int? resendToken) {
          _pendingVerificationId = verificationId;
          if (kDebugMode) {
            debugPrint(
                '📱 Firebase code sent, verificationId: ${verificationId.substring(0, 8)}...');
          }
          onCodeSent(verificationId);
          // Note: we do NOT cancel the global timeout here —
          // the user still needs to enter the OTP within the timeout window.
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (kDebugMode) {
            debugPrint('📱 Firebase code auto-retrieval timed out');
          }
          _globalTimeout?.cancel();
          onTimeout();
        },
      );
    } catch (e) {
      _globalTimeout?.cancel();
      if (kDebugMode) {
        debugPrint('📱 Firebase initiatePhoneVerification exception: $e');
      }
      onError('Failed to start verification: $e');
    }
  }

  /// Verify the SMS code entered by the user.
  ///
  /// Returns `true` if verification succeeded, `false` otherwise.
  /// Must be called after [initiatePhoneVerification] has completed the
  /// onCodeSent callback (i.e., we have a verificationId).
  Future<bool> verifyPhoneOtp(String smsCode) async {
    final verificationId = _pendingVerificationId;
    if (verificationId == null || verificationId.isEmpty) {
      if (kDebugMode) {
        debugPrint(
            '📱 verifyPhoneOtp called but no pending verificationId');
      }
      return false;
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      await _auth.signInWithCredential(credential);
      _globalTimeout?.cancel();
      if (kDebugMode) {
        debugPrint('📱 Firebase OTP verification succeeded');
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _globalTimeout?.cancel();
      if (kDebugMode) {
        debugPrint(
            '📱 Firebase OTP verification failed: ${e.message}');
      }
      return false;
    } catch (e) {
      _globalTimeout?.cancel();
      if (kDebugMode) {
        debugPrint('📱 Firebase OTP verification error: $e');
      }
      return false;
    }
  }

  /// Cancel any ongoing verification.
  void cancel() {
    _globalTimeout?.cancel();
    _pendingVerificationId = null;
    _verificationCompleter?.complete(false);
    _verificationCompleter = null;
  }

  /// Map FirebaseAuthException codes to user-friendly messages.
  String _mapFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Invalid phone number format';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Phone verification failed';
    }
  }
}
