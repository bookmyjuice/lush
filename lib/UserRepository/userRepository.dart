import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:lush/getIt.dart';
import 'package:lush/views/models/googleSignIn.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../views/models/user.dart';

class UserRepository {
  bool userLoggedIn = false;
  User user =
      User.blank("", "", "", "", "", "", "", "", "", "", "", "", "", "");
  final MyGoogleSignIn googleSignIn = getIt.get();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final HttpClient ioc = HttpClient();
  late String token;

  Future<bool> autoLogin() async {
    late String data;
    SharedPreferences sharedPreferences = await _prefs;
    final String? username = sharedPreferences.getString("username");
    final String? password = sharedPreferences.getString("password");
    if (username == null || password == null) {
      return false;
    } else {
      data = jsonEncode({"username": username, "password": password});
    }
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.post(
        Uri.parse("192.168.1.27:8080/api/auth/signin"),
        body: data,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        });
    var body = const Utf8Decoder().convert(response.bodyBytes);
    String token = json.decode(body)['accessToken'];
    if (response.statusCode == 200) {
      sharedPreferences.setString("token", token);
      token = token;

      var response = await http.get(Uri.parse("localhost:8080/api/user"),
          // body: data,
          headers: {
            "authorization": "Bearer $token",
            "Accept": "application/json",
            "Content-Type": "application/json",
          });
      var body = const Utf8Decoder().convert(response.bodyBytes);
      user = json.decode(body);
      // user.setPhone = username;
      // user.password = password;
      return true;
    } else {
      return false;
    }
  }

  Future<bool> login(String username_, String pwd, bool remember) async {
    late String data;
    SharedPreferences sharedPreferences = await _prefs;
    final String username = username_;
    final String password = pwd;
    final Object ifRememberMeChecked = remember;
    if (ifRememberMeChecked == true) persistCredentials(username, pwd);
    data = jsonEncode({"username": username, "password": password});

    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.post(
        Uri.parse('http://192.168.1.27:8080/api/auth/signin'),
        body: data,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        });
    var body = const Utf8Decoder().convert(response.bodyBytes);
    String token = json.decode(body)['accessToken'];
    if (response.statusCode == 200) {
      sharedPreferences.setString("token", token);
      token = token;
      return true;
    } else {
      return true;
    }
  }

  Future<String> initialSignUp() async {
    String data;
    data = jsonEncode({
      "phone": user.getPhone,
      "email": user.getEmail,
      "role": user.getRole,
      "password": user.getPassword
    });
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    try {
      var response = await http.post(
          Uri.parse("https://192.168.1.27:8080/api/auth/signup"),
          body: data,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          });
      var body = const Utf8Decoder().convert(response.bodyBytes);
      user.setId = json.decode(body)['message'];
      return json.decode(body)['message'];
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> registerUserWithAddress() async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.post(
        Uri.parse("https://192.168.1.27:8080/chargebee/register"),
        body: user.toJson(),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        });
    var body = const Utf8Decoder().convert(response.bodyBytes);
    return json.decode(body)['message'];
  }

  Future<void> verifyMobile(String mobileNumber) async {
    // Account account = Account(client);
    // // final u = account;
    // // account.updatePhone(phone: mobileNumber, password: u.);
    // account.createPhoneVerification();
  }

  Future<void> deleteToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.remove("token");
  }

  Future<void> persistToken(String token) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    sharedPreferences.setString("token", token);
  }

  Future<void> persistCredentials(String u, String p) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString("username", u);
    sharedPreferences.setString("password", p);
  }

  Future<String?> getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? t = sharedPreferences.getString("token");
    return t;
  }

  Future<Object?> googleSignIn_() async {
    try {
      await MyGoogleSignIn.login();
    } catch (error) {
      print("error");
      return error;
    }
    user.setFirstName = MyGoogleSignIn.currentUser().displayName!.split(" ")[0];
    user.setLastName = MyGoogleSignIn.currentUser().displayName!.split(" ")[1];
    user.setEmail = MyGoogleSignIn.currentUser().email;
    // user.role = "User";
    return user;
    // return null;
  }
}
