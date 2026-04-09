import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Singleton helper for Google Sign-In
class GoogleSignInHelper {
  // Singleton instance
  static final GoogleSignInHelper instance = GoogleSignInHelper._internal();
  GoogleSignInHelper._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isInitialized = false;

  // Internal storage for the current user
  GoogleSignInAccount? _currentUser;

  // Server Client ID (REQUIRED for Android)
  // Ensure your SHA-1 fingerprint is added to this project in Google Cloud Console
  static const String _serverClientId = '434116959668-ab6k17v17l18ji7otsijcmahhfdb5322.apps.googleusercontent.com';

  /// Get the current signed-in user
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Initialize Google Sign-In
  /// Call this once at app startup (e.g., in main())
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔧 Initializing GoogleSignIn...');

      await _googleSignIn.initialize(
        serverClientId: _serverClientId,
      );

      // Try to restore previous session automatically
      // If successful, it updates _googleSignIn.currentUser, but we should also sync our local variable
      final restoredUser = await _googleSignIn.attemptLightweightAuthentication();
      if (restoredUser != null) {
        _currentUser = restoredUser;
      }

      _isInitialized = true;
      debugPrint('✅ GoogleSignIn Initialized');
    } catch (e) {
      debugPrint('❌ GoogleSignIn Initialization Failed: $e');
    }
  }

  /// Sign In with Google
  /// Returns the account object if successful, null if cancelled or failed.
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Ensure initialized before signing in
      if (!_isInitialized) {
        await initialize();
      }

      if (_googleSignIn.supportsAuthenticate()) {
        debugPrint('🔑 Calling authenticate()...');
        final account = await _googleSignIn.authenticate();
        
        // Update internal state
        if (account != null) {
          _currentUser = account;
          debugPrint('✅ Signed in: ${account.email}');
        }
        
        return account;
      } else {
        debugPrint('⚠️ GoogleSignIn: Platform does not support authenticate()');
        return null;
      }
    } catch (e) {
      debugPrint('❌ GoogleSignIn Failed: $e');
      return null;
    }
  }

  /// Sign Out / Disconnect
  Future<void> signOut() async {
    try {
      await _googleSignIn.disconnect();
      _currentUser = null; // Clear internal state
      debugPrint('✅ GoogleSignOut Success');
    } catch (e) {
      debugPrint('❌ GoogleSignOut Failed: $e');
    }
  }
}
