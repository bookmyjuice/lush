import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';
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

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final HttpClient ioc = HttpClient();
  late String token;
  Future<bool> isInternetAvailable() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
      return false;
    } on SocketException catch (_) {
      return false;
    }
  }

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
          sharedPreferences.setString("token", token_);
          token = token_;
          return true;
        } else {
          return AutologinWithToken();
        }
      }
    } else {
      return AutologinWithToken();
    }
  }

  Future<bool> AutologinWithToken() async {
    SharedPreferences sharedPreferences = await _prefs;
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
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

  Future<Map<String, String>> getSubscriptionPageUrl() async {
    SharedPreferences sharedPreferences = await _prefs;

    if (sharedPreferences
                .getInt("premium_pricing_page_url_expires_at") !=
            null &&
        sharedPreferences.getInt("delight_pricing_page_url_expires_at") !=
            null &&
        sharedPreferences.getInt("signature_pricing_page_url_expires_at") !=
            null) {
      if (isUrlvalid(sharedPreferences
              .getInt("premium_pricing_page_url_expires_at")!) &&
          isUrlvalid(sharedPreferences
              .getInt("delight_pricing_page_url_expires_at")!) &&
          isUrlvalid(sharedPreferences
              .getInt("signature_pricing_page_url_expires_at")!)) {
        return pricingPageUrlsMap();
      } else {
        try {
          await get_pricing_page_url();
          return pricingPageUrlsMap();
        } catch (e) {
          return {
            "premium": "could not get premium subscription page url",
            "delight": "could not get delight subscription page url",
            "signature": "could not get signature subscription page url"
          };
        }
      }
    } else {
      try {
        await get_pricing_page_url();
        return pricingPageUrlsMap();
      } catch (e) {
        return {
          "premium": "could not get premium subscription page url",
          "delight": "could not get delight subscription page url",
          "signature": "could not get signature subscription page url"
        };
      }
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

    final currentUser = MyGoogleSignIn.currentUser;
    if (currentUser == null) {
      return "Google Sign-In failed: No user found";
    }

    final displayName = currentUser.displayName;
    if (displayName != null && displayName.contains(" ")) {
      final nameParts = displayName.split(" ");
      user.setFirstName = nameParts[0];
      user.setLastName = nameParts.length > 1 ? nameParts[1] : "";
    } else {
      user.setFirstName = displayName ?? "";
      user.setLastName = "";
    }

    user.setEmail = currentUser.email;
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

  Future<void> get_pricing_page_url() async {
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
      sharedPreferences.setString(
          "premium_pricing_page_url", json.decode(body)["premium"]["url"]);
      sharedPreferences.setString(
          "delight_pricing_page_url", json.decode(body)["delight"]["url"]);
      sharedPreferences.setString(
          "signature_pricing_page_url", json.decode(body)["signature"]["url"]);
      sharedPreferences.setInt("premium_pricing_page_url_expires_at",
          json.decode(body)["premium"]['expires_at']);
      sharedPreferences.setInt("delight_pricing_page_url_expires_at",
          json.decode(body)["delight"]['expires_at']);
      sharedPreferences.setInt("signature_pricing_page_url_expires_at",
          json.decode(body)["signature"]['expires_at']);
    } else {
      throw Exception("Error: ${response.statusCode}");
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
    SharedPreferences sharedPreferences = await _prefs;
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.get(Uri.parse("$server/api/test/user"), headers: {
      "authorization": "Bearer $token",
      "Accept": "application/json",
      "Content-Type": "application/json",
    });
    var body = const Utf8Decoder().convert(response.bodyBytes);
    if (response.statusCode != 200) {
      response = await http.get(Uri.parse("$server/api/test/user"), headers: {
        "authorization": "Bearer ${sharedPreferences.getString('token')}",
        "Accept": "application/json",
        "Content-Type": "application/json",
      });
      body = const Utf8Decoder().convert(response.bodyBytes);
    }
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

  Future<Map<String, String>> pricingPageUrlsMap() async {
    try {
      // First try to get URLs from the backend
      final apiUrls = await getPricingPageUrls();
      if (apiUrls.isNotEmpty) {
        // Save to SharedPreferences for future use
        SharedPreferences sharedPreferences = await _prefs;
        for (var entry in apiUrls.entries) {
          await sharedPreferences.setString(
              "${entry.key}_pricing_page_url", entry.value);
        }
        return apiUrls;
      }
    } catch (e) {
      print('Error fetching pricing page URLs from API: $e');
      // Fall back to cached URLs if API call fails
    }

    // Fallback to cached URLs
    Map<String, String> urls = {"premium": "", "delight": "", "signature": ""};
    SharedPreferences sharedPreferences = await _prefs;
    urls["premium"] =
        sharedPreferences.getString("premium_pricing_page_url") ?? "";
    urls["delight"] =
        sharedPreferences.getString("delight_pricing_page_url") ?? "";
    urls["signature"] =
        sharedPreferences.getString("signature_pricing_page_url") ?? "";
    return urls;
  }

  /// Fetch pricing page URLs from the backend
  Future<Map<String, String>> getPricingPageUrls() async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      var response = await http.get(
        Uri.parse('$server/api/test/generate_pricing_page_session_url'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var body = const Utf8Decoder().convert(response.bodyBytes);
        Map<String, dynamic> responseJson = json.decode(body);

        // Extract URLs from the response
        Map<String, String> urls = {};

        if (responseJson.containsKey('premium') &&
            responseJson['premium'] is Map) {
          final premiumData = responseJson['premium'] as Map<String, dynamic>;
          if (premiumData.containsKey('hosted_page') &&
              premiumData['hosted_page'] is Map &&
              premiumData['hosted_page'].containsKey('url')) {
            urls['premium'] = premiumData['hosted_page']['url'];
          }
        }

        if (responseJson.containsKey('signature') &&
            responseJson['signature'] is Map) {
          final signatureData =
              responseJson['signature'] as Map<String, dynamic>;
          if (signatureData.containsKey('hosted_page') &&
              signatureData['hosted_page'] is Map &&
              signatureData['hosted_page'].containsKey('url')) {
            urls['signature'] = signatureData['hosted_page']['url'];
          }
        }

        if (responseJson.containsKey('delight') &&
            responseJson['delight'] is Map) {
          final delightData = responseJson['delight'] as Map<String, dynamic>;
          if (delightData.containsKey('hosted_page') &&
              delightData['hosted_page'] is Map &&
              delightData['hosted_page'].containsKey('url')) {
            urls['delight'] = delightData['hosted_page']['url'];
          }
        }

        return urls;
      } else {
        throw Exception(
            'Failed to load pricing page URLs: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getPricingPageUrls: $e');
      return {};
    }
  }

  /// Fetch charge items (one-time purchase items) from the backend
  /// These are the items displayed in the menu for one-time orders
  Future<List<Map<String, dynamic>>> getChargeItems() async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      var response = await http.get(
        Uri.parse('$server/api/test/charge-items'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var body = const Utf8Decoder().convert(response.bodyBytes);
        List<dynamic> chargeItemsJson = json.decode(body);

        // Convert to List<Map<String, dynamic>>
        List<Map<String, dynamic>> chargeItems = chargeItemsJson
            .map((item) => Map<String, dynamic>.from(item))
            .toList();

        print(
            'Successfully loaded ${chargeItems.length} charge items from API');
        return chargeItems;
      } else {
        print(
            'Failed to load charge items: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load charge items: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getChargeItems: $e');
      // Return default items if there's an error
      return getDefaultChargeItems();
    }
  }

  /// Get default charge items when backend is not available
  List<Map<String, dynamic>> getDefaultChargeItems() {
    return [
      {
        "id": "abc_default",
        "name": "ABC",
        "description": "Apple Beetroot Carrot juice",
        "imagePath": "assets/ABC.png",
        "startColor": "#673f45",
        "endColor": "#7a1f3d",
        "kacl": 120,
        "meals": ["Apple", "Beetroot", "Carrot"],
        "type": "CHARGE",
        "status": "ACTIVE",
        "itemFamilyId": "Premium",
        "itemPrices": [
          {
            "id": "abc_100ml",
            "name": "Small (100ml)",
            "description": "Perfect for a quick refreshment",
            "price": 50.0,
            "currencyCode": "INR",
            "period": null,
            "periodUnit": null,
            "pricingModel": "PER_UNIT"
          },
          {
            "id": "abc_200ml",
            "name": "Medium (200ml)",
            "description": "Good for regular consumption",
            "price": 90.0,
            "currencyCode": "INR",
            "period": null,
            "periodUnit": null,
            "pricingModel": "PER_UNIT"
          },
          {
            "id": "abc_500ml",
            "name": "Large (500ml)",
            "description": "Best value for money",
            "price": 200.0,
            "currencyCode": "INR",
            "period": null,
            "periodUnit": null,
            "pricingModel": "PER_UNIT"
          }
        ]
      },
      {
        "id": "pineapple_default",
        "name": "Pineapple",
        "description": "Fresh pineapple juice",
        "imagePath": "assets/pineapple.png",
        "startColor": "#fad704",
        "endColor": "#ffd964",
        "kacl": 602,
        "meals": ["Fresh pineapple", "Natural sweetness"],
        "type": "CHARGE",
        "status": "ACTIVE",
        "itemFamilyId": "Signature",
        "itemPrices": [
          {
            "id": "pineapple_100ml",
            "name": "Small (100ml)",
            "description": "Perfect for a quick refreshment",
            "price": 60.0,
            "currencyCode": "INR",
            "period": null,
            "periodUnit": null,
            "pricingModel": "PER_UNIT"
          },
          {
            "id": "pineapple_200ml",
            "name": "Medium (200ml)",
            "description": "Good for regular consumption",
            "price": 110.0,
            "currencyCode": "INR",
            "period": null,
            "periodUnit": null,
            "pricingModel": "PER_UNIT"
          }
        ]
      },
      {
        "juiceID": "watermelon_default",
        "name": "Watermelon",
        "description": "Fresh watermelon juice",
        "imagePath": "assets/watermelon.png",
        "startColor": "#FFB1C9",
        "endColor": "#B8292C",
        "kacl": 525,
        "meals": ["Fresh watermelon", "Hydrating"],
        "type": "CHARGE",
        "status": "ACTIVE"
      },
      {
        "juiceID": "vitamin_c_default",
        "name": "Vitamin C",
        "description": "Vitamin C rich juice",
        "imagePath": "assets/VitaminC.png",
        "startColor": "#FFF12D",
        "endColor": "#988623",
        "kacl": 180,
        "meals": ["Citrus fruits", "Immunity boost"],
        "type": "CHARGE",
        "status": "ACTIVE"
      }
    ];
  }

  /// Get cart checkout URL from Chargebee
  Future<String> getCartCheckoutUrl() async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      var response = await http.get(
        Uri.parse('$server/cartCheckout'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        var body = const Utf8Decoder().convert(response.bodyBytes);
        // Assuming the response contains a URL field
        var jsonResponse = json.decode(body);
        return jsonResponse["url"] ??
            jsonResponse["checkout_url"] ??
            jsonResponse.toString();
      } else {
        throw Exception(
            'Failed to get cart checkout URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting cart checkout URL: $e');
    }
  }
}
