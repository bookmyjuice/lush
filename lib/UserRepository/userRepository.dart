import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
// import '../views/models/User.dart';
// import 'package:appwrite/appwrite.dart';

class UserRepository {
  late bool userLoggedIn;
  // Client client = Client()
  //     .setEndpoint('http://167.71.224.84/v1')
  //     .setProject('63d3be0307eb40e0f098')
  //     .setSelfSigned(status: true);
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final HttpClient ioc = HttpClient();

  // Future<String?> signInGoogle({required User user}) async {
  //   SharedPreferences sharedPreferences = await _prefs;
  //   // (user.name==)

  //   //if user exists in DB, pass ID & password, get a JWT Token and return it else return null
  //   final data = jsonEncode({"username": user.name, "password": user.password});
  //   try {
  //     final HttpClient ioc = HttpClient();
  //     ioc.badCertificateCallback =
  //         (X509Certificate cert, String host, int port) => true;
  //     final http = IOClient(ioc);
  //     var response = await http.post(
  //         Uri.parse("https://ev.powergrid.in/authenticate"),
  //         body: data,
  //         headers: {
  //           "Accept": "application/json",
  //           "Content-Type": "application/json",
  //         });
  //     var body = const Utf8Decoder().convert(response.bodyBytes);
  //     String token = json.decode(body)['token'];
  //     if (response.statusCode == 200) {
  //       // if (rememberMe == "true") {
  //       //   sharedPreferences.setString("rememberMe", rememberMe);
  //       //   persistCredentials(username, password);
  //       // }
  //       // persistToken(token);
  //       return token;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e.toString());
  //     }
  //   }
  //   return null;
  // }
  // Future<String?> signInFacebook({required User user}) async {
  //   SharedPreferences sharedPreferences = await _prefs;
  //   // (user.name==)
  //   final data = jsonEncode({"username": user.name, "password": user.password});
  //   try {
  //     final HttpClient ioc = HttpClient();
  //     ioc.badCertificateCallback =
  //         (X509Certificate cert, String host, int port) => true;
  //     final http = IOClient(ioc);
  //     var response = await http.post(
  //         Uri.parse("https://ev.powergrid.in/authenticate"),
  //         body: data,
  //         headers: {
  //           "Accept": "application/json",
  //           "Content-Type": "application/json",
  //         });
  //     var body = const Utf8Decoder().convert(response.bodyBytes);
  //     String token = json.decode(body)['token'];
  //     if (response.statusCode == 200) {
  //       // if (rememberMe == "true") {
  //       //   sharedPreferences.setString("rememberMe", rememberMe);
  //       //   persistCredentials(username, password);
  //       // }
  //       // persistToken(token);
  //       return token;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print(e.toString());
  //     }
  //   }
  //   return null;
  // }

  //AutoLogin function

  Future<String> autoLogin() async {
    late String data;
    SharedPreferences sharedPreferences = await _prefs;
    final String? username = sharedPreferences.getString("username");
    final String? password = sharedPreferences.getString("password");
    // final Object? ifRememberMeChecked = sharedPreferences.get("rememberMe");
    if (username == null || password == null) {
      return "0";
    } else {
      data = jsonEncode({"username": username, "password": password});
    }
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.post(Uri.parse("localhost:8080/api/auth/signin"),
        body: data,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        });
    var body = const Utf8Decoder().convert(response.bodyBytes);
    String token = json.decode(body)['accessToken'];
    if (response.statusCode == 200) {
      sharedPreferences.setString("token", token);
      return token;
    } else {
      return "0";
    }
  }

  Future<String> login(String username_, String pwd, bool remember) async {
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
        Uri.parse('http://localhost:8080/api/auth/signin'),
        body: data,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        });
    var body = const Utf8Decoder().convert(response.bodyBytes);
    String token = json.decode(body)['accessToken'];
    if (response.statusCode == 200) {
      sharedPreferences.setString("token", token);
      return token;
    } else {
      return "0";
    }
  }

  Future<String> signUp(
      String phone, String email, String role, String pwd) async {
    // SharedPreferences sharedPreferences = await _prefs;
    // final HttpClient ioc = HttpClient();
    String data;
    data = jsonEncode(
        {"phone": phone, "email": email, "role": role, "password": pwd});
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.post(
        Uri.parse("https://localhost:8080/api/auth/signup"),
        body: data,
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        });
    var body = const Utf8Decoder().convert(response.bodyBytes);
    return json.decode(body)['message'];
  }

  Future<String> registerUserWithAddress(
      {required String id,
      required String firstName,
      required String lastName,
      required String phone,
      required String email,
      required String address,
      required String extendedAddr,
      required String extendedAddr2,
      required String city,
      required String state,
      required String country,
      required String zip}) async {
    String data;
    data = jsonEncode({
      "firstName": firstName,
      "lastName": lastName,
      "id": id,
      "phone": phone,
      "email": email,
      "addr": address,
      "extendedAddr": extendedAddr,
      "extendedAddr2": extendedAddr2,
      "city": city,
      "state": state,
      "country": country,
      "zip": zip
    });

    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.post(
        Uri.parse("https://localhost:8080/chargebee/register"),
        body: data,
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
}
