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

  // Server Client ID for ID token verification (REQUIRED for Android)
  // IMPORTANT: This must be the WEB client ID (not Android) as per google_sign_in 7.x docs.
  // The Android OAuth client is auto-configured via google-services.json.
  static const String _serverClientId = '24122477606-tju3ortu42psbfluvl9hvmj7q15ec64c.apps.googleusercontent.com';

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

      // In google_sign_in 7.x, session restore APIs (isSignedIn, currentUser) were removed.
      // Users will authenticate fresh via the sign-in flow when needed.
      debugPrint('ℹ️ GoogleSignIn initialized. Session will be restored on first sign-in.');

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
      // Log the full error details for debugging
      if (e is Exception) {
        debugPrint('❌ GoogleSignIn Error Type: ${e.runtimeType}');
        debugPrint('❌ GoogleSignIn Error Details: $e');
      }
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
