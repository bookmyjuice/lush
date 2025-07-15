import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyGoogleSignIn {
  static final List<String> _scopes = <String>[
    'email',
    // 'https://www.googleapis.com/auth/contacts.readonly',
  ];

  static GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
  static GoogleSignInAccount? _currentUser;

  /// Initialize Google Sign-In
  static Future<void> initialize({
    String? clientId,
    String? serverClientId,
  }) async {
    await _googleSignIn.initialize(
      clientId: clientId,
      serverClientId: serverClientId,
    );
  }

  /// Attempt lightweight authentication (silent sign-in)
  static Future<GoogleSignInAccount?> attemptLightweightAuthentication() async {
    try {
      _currentUser = await _googleSignIn.attemptLightweightAuthentication();
      return _currentUser;
    } catch (e) {
      debugPrint('Error during lightweight authentication: $e');
      return null;
    }
  }

  /// Sign in with Google
  static Future<GoogleSignInAccount?> login() async {
    try {
      if (_googleSignIn.supportsAuthenticate()) {
        _currentUser = await _googleSignIn.authenticate();
        return _currentUser;
      } else {
        // Fallback for platforms that don't support authenticate()
        throw UnsupportedError(
            'Google Sign-In authentication not supported on this platform');
      }
    } catch (e) {
      debugPrint('Error during Google Sign-In: $e');
      return null;
    }
  }

  /// Get current signed-in user
  static GoogleSignInAccount? get currentUser => _currentUser;

  /// Check if user is signed in
  static bool get isUserSignedIn => _currentUser != null;

  /// Sign out
  static Future<void> signOut() async {
    await _googleSignIn.signOut();
    _currentUser = null;
  }

  /// Disconnect (revoke access)
  static Future<void> disconnect() async {
    await _googleSignIn.disconnect();
    _currentUser = null;
  }

  /// Get authorization for specific scopes
  static Future<GoogleSignInClientAuthorization?> getAuthorizationForScopes(
    List<String> scopes,
  ) async {
    final user = _currentUser;
    if (user == null) return null;

    try {
      return await user.authorizationClient.authorizationForScopes(scopes);
    } catch (e) {
      debugPrint('Error getting authorization for scopes: $e');
      return null;
    }
  }

  /// Authorize new scopes (requires user interaction)
  static Future<GoogleSignInClientAuthorization?> authorizeScopes(
    List<String> scopes,
  ) async {
    final user = _currentUser;
    if (user == null) return null;

    try {
      return await user.authorizationClient.authorizeScopes(scopes);
    } catch (e) {
      debugPrint('Error authorizing scopes: $e');
      return null;
    }
  }

  /// Get server authorization code
  static Future<GoogleSignInServerAuthorization?> getServerAuthorization(
    List<String> scopes,
  ) async {
    final user = _currentUser;
    if (user == null) return null;

    try {
      return await user.authorizationClient.authorizeServer(scopes);
    } catch (e) {
      debugPrint('Error getting server authorization: $e');
      return null;
    }
  }

  /// Get access token for API calls
  static Future<String?> getAccessToken() async {
    final authorization = await getAuthorizationForScopes(_scopes);
    return authorization?.accessToken;
  }

  /// Listen to authentication events
  static Stream<GoogleSignInAuthenticationEvent> get authenticationEvents =>
      _googleSignIn.authenticationEvents;

  /// Check if authorization requires user interaction
  static bool get authorizationRequiresUserInteraction =>
      _googleSignIn.authorizationRequiresUserInteraction();
}
