import 'dart:io';
import 'package:appwrite/models.dart';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import '../models/User.dart';
import 'package:appwrite/appwrite.dart';

class UserRepository {
  late bool userLoggedIn;
  Client client = Client()
      .setEndpoint('http://167.71.224.84/v1')
      .setProject('63d3be0307eb40e0f098')
      .setSelfSigned(status: true);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final HttpClient ioc = HttpClient();

  Future<String?> signInGoogle({required User user}) async {
    // SharedPreferences sharedPreferences = await _prefs;
    // (user.name==)

    //if user exists in DB, pass ID & password, get a JWT Token and return it else return null
    final data = jsonEncode({"username": user.name, "password": user.password});
    try {
      final HttpClient ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      var response = await http.post(
          Uri.parse("https://ev.powergrid.in/authenticate"),
          body: data,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          });
      var body = const Utf8Decoder().convert(response.bodyBytes);
      String token = json.decode(body)['token'];
      if (response.statusCode == 200) {
        // if (rememberMe == "true") {
        //   sharedPreferences.setString("rememberMe", rememberMe);
        //   persistCredentials(username, password);
        // }
        // persistToken(token);
        return token;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  Future<String?> signInFacebook({required User user}) async {
    SharedPreferences sharedPreferences = await _prefs;
    // (user.name==)
    final data = jsonEncode({"username": user.name, "password": user.password});
    try {
      final HttpClient ioc = HttpClient();
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      var response = await http.post(
          Uri.parse("https://ev.powergrid.in/authenticate"),
          body: data,
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          });
      var body = const Utf8Decoder().convert(response.bodyBytes);
      String token = json.decode(body)['token'];
      if (response.statusCode == 200) {
        // if (rememberMe == "true") {
        //   sharedPreferences.setString("rememberMe", rememberMe);
        //   persistCredentials(username, password);
        // }
        // persistToken(token);
        return token;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
    return null;
  }

  //AutoLogin function
  Future<String> autoLogin() async {
    SharedPreferences sharedPreferences = await _prefs;

    final String? username = sharedPreferences.getString("username");
    final String? password = sharedPreferences.getString("password");
    final Object? ifRememberMeChecked = sharedPreferences.get("rememberMe");

    if (username == null || password == null || ifRememberMeChecked == null) {
      return "";
    }

    if (ifRememberMeChecked == "true") {
      persistCredentials(username, password);
    }

    final data = jsonEncode({"username": username, "password": password});
    final HttpClient ioc = HttpClient();
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.post(
        Uri.parse("https://ev.powergrid.in/authenticate"),
        body: data,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        });
    var body = const Utf8Decoder().convert(response.bodyBytes);
    String token = json.decode(body)['token'];
    if (response.statusCode == 200) {
      sharedPreferences.setString("token", token);
      return token;
    } else {
      return "";
    }
  }

  Future<bool> SignUp({required User user}) async {
    SharedPreferences sharedPreferences = await _prefs;
    Account account = Account(client);
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final res = await account.create(
        userId: ID.unique(),
        email: user.email,
        password: user.password!,
        name: user.name);

    print(res.registration);
    print(res.status);
    print(res.emailVerification);
    print(res.prefs);
    print(res.phone);
    // sharedPreferences.setString("userid", user.userid);
    // sharedPreferences.setString("username", user.name);
    // sharedPreferences.setString("password", user.password);
    // sharedPreferences.setString("flatORVilla", user.flatOrVillaNumber);
    // sharedPreferences.setString("phoneNo", user.phoneNo);
    return res.status;
  }

  Future<void> verifyMobile(String mobileNumber) async {
    Account account = Account(client);
    // final u = account;
    // account.updatePhone(phone: mobileNumber, password: u.);
    account.createPhoneVerification();
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
}
