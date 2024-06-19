import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
class Facebook{
  // static final _googleSignIn = GoogleSignIn();
  static Future<LoginResult> login()=> FacebookAuth.instance.login();
  static Future<Map<String,dynamic>> userdata() =>FacebookAuth.instance.getUserData();
}