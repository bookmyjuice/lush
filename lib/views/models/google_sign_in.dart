import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Singleton helper for Google Sign-In
class GoogleSignInHelper {
  // Singleton instance
  static final GoogleSignInHelper instance = GoogleSignInHelper._internal();
  GoogleSignInHelper._internal();

  // In google_sign_in 7.x, only GoogleSignIn.instance is available
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  
  bool _isInitialized = false;

  // Internal storage for the current user
  GoogleSignInAccount? _currentUser;

  // Server Client ID (REQUIRED for Android)
  // Ensure your SHA-1 fingerprint is added to this project in Google Cloud Console
  static const String _serverClientId = '434116959668-sovbab9648v9hgbk1pi3tfg3ssl60mhb.apps.googleusercontent.com';

  /// Get the current signed-in user
  GoogleSignInAccount? get currentUser => _currentUser;

  /// Initialize Google Sign-In
  /// Call this once at app startup (e.g., in main())
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🔧 Initializing GoogleSignIn...');

      // Initialize with server client ID
      await _googleSignIn.initialize(serverClientId: _serverClientId);

      // Try to restore previous session automatically
      final restoredUser = await _googleSignIn.attemptLightweightAuthentication();
      if (restoredUser != null) {
        _currentUser = restoredUser;
        debugPrint('✅ Restored session: ${restoredUser.email}');
      }

      _isInitialized = true;
      debugPrint('✅ GoogleSignIn initialized');
    } catch (e) {
      debugPrint('❌ GoogleSignIn Initialization Failed: $e');
      // Don't fail initialization - user can still sign in manually
      _isInitialized = true;
    }
  }

  /// Sign In with Google
  /// Returns the account object if successful, null if cancelled or failed.
  /// Uses authenticate() which shows the account picker dialog.
  Future<GoogleSignInAccount?> signIn() async {
    try {
      // Ensure initialized before signing in
      if (!_isInitialized) {
        await initialize();
      }

      debugPrint('🔑 Calling authenticate() to show account picker...');
      
      // authenticate() shows the account picker on Android
      final account = await _googleSignIn.authenticate();

      // Update internal state
      if (account != null) {
        _currentUser = account;
        debugPrint('✅ Signed in: ${account.email}');
        debugPrint('👤 Display Name: ${account.displayName}');
      } else {
        debugPrint('⚠️ Google Sign-In: User cancelled or no account selected');
      }

      return account;
    } catch (e) {
      debugPrint('❌ GoogleSignIn Failed: $e');
      return null;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      _currentUser = null;
      debugPrint('✅ GoogleSignOut Success');
    } catch (e) {
      debugPrint('❌ GoogleSignOut Failed: $e');
    }
  }
}
