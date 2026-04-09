import 'dart:convert';
import 'dart:io';

import 'package:http/io_client.dart';
import 'package:lush/config/api_config.dart';
import 'package:lush/views/models/googleSignIn.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/models/user.dart';

class UserRepository {
  String? server = ApiConfig.baseUrl;
  bool userLoggedIn = false;
  User user =
      User.blank("", "", "", "", "", "", "", "", "", "", "", "", "", "");

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final HttpClient ioc = HttpClient();
  late String token;

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    SharedPreferences sharedPreferences = await _prefs;
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      var response = await http.get(
        Uri.parse('${server!}/api/test/ordersByCustomerId'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${sharedPreferences.getString("token")}",
        },
      );
      if (response.statusCode == 200) {
        var body = const Utf8Decoder().convert(response.bodyBytes);
        final dynamic decoded = json.decode(body);
        if (decoded is List) {
          return decoded.whereType<Map<String, dynamic>>().toList();
        }
        return [];
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  Future<String> getCartCheckoutUrl(
      List<Map<String, dynamic>> cartItems) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      var response = await http.post(
        Uri.parse('$server/api/test/cartCheckout'),
        headers: {
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
        body: jsonEncode(cartItems),
      );

      if (response.statusCode == 200) {
        var body = const Utf8Decoder().convert(response.bodyBytes);
        final dynamic jsonResponse = json.decode(body);
        if (jsonResponse is Map<String, dynamic>) {
          // The hosted page URL is usually in 'url' or 'hosted_page.url'
          final url = jsonResponse["url"] ??
              jsonResponse["hosted_page"]?["url"] ??
              jsonResponse["checkout_url"];
          return url?.toString() ?? jsonResponse.toString();
        }
        return jsonResponse.toString();
      } else {
        throw Exception(
            'Failed to get cart checkout URL: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting cart checkout URL: $e');
    }
  }

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

  /// TC-PROD-001: Fetch charge items from backend
  /// GET /api/test/charge-items
  /// Returns list of items with Delight/Signature/Premium categories
  /// and 200/300/500ml size prices
  Future<List<Map<String, dynamic>>> getChargeItems() async {
    SharedPreferences sharedPreferences = await _prefs;
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      
      print('🛒 Fetching charge items from: $server/api/test/charge-items');
      
      var response = await http.get(
        Uri.parse('$server/api/test/charge-items'),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
          "Authorization": "Bearer ${sharedPreferences.getString("token") ?? ''}",
        },
      );
      
      print('🛒 Response status: ${response.statusCode}');
      print('🛒 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        var body = const Utf8Decoder().convert(response.bodyBytes);
        final dynamic decoded = json.decode(body);
        
        if (decoded is List) {
          print('🛒 Successfully fetched ${decoded.length} items');
          return decoded.whereType<Map<String, dynamic>>().toList();
        }
        print('🛒 Response is not a list');
        return [];
      } else {
        print('🛒 Failed to load items: ${response.statusCode}');
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      print('🛒 Error fetching charge items: $e');
      // Return fallback data
      return _getFallbackChargeItems();
    }
  }

  /// Fallback charge items when API is unavailable
  List<Map<String, dynamic>> _getFallbackChargeItems() {
    return [
      {
        'itemId': 'delight_watermelon',
        'name': 'Watermelon',
        'description': 'Refreshing watermelon juice',
        'category': 'Delight',
        'imagePath': 'assets/watermelon.png',
        'startColor': '#FFB1C9',
        'endColor': '#B8292C',
        'calories': 525,
        'meals': ['Watermelon juice'],
        'enabledForCheckout': true,
        'prices': [
          {'id': 'watermelon_200', 'name': '200ml', 'price': 75.0, 'currencyCode': 'INR'},
          {'id': 'watermelon_300', 'name': '300ml', 'price': 99.0, 'currencyCode': 'INR'},
          {'id': 'watermelon_500', 'name': '500ml', 'price': 149.0, 'currencyCode': 'INR'},
        ],
      },
      {
        'itemId': 'delight_pineapple',
        'name': 'Pineapple',
        'description': 'Fresh pineapple juice',
        'category': 'Delight',
        'imagePath': 'assets/pineapple.png',
        'startColor': '#fad704',
        'endColor': '#ffd964',
        'calories': 602,
        'meals': ['Fresh pineapple', 'a pinch of salt'],
        'enabledForCheckout': true,
        'prices': [
          {'id': 'pineapple_200', 'name': '200ml', 'price': 75.0, 'currencyCode': 'INR'},
          {'id': 'pineapple_300', 'name': '300ml', 'price': 99.0, 'currencyCode': 'INR'},
          {'id': 'pineapple_500', 'name': '500ml', 'price': 149.0, 'currencyCode': 'INR'},
        ],
      },
      {
        'itemId': 'signature_abc',
        'name': 'ABC Juice',
        'description': 'Apple Beetroot Carrot blend',
        'category': 'Signature',
        'imagePath': 'assets/ABC.png',
        'startColor': '#673f45',
        'endColor': '#7a1f3d',
        'calories': 0,
        'meals': ['Apple', 'Beetroot', 'Carrot'],
        'enabledForCheckout': true,
        'prices': [
          {'id': 'abc_200', 'name': '200ml', 'price': 99.0, 'currencyCode': 'INR'},
          {'id': 'abc_300', 'name': '300ml', 'price': 129.0, 'currencyCode': 'INR'},
          {'id': 'abc_500', 'name': '500ml', 'price': 199.0, 'currencyCode': 'INR'},
        ],
      },
      {
        'itemId': 'signature_vitaminc',
        'name': 'Vitamin C',
        'description': 'Immune boosting blend',
        'category': 'Signature',
        'imagePath': 'assets/VitaminC.png',
        'startColor': '#FFF12D',
        'endColor': '#988623',
        'calories': 0,
        'meals': ['Amla', 'Pineapple', 'Tangerine'],
        'enabledForCheckout': true,
        'prices': [
          {'id': 'vitaminc_200', 'name': '200ml', 'price': 99.0, 'currencyCode': 'INR'},
          {'id': 'vitaminc_300', 'name': '300ml', 'price': 129.0, 'currencyCode': 'INR'},
          {'id': 'vitaminc_500', 'name': '500ml', 'price': 199.0, 'currencyCode': 'INR'},
        ],
      },
      {
        'itemId': 'premium_pbc',
        'name': 'Bloody Red',
        'description': 'Premium beetroot blend',
        'category': 'Premium',
        'imagePath': 'assets/PBC.png',
        'startColor': '#880808',
        'endColor': '#B8292C',
        'calories': 0,
        'meals': ['Beetroot', 'Pomegranate'],
        'enabledForCheckout': true,
        'prices': [
          {'id': 'pbc_200', 'name': '200ml', 'price': 129.0, 'currencyCode': 'INR'},
          {'id': 'pbc_300', 'name': '300ml', 'price': 169.0, 'currencyCode': 'INR'},
          {'id': 'pbc_500', 'name': '500ml', 'price': 249.0, 'currencyCode': 'INR'},
        ],
      },
    ];
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
        String token_ = json.decode(responseBody)['accessToken'] as String;
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
    String res = json.decode(body)["message"] as String;
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
        final accessToken = json.decode(body)['accessToken'] as String;
        sharedPreferences.setString("token", accessToken);
        token = accessToken;
        getUserDetailsFromServer();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Sign up with Google - includes googleId and photoUrl
  Future<String> signUpWithGoogle({
    required String email,
    required String phone,
    required String firstName,
    required String lastName,
    required String password,
    required String address,
    required String extendedAddr,
    required String extendedAddr2,
    required String city,
    required String state,
    required String zip,
    required String country,
    String? googleId,
    String? photoUrl,
  }) async {
    // Validate required fields
    if (phone.isEmpty) {
      return "Error: Phone number is required";
    }
    if (email.isEmpty) {
      return "Error: Email is required";
    }
    if (password.isEmpty) {
      return "Error: Password is required";
    }
    if (firstName.isEmpty) {
      return "Error: First name is required";
    }
    if (address.isEmpty) {
      return "Error: Address is required";
    }
    if (city.isEmpty) {
      return "Error: City is required";
    }
    if (state.isEmpty) {
      return "Error: State is required";
    }
    if (zip.isEmpty) {
      return "Error: ZIP code is required";
    }
    if (country.isEmpty) {
      return "Error: Country is required";
    }

    // Use unified signup endpoint with Google-specific fields
    final signupData = {
      'email': email.toLowerCase().trim(),
      'phone': phone.trim(),
      'password': password,
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'address': address.trim(),
      'extendedAddr': extendedAddr.trim(),
      'extendedAddr2': extendedAddr2.trim(),
      'city': city.trim(),
      'state': state.trim(),
      'zip': zip.trim(),
      'country': country.trim().toUpperCase(),
      if (googleId != null) 'googleId': googleId,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };

    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);

    try {
      print('📝 Signing up user with Google: $email');

      var response = await http.post(
        Uri.parse("$server/api/auth/unified-signup"),
        body: jsonEncode(signupData),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      var body = const Utf8Decoder().convert(response.bodyBytes);
      print('✅ Google Signup Response Status: ${response.statusCode}');
      print('📄 Response Body: $body');

      if (response.statusCode == 200) {
        final message = json.decode(body)['message'] as String? ?? 'User registered successfully';

        // Set user data
        user.setEmail = email;
        user.setPhone = phone;
        user.setFirstName = firstName;
        user.setLastName = lastName;
        user.setPassword = password;
        user.setId = email;

        // Persist credentials for auto-login
        await persistCredentials(email, password);

        // Try to auto-login to get JWT token
        final loginSuccess = await login(email, password, false);

        if (loginSuccess) {
          print('🎉 Google user registered and auto-logged in: $email');
          return message;
        } else {
          print('⚠️ Google user registered but auto-login failed');
          return message;
        }
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(body);
        final errorMsg = errorBody['message'] ?? 'Invalid request';
        return "Error: $errorMsg";
      } else {
        return "Error: ${response.statusCode} - ${json.decode(body)['message'] ?? 'Unknown error'}";
      }
    } catch (e) {
      return "Error: Failed to connect to server - $e";
    }
  }

  Future<String> signUp() async {
    // Validate required fields
    if (user.getPhone.isEmpty) {
      return "Error: Phone number is required";
    }
    if (user.getEmail.isEmpty) {
      return "Error: Email is required";
    }
    if (user.getPassword.isEmpty) {
      return "Error: Password is required";
    }
    if (user.getFirstName.isEmpty) {
      return "Error: First name is required";
    }
    if (user.getAddress.isEmpty) {
      return "Error: Address is required";
    }
    if (user.getCity.isEmpty) {
      return "Error: City is required";
    }
    if (user.getState.isEmpty) {
      return "Error: State is required";
    }
    if (user.getZip.isEmpty) {
      return "Error: ZIP code is required";
    }
    if (user.getCountry.isEmpty) {
      return "Error: Country is required";
    }

    // Use unified signup endpoint
    final signupData = {
      'email': user.getEmail.toLowerCase().trim(),
      'phone': user.getPhone.trim(),
      'password': user.getPassword,
      'firstName': user.getFirstName.trim(),
      'lastName': user.getLastName.trim(),
      'address': user.getAddress.trim(),
      'extendedAddr': user.getExtendedAddr.trim(),
      'extendedAddr2': user.getExtendedAddr2.trim(),
      'city': user.getCity.trim(),
      'state': user.getState.trim(),
      'zip': user.getZip.trim(),
      'country': user.getCountry.trim().toUpperCase(),
    };

    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);

    try {
      print('📝 Signing up user with unified signup: ${user.getEmail}');

      var response = await http.post(
        Uri.parse("$server/api/auth/unified-signup"),
        body: jsonEncode(signupData),
        headers: {
          "Accept": "application/json",
          "Content-Type": "application/json",
        },
      );

      var body = const Utf8Decoder().convert(response.bodyBytes);
      print('✅ Signup Response Status: ${response.statusCode}');
      print('📄 Response Body: $body');

      if (response.statusCode == 200) {
        final message = json.decode(body)['message'] as String? ?? 'User registered successfully';
        
        // Set user ID from server response or generate from email
        user.setId = user.getEmail;

        // Persist credentials for auto-login
        await persistCredentials(user.getEmail, user.getPassword);

        // Try to auto-login to get JWT token using email
        final loginSuccess =
            await login(user.getEmail, user.getPassword, false);

        if (loginSuccess) {
          print('🎉 User registered and auto-logged in: ${user.getEmail}');
          return message;
        } else {
          print('⚠️ User registered but auto-login failed');
          return message; // Signup was successful even if auto-login failed
        }
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(body);
        final errorMsg = errorBody['message'] ?? 'Invalid request';
        return "Error: $errorMsg";
      } else {
        return "Error: ${response.statusCode} - ${json.decode(body)['message'] ?? 'Unknown error'}";
      }
    } catch (e) {
      print('❌ Signup Error: $e');
      return "Error: ${e.toString()}";
    }
  }

  Future<String> sendOTP(String phoneNumber) async {
    try {
      print('📱 Sending OTP to: $phoneNumber');

      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      var response = await http.post(
        Uri.parse("$server/api/auth/send-otp"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ OTP sent successfully');
        return "OTP_SENT";
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        final errorMsg = errorBody['message'] ?? 'Invalid request';
        return "Error: $errorMsg";
      } else {
        return "Error: Failed to send OTP (${response.statusCode})";
      }
    } catch (e) {
      print('❌ Send OTP Error: $e');
      return "Error: ${e.toString()}";
    }
  }

  Future<String> verifyOTP(String otp) async {
    try {
      print('🔐 Verifying OTP: ${otp.substring(0, 2)}****');

      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      var response = await http.post(
        Uri.parse("$server/api/auth/verify-otp"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "phone": user.getPhone,
          "otp": otp,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ OTP verified successfully');
        return "OTP_VERIFIED";
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        final errorMsg = errorBody['message'] ?? 'Invalid OTP';
        return "Error: $errorMsg";
      } else {
        return "Error: OTP verification failed (${response.statusCode})";
      }
    } catch (e) {
      print('❌ Verify OTP Error: $e');
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
      // Use the new singleton helper for sign-in
      await GoogleSignInHelper.instance.signIn();
    } catch (error) {
      // print("error");
      return error;
    }

    final currentUser = GoogleSignInHelper.instance.currentUser;
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
    return user;
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
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        });

    if (response.statusCode == 200) {
      var body = const Utf8Decoder().convert(response.bodyBytes);
      final dynamic decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        final premiumData = decoded["premium"];
        final delightData = decoded["delight"];
        final signatureData = decoded["signature"];
        
        if (premiumData is Map<String, dynamic>) {
          sharedPreferences.setString(
              "premium_pricing_page_url", (premiumData["url"] as String?) ?? "");
          sharedPreferences.setInt("premium_pricing_page_url_expires_at",
              (premiumData['expires_at'] as int?) ?? 0);
        }
        if (delightData is Map<String, dynamic>) {
          sharedPreferences.setString(
              "delight_pricing_page_url", (delightData["url"] as String?) ?? "");
          sharedPreferences.setInt("delight_pricing_page_url_expires_at",
              (delightData['expires_at'] as int?) ?? 0);
        }
        if (signatureData is Map<String, dynamic>) {
          sharedPreferences.setString(
              "signature_pricing_page_url", (signatureData["url"] as String?) ?? "");
          sharedPreferences.setInt("signature_pricing_page_url_expires_at",
              (signatureData['expires_at'] as int?) ?? 0);
        }
      }
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
          "Authorization": "Bearer $token",
          "Accept": "application/json",
          "Content-Type": "application/json",
        });

    if (response.statusCode == 200) {
      var body = const Utf8Decoder().convert(response.bodyBytes);
      final dynamic decoded = json.decode(body);
      if (decoded is Map<String, dynamic>) {
        final url = decoded["access_url"];
        final expiresAt = decoded['expires_at'];
        
        if (url is String) {
          sharedPreferences.setInt("self_serve_page_url_expires_at",
              expiresAt is int ? expiresAt : 0);
          return url;
        }
      }
      return "Error: Invalid response format";
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
    user.setFirstName = json.decode(body)["firstName"] as String? ?? "";
    user.setLastName = json.decode(body)["lastName"] as String? ?? "";
    user.setEmail = json.decode(body)["email"] as String? ?? "";
    user.setPhone = json.decode(body)["username"] as String? ?? "";
    user.setAddress = json.decode(body)["address"] as String? ?? "";
    user.setExtendedAddr = json.decode(body)["extendedAddr"] as String? ?? "";
    user.setExtendedAddr2 = json.decode(body)["extendedAddr2"] as String? ?? "";
    user.setCity = json.decode(body)["city"] as String? ?? "";
    user.setState = json.decode(body)["state"] as String? ?? "";
    user.setCountry = json.decode(body)["country"] as String? ?? "";
    user.setId = json.decode(body)["id"].toString();
    user.setZip = json.decode(body)["zip"] as String? ?? "";
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
        Map<String, dynamic> responseJson = json.decode(body) as Map<String, dynamic>;

        // Extract URLs from the response
        Map<String, String> urls = {};

        if (responseJson.containsKey('premium') &&
            responseJson['premium'] is Map) {
          final premiumData = responseJson['premium'] as Map<String, dynamic>;
          if (premiumData.containsKey('hosted_page') &&
              premiumData['hosted_page'] is Map<String, dynamic>) {
            final hostedPage = premiumData['hosted_page'] as Map<String, dynamic>;
            if (hostedPage.containsKey('url')) {
              urls['premium'] = hostedPage['url'] as String;
            }
          }
        }

        if (responseJson.containsKey('signature') &&
            responseJson['signature'] is Map) {
          final signatureData =
              responseJson['signature'] as Map<String, dynamic>;
          if (signatureData.containsKey('hosted_page') &&
              signatureData['hosted_page'] is Map<String, dynamic>) {
            final hostedPageData = signatureData['hosted_page'] as Map<String, dynamic>;
            if (hostedPageData.containsKey('url')) {
              urls['signature'] = hostedPageData['url'] as String;
            }
          }
        }

        if (responseJson.containsKey('delight') &&
            responseJson['delight'] is Map) {
          final delightData = responseJson['delight'] as Map<String, dynamic>;
          if (delightData.containsKey('hosted_page') &&
              delightData['hosted_page'] is Map<String, dynamic>) {
            final hostedPage = delightData['hosted_page'] as Map<String, dynamic>;
            if (hostedPage.containsKey('url')) {
              urls['delight'] = hostedPage['url'] as String;
            }
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

  // ...existing code...
  // Use getCartCheckoutUrl(List<Map<String, dynamic>> cartItems) for cart checkout
}
