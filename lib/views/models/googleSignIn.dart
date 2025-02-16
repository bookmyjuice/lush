import 'package:google_sign_in/google_sign_in.dart';

class MyGoogleSignIn {
  static final List<String> _scopes = <String>[
    'email'
    // 'https://www.googleapis.com/auth/contacts.readonly',
  ];

  static final _googleSignIn = GoogleSignIn(scopes: _scopes);
  static Future<GoogleSignInAccount?> login() => _googleSignIn.signIn();
  static GoogleSignInAccount currentUser() => _googleSignIn.currentUser!;
  static Future<bool> isUserSignedIn() => _googleSignIn.isSignedIn();
  static Future<Map<String, String>>? googleAuthHeaders =
      _googleSignIn.currentUser?.authHeaders;
}
