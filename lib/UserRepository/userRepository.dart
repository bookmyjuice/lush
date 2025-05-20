import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
import 'package:lush/getIt.dart';
import 'package:lush/views/models/googleSignIn.dart';
import 'package:lush/views/models/signUpRequest.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../views/models/user.dart';

class UserRepository {
  String server = "http://api.bookmyjuice.co.in:8080";
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
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    token = sharedPreferences.getString("token") ?? '*';
    if (token == '*') {
      final String? username = sharedPreferences.getString("username");
      final String? password = sharedPreferences.getString("password");

      if (username == null || password == null) {
        userLoggedIn = false;
        return false;
      } else {
        data = jsonEncode({"username": username, "password": password});
        var response = await http
            .post(Uri.parse("$server/api/auth/signin"), body: data, headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        });
        var responseBody = const Utf8Decoder().convert(response.bodyBytes);
        String token_ = json.decode(responseBody)['accessToken'];
        if (response.statusCode == 200) {
          sharedPreferences.setString("token", token);
          token = token_;
          return true;
        } else {
          return false;
        }
      }
    } else {
      var response =
          await http.get(Uri.parse("$server/api/auth/autologin"), headers: {
        "authorization": "Bearer $token",
        "Accept": "application/json",
        "Content-Type": "application/json",
      });
      var body = const Utf8Decoder().convert(response.bodyBytes);
      String res = json.decode(body)["message"];
      if (res == "ok") {
        userLoggedIn = true;
        await getUserDetailsFromServer();
        return true;
      } else {
        sharedPreferences.remove("token");
        userLoggedIn = false;
        return false;
      }
    }
  }

  Future<bool> login(String username_, String pwd, bool remember) async {
    SharedPreferences sharedPreferences = await _prefs;
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    try {
      var response = await http.post(Uri.parse('$server/api/auth/signin'),
          body: jsonEncode({"username": username_, "password": pwd}),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          });

      if (response.statusCode == 200) {
        if (remember == true) {
          persistCredentials(username_, pwd);
        }
        var body = const Utf8Decoder().convert(response.bodyBytes);
        // String token = json.decode(body)['accessToken'];
        sharedPreferences.setString("token", json.decode(body)['accessToken']);
        token = json.decode(body)['accessToken'];
        getUserDetailsFromServer();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<String> signUp() async {
    final SignupRequest data = SignupRequest(
      username: user.getPhone,
      email: user.getEmail,
      password: user.getPassword,
      address: user.getAddress,
      extendedAddr: user.getExtendedAddr,
      extendedAddr2: user.getExtendedAddr2,
      firstName: user.getFirstName,
      lastName: user.getLastName,
      city: user.getCity,
      state: user.getState,
      country: user.getCountry,
      zip: user.getZip,
      role: {"user"},
    );
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    try {
      var response = await http.post(Uri.parse("$server/api/auth/signup"),
          body: jsonEncode(data.toJson()),
          headers: {
            "Accept": "application/json",
            "Content-Type": "application/json",
          });
      var body = const Utf8Decoder().convert(response.bodyBytes);
      if (response.statusCode == 200) {
        user.setId = json.decode(body)['message'];
        return json.decode(body)['message'];
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  Future<String> getSubscriptionPageUrl() async {
    SharedPreferences sharedPreferences = await _prefs;

    if (sharedPreferences.getInt("pricing_page_url_expires_at") != null) {
      if (isUrlvalid(
          sharedPreferences.getInt("pricing_page_url_expires_at")!)) {
        if (sharedPreferences.getString("pricing_page_url") == null) {
          return get_pricing_page_url();
        } else {
          return sharedPreferences.getString("pricing_page_url")!;
        }
      } else {
        return get_pricing_page_url();
      }
    } else {
      return get_pricing_page_url();
    }
  }

  //   Future<void> verifyMobile(String mobileNumber) async {
  //     // Account account = Account(client);
  //     // // final u = account;
  //     // // account.updatePhone(phone: mobileNumber, password: u.);
  //     // account.createPhoneVerification();
  //   }

  //   Future<void> deleteToken() async {
  //     SharedPreferences sharedPreferences =
  //         await SharedPreferences.getInstance();
  //     sharedPreferences.remove("token");
  //   }

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
    if (await autoLogin() == true) {
      return token;
    } else {
      SharedPreferences sharedPreferences = await _prefs;
      String? token = sharedPreferences.getString("token");
      if (token == null) {
        return null;
      } else {
        if (await autoLogin() == true) {
          return token;
        } else {
          return null;
        }
      }
    }
  }

  //   Future<void> persistCustomerId(String customerId) async {
  //     SharedPreferences sharedPreferences =
  //         await SharedPreferences.getInstance();
  //     sharedPreferences.setString("customerId", customerId);
  //   }

  Future<Object?> googleSignIn_() async {
    try {
      await MyGoogleSignIn.login();
    } catch (error) {
      // print("error");
      return error;
    }
    user.setFirstName = MyGoogleSignIn.currentUser().displayName!.split(" ")[0];
    user.setLastName = MyGoogleSignIn.currentUser().displayName!.split(" ")[1];
    user.setEmail = MyGoogleSignIn.currentUser().email;
    // user.role = "User";
    return user;
    // return null;
  }

  bool isUrlvalid(int expiresAt) {
    return DateTime.now().toUtc().isAfter(
          DateTime.fromMillisecondsSinceEpoch(
            DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000)
                .millisecondsSinceEpoch,
            isUtc: true,
          ).toUtc(),
        );
  }

  Future<String> get_pricing_page_url() async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http
        .get(Uri.parse('$server/api/test/generate_pricing_page_session_url'),
            // body: jsonEncode({"customerId": user.getId}),
            headers: {
          "Authorization": "Bearer $token}",
          "Accept": "application/json",
          "Content-Type": "application/json",
        });

    if (response.statusCode == 200) {
      var body = const Utf8Decoder().convert(response.bodyBytes);
      String url = json.decode(body)["url"];

      // sharedPreferences.setInt(
      //     "url_expires_at", json.decode(body)['expires_at']);
      // Time expiresAt = DateTime.parse(json.decode(body)['expires_at']);
      sharedPreferences.setString("pricing_page_url", url);
      sharedPreferences.setInt(
          "pricing_page_url_expires_at", json.decode(body)['expires_at']);
      return url;
    } else {
      return "Error: ${response.statusCode}";
    }
  }

  Future<String> getSelfServePageUrl() async {
    SharedPreferences sharedPreferences = await _prefs;
    if (sharedPreferences.getInt("self_serve_page_url_expires_at") != null) {
      if (isUrlvalid(
          sharedPreferences.getInt("self_serve_page_url_expires_at")!)) {
        if (sharedPreferences.getString("self_serve_page_url") == null) {
          return get_self_serve_page_url();
        } else {
          return sharedPreferences.getString("self_serve_page_url")!;
        }
      } else {
        return get_self_serve_page_url();
      }
    } else {
      return get_self_serve_page_url();
    }
  }

  Future<String> get_self_serve_page_url() async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var response = await http.get(Uri.parse('$server/api/test/portal'),
        // body: jsonEncode({"customerId": user.getId}),
        headers: {
          "Authorization": "Bearer $token}",
          "Accept": "application/json",
          "Content-Type": "application/json",
        });

    if (response.statusCode == 200) {
      var body = const Utf8Decoder().convert(response.bodyBytes);
      String url = json.decode(body)["access_url"];
      sharedPreferences.setInt(
          "self_serve_page_url_expires_at", json.decode(body)['expires_at']);
      return url;
    } else {
      return "Error: ${response.statusCode}";
    }
  }

  Future<void> logout() async {
    SharedPreferences sharedPreferences = await _prefs;
    sharedPreferences.remove("token");
    sharedPreferences.remove("username");
    sharedPreferences.remove("password");
    sharedPreferences.remove("customerId");
    userLoggedIn = false;
  }

  Future<void> getUserDetailsFromServer() async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.get(Uri.parse("$server/api/test/user"), headers: {
      "authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    });
    var body = const Utf8Decoder().convert(response.bodyBytes);
    user.setFirstName = json.decode(body)["firstName"];
    user.setLastName = json.decode(body)["lastName"];
    user.setEmail = json.decode(body)["email"];
    user.setPhone = json.decode(body)["username"];
    user.setAddress = json.decode(body)["address"];
    user.setExtendedAddr = json.decode(body)["extendedAddr"];
    user.setExtendedAddr2 = json.decode(body)["extendedAddr2"];
    user.setCity = json.decode(body)["city"];
    user.setState = json.decode(body)["state"];
    user.setCountry = json.decode(body)["country"];
    user.setId = json.decode(body)["id"].toString();
    user.setZip = json.decode(body)["zip"];
    user.setRole = json
        .decode(body)["roles"][0]["name"]
        .toString()
        .substring(5, 9)
        .toLowerCase();
  }
}
