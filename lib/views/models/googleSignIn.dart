import 'package:google_sign_in/google_sign_in.dart';

class googleSignIn{
static final _googleSignIn = GoogleSignIn();
static Future<GoogleSignInAccount?> login()=> _googleSignIn.signIn();
static GoogleSignInAccount currentUser()=> _googleSignIn.currentUser!;
static Future<bool> isUserSignedIn() => _googleSignIn.isSignedIn();
static Future<Map<String, String>>? googleAuthHeaders=  _googleSignIn.currentUser?.authHeaders;
}