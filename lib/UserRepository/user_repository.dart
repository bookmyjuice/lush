import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:lush/config/api_config.dart';
import 'package:lush/services/secure_storage_service.dart';
import 'package:lush/views/models/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../views/models/user.dart';

class UserRepository {
  String? server = ApiConfig.baseUrl;
  bool userLoggedIn = false;
  User user = User.blank();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final SecureStorageService _secureStorage = SecureStorageService();
  final HttpClient ioc = HttpClient();
  late String token;

  /// Fetch the authenticated customer's orders.
  /// GET /api/orders/by-customer (production).
  /// Returns a raw JSON array of order objects.
  Future<List<Map<String, dynamic>>> fetchOrders() async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();
      final response = await http.get(
        Uri.parse('${server!}/api/orders/by-customer'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );
      if (response.statusCode == 200) {
        final body = const Utf8Decoder().convert(response.bodyBytes);
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

  /// Create a Chargebee Hosted Page for one-time checkout from cart items.
  /// POST /api/v2/checkout/with-items (production).
  ///
  /// Request: { "items": [ { "price_id": <chargebee item price id>, "quantity": n } ] }
  /// Response: { "status": "success", "message": "...", "data": { "url": ... } }
  Future<String> getCartCheckoutUrl(
      List<Map<String, dynamic>> cartItems,) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();

      final response = await http.post(
        Uri.parse('$server/api/v2/checkout/with-items'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'items': cartItems}),
      );

      if (response.statusCode == 200) {
        final body = const Utf8Decoder().convert(response.bodyBytes);
        final dynamic jsonResponse = json.decode(body);
        if (jsonResponse is Map<String, dynamic>) {
          // Production contract (POST /api/v2/checkout/with-items):
          //   { "status": "success", "message": "...", "data": { "url": ... } }
          // Legacy shapes ('url', 'hosted_page.url', 'checkout_url') are kept as
          // fallbacks so older servers still resolve.
          final data = jsonResponse['data'];
          final url = (data is Map ? data['url'] : null) ??
              jsonResponse['url'] ??
              jsonResponse['hosted_page']?['url'] ??
              jsonResponse['checkout_url'];
          return url?.toString() ?? jsonResponse.toString();
        }
        return jsonResponse.toString();
      } else {
        final errorBody = const Utf8Decoder().convert(response.bodyBytes);
        throw Exception(
            'Failed to get cart checkout URL: ${response.statusCode} - $errorBody',);
      }
    } catch (e) {
      throw Exception('Error getting cart checkout URL: $e');
    }
  }

  /// BR-006: Check if an email already exists in the system
  /// GET /api/auth/check-email?email={email}
  /// Returns true if user exists, false otherwise
  Future<bool> checkEmailExists(String email) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final response = await http.get(
        Uri.parse('$server/api/auth/check-email?email=${Uri.encodeComponent(email)}'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        final body = const Utf8Decoder().convert(response.bodyBytes);
        final decoded = json.decode(body);
        if (decoded is Map<String, dynamic>) {
          return decoded['exists'] == true;
        }
      }
      return false;
    } catch (e) {
      debugPrint('⚠️ checkEmailExists error: $e');
      return false;
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
  /// GET /api/v1/catalog/charge-items
  /// Returns list of items with Delight/Signature/Premium categories
  /// and 200/300/500ml size prices
  Future<List<Map<String, dynamic>>> getChargeItems() async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();

      debugPrint('🛒 Fetching charge items from: $server/api/v1/catalog/charge-items');

      final response = await http.get(
        Uri.parse('$server/api/v1/catalog/charge-items'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': "Bearer ${authToken ?? ''}",
        },
      );
      
      debugPrint('🛒 Response status: ${response.statusCode}');
      debugPrint('🛒 Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        final body = const Utf8Decoder().convert(response.bodyBytes);
        final dynamic decoded = json.decode(body);
        
        if (decoded is List) {
          debugPrint('🛒 Successfully fetched ${decoded.length} items');
          return decoded.whereType<Map<String, dynamic>>().toList();
        }
        debugPrint('🛒 Response is not a list');
        return [];
      } else {
        debugPrint('🛒 Failed to load items: ${response.statusCode}');
        throw Exception('Failed to load items: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('🛒 Error fetching charge items: $e');
      // Return empty list on error — UI will handle empty state
      return [];
    }
  }

  /// BR-006: Auto-login decodes JWT locally to check token validity.
  /// JWT expiration is 30 days (2592000000ms). No network call is made.
  /// Expired or missing token requires manual re-login via login screen.
  /// No credential storage or silent re-authentication.
  Future<bool> autoLogin() async {
    token = (await _secureStorage.getAuthToken()) ?? '*';
    if (token == '*') {
      // BR-006: No credential fallback — user must manually login
      userLoggedIn = false;
      return false;
    }
    try {
      // Decode JWT locally to check expiry without network call
      final parts = token.split('.');
      if (parts.length != 3) {
        await _secureStorage.deleteAuthToken();
        userLoggedIn = false;
        return false;
      }
      // Pad base64 payload for decoding
      String payload = parts[1];
      payload = payload.padRight(payload.length + (4 - payload.length % 4) % 4, '=');
      payload = payload.replaceAll('-', '+').replaceAll('_', '/');
      final decoded = utf8.decode(base64.decode(payload));
      final Map<String, dynamic> claims = json.decode(decoded) as Map<String, dynamic>;
      
      // Check expiration
      final exp = claims['exp'] as int?;
      if (exp == null) {
        await _secureStorage.deleteAuthToken();
        userLoggedIn = false;
        return false;
      }
      final expiryTime = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      if (DateTime.now().toUtc().isAfter(expiryTime)) {
        // Token expired
        await _secureStorage.deleteAuthToken();
        userLoggedIn = false;
        return false;
      }
      
      // Token is valid — set user and fetch details from server
      userLoggedIn = true;
      await getUserDetailsFromServer();
      return true;
    } catch (e) {
      debugPrint('Auto-login JWT decode failed: $e');
      await _secureStorage.deleteAuthToken();
      userLoggedIn = false;
      return false;
    }
  }

  /// BR-006: No longer makes network call. Kept for backward compatibility.
  /// All token validation is done locally in autoLogin().
  @Deprecated('Use autoLogin() which decodes JWT locally')
  Future<bool> autologinWithToken() async {
    return autoLogin();
  }

  /// FIX: BUG-AUTH-002 — Propagate SocketException so the BLoC can emit AuthError
  /// instead of swallowing network errors as generic `false`.
  Future<bool> login(String username_, String pwd, bool remember) async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    try {
      final response = await http.post(Uri.parse('$server/api/auth/signin'),
          body: jsonEncode({'username': username_, 'password': pwd}),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },);

      if (response.statusCode == 200) {
        // BR-006: No credential storage - expired token requires manual re-login
        final body = const Utf8Decoder().convert(response.bodyBytes);
        final accessToken = json.decode(body)['accessToken'] as String;
        await _secureStorage.saveAuthToken(accessToken);
        token = accessToken;
        userLoggedIn = true;
        getUserDetailsFromServer();
        return true;
      } else {
        return false;
      }
    } on SocketException {
      // Re-throw so the BLoC can catch this and emit AuthError
      rethrow;
    } catch (e) {
      debugPrint('❌ BUG-AUTH-002: login() caught non-SocketException: $e');
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
      return 'Error: Phone number is required';
    }
    if (email.isEmpty) {
      return 'Error: Email is required';
    }
    if (password.isEmpty) {
      return 'Error: Password is required';
    }
    if (firstName.isEmpty) {
      return 'Error: First name is required';
    }
    if (address.isEmpty) {
      return 'Error: Address is required';
    }
    if (city.isEmpty) {
      return 'Error: City is required';
    }
    if (state.isEmpty) {
      return 'Error: State is required';
    }
    if (zip.isEmpty) {
      return 'Error: ZIP code is required';
    }
    if (country.isEmpty) {
      return 'Error: Country is required';
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
      debugPrint('📝 Signing up user with Google: $email');

      final response = await http.post(
        Uri.parse('$server/api/auth/unified-signup'),
        body: jsonEncode(signupData),
        headers: 
        {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final body = const Utf8Decoder().convert(response.bodyBytes);
      debugPrint('✅ Google Signup Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: $body');

      if (response.statusCode == 200) {
        final message = json.decode(body)['message'] as String? ?? 'User registered successfully';

        // Set user data
        user.setEmail = email;
        user.setPhone = phone;
        user.setFirstName = firstName;
        user.setLastName = lastName;
        user.setPassword = password;
        user.setId = email;

        // FIX: BUG-AUTH-004 — Try auto-login, but DON'T fail signup if network is down
        try {
          final loginSuccess = await login(phone, password, false);
          if (loginSuccess) {
            debugPrint('🎉 Google user registered and auto-logged in: $email');
          } else {
            debugPrint('⚠️ Google user registered but auto-login returned false');
          }
        } on SocketException catch (_) {
          debugPrint('⚠️ BUG-AUTH-004 (Google): Auto-login failed (network) but signup succeeded');
        }

        return message;
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(body);
        final errorMsg = errorBody['message'] ?? 'Invalid request';
        return 'Error: $errorMsg';
      } else {
        return "Error: ${response.statusCode} - ${json.decode(body)['message'] ?? 'Unknown error'}";
      }
    } catch (e) {
      return 'Error: Failed to connect to server - $e';
    }
  }

  /// FIX: BUG-AUTH-004 — Auto-login after signup may fail due to network.
  /// The signup itself succeeded on the server; return success even if auto-login fails.
  /// The user will see a success toast and can manually log in.
  Future<String> signUp() async {
    // Validate required fields
    if (user.getPhone.isEmpty) {
      return 'Error: Phone number is required';
    }
    if (user.getEmail.isEmpty) {
      return 'Error: Email is required';
    }
    if (user.getPassword.isEmpty) {
      return 'Error: Password is required';
    }
    if (user.getFirstName.isEmpty) {
      return 'Error: First name is required';
    }
    if (user.getAddress.isEmpty) {
      return 'Error: Address is required';
    }
    if (user.getCity.isEmpty) {
      return 'Error: City is required';
    }
    if (user.getState.isEmpty) {
      return 'Error: State is required';
    }
    if (user.getZip.isEmpty) {
      return 'Error: ZIP code is required';
    }
    if (user.getCountry.isEmpty) {
      return 'Error: Country is required';
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
      debugPrint('📝 Signing up user with unified signup: ${user.getEmail}');

      final response = await http.post(
        Uri.parse('$server/api/auth/unified-signup'),
        body: jsonEncode(signupData),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final body = const Utf8Decoder().convert(response.bodyBytes);
      debugPrint('✅ Signup Response Status: ${response.statusCode}');
      debugPrint('📄 Response Body: $body');

      if (response.statusCode == 200) {
        final message = json.decode(body)['message'] as String? ?? 'User registered successfully';
        
        // Set user ID from server response or generate from email
        user.setId = user.getEmail;

        // FIX: BUG-AUTH-004 — Try auto-login, but DON'T fail signup if network is down
        try {
          final loginSuccess = await login(user.getPhone, user.getPassword, false);
          if (loginSuccess) {
            debugPrint('🎉 User registered and auto-logged in: ${user.getEmail}');
          } else {
            debugPrint('⚠️ User registered but auto-login returned false');
          }
        } on SocketException catch (_) {
          // Signup succeeded on server; network blip for auto-login is non-fatal
          debugPrint('⚠️ BUG-AUTH-004: Auto-login failed (network) but signup succeeded');
        }

        // ✅ Signup was successful regardless of auto-login outcome
        return message;
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(body);
        final errorMsg = errorBody['message'] ?? 'Invalid request';
        return 'Error: $errorMsg';
      } else {
        return "Error: ${response.statusCode} - ${json.decode(body)['message'] ?? 'Unknown error'}";
      }
    } catch (e) {
      debugPrint('❌ Signup Error: $e');
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> sendOTP(String phoneNumber) async {
    try {
      debugPrint('📱 Sending OTP to: $phoneNumber');

      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      final response = await http.post(
        Uri.parse('$server/api/auth/send-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phoneNumber,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ OTP sent successfully');
        return 'OTP_SENT';
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        final errorMsg = errorBody['message'] ?? 'Invalid request';
        return 'Error: $errorMsg';
      } else {
        return 'Error: Failed to send OTP (${response.statusCode})';
      }
    } catch (e) {
      debugPrint('❌ Send OTP Error: $e');
      return 'Error: ${e.toString()}';
    }
  }

  Future<String> verifyOTP(String otp, {String? phone}) async {
    try {
      debugPrint('🔐 Verifying OTP: ${otp.substring(0, 2)}****');

      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      final response = await http.post(
        Uri.parse('$server/api/auth/verify-otp'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'phone': phone ?? user.getPhone,
          'otp': otp,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('✅ OTP verified successfully');
        return 'OTP_VERIFIED';
      } else if (response.statusCode == 400) {
        final errorBody = json.decode(response.body);
        final errorMsg = errorBody['message'] ?? 'Invalid OTP';
        return 'Error: $errorMsg';
      } else {
        return 'Error: OTP verification failed (${response.statusCode})';
      }
    } catch (e) {
      debugPrint('❌ Verify OTP Error: $e');
      return 'Error: ${e.toString()}';
    }
  }

  /// BR-001: Send email verification code via backend
  Future<String> sendEmailVerification(String email) async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    try {
      final response = await http.post(
        Uri.parse('$server/api/auth/send-email-verification'),
        body: jsonEncode({'email': email}),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      final body = const Utf8Decoder().convert(response.bodyBytes);
      return json.decode(body)['message'] as String;
    } catch (e) {
      return 'Error: Network error - $e';
    }
  }

  /// BR-001: Verify an email verification code via backend.
  ///
  /// Returns the signed `emailVerificationToken` on success; that token is the
  /// proof `/auth/phone-signup` requires (email is mandatory at signup).
  Future<Map<String, dynamic>> verifyEmailCode(String email, String code) async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    try {
      final response = await http.post(
        Uri.parse('$server/api/auth/verify-email-code'),
        body: jsonEncode({
          'email': email,
          'verificationCode': code,
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      final body = const Utf8Decoder().convert(response.bodyBytes);
      final decoded = json.decode(body) as Map<String, dynamic>;
      final message = decoded['message'] as String? ?? '';
      if (response.statusCode == 200 &&
          (decoded['emailVerificationToken'] as String? ?? '').isNotEmpty) {
        return {
          'status': 'success',
          'email': decoded['email'] as String? ?? email,
          'emailVerificationToken': decoded['emailVerificationToken'],
        };
      }
      return {
        'status': 'error',
        'error': message.isNotEmpty ? message : 'Invalid or expired code',
      };
    } catch (e) {
      return {'status': 'error', 'error': 'Network error - $e'};
    }
  }

  /// BR-009 Method 1: Reset password via mobile OTP
  Future<String> resetPasswordViaMobile({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    try {
      final response = await http.post(
        Uri.parse('$server/api/auth/reset-password-mobile'),
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
          'password': newPassword,
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      final body = const Utf8Decoder().convert(response.bodyBytes);
      return json.decode(body)['message'] as String;
    } catch (e) {
      return 'Error: Network error - $e';
    }
  }

  /// BR-009 Method 2: Reset password via email verification code
  Future<String> resetPasswordViaEmail({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    try {
      final response = await http.post(
        Uri.parse('$server/api/auth/reset-password-email'),
        body: jsonEncode({
          'email': email,
          'verificationCode': verificationCode,
          'password': newPassword,
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );
      final body = const Utf8Decoder().convert(response.bodyBytes);
      return json.decode(body)['message'] as String;
    } catch (e) {
      return 'Error: Network error - $e';
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
    await _secureStorage.saveAuthToken(token);
  }

  Future<String?> getToken() async {
    if (await autoLogin() == true) {
      return token;
    } else {
      final String? token = await _secureStorage.getAuthToken();
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

  Future<Object?> googleSignIn() async {
    try {
      // CORRECT:
      // final googleSignInAccount = await GoogleSignInHelper.instance.signIn();
      // final googleAuth = await googleSignInAccount.authentication; // await THIS
      // Step 1: Show Google account picker and get account
      final googleAccount = await GoogleSignInHelper.instance.signIn().then((credential) => credential);

      if (googleAccount == null) {
        return 'Google Sign-In cancelled: No account selected';
      }

      final currentUser = GoogleSignInHelper.instance.currentUser;
      if (currentUser == null) {
        return 'Google Sign-In Failed: No user found after sign-in';
      }

      final displayName = currentUser.displayName;
      if (displayName != null && displayName.contains(' ')) {
        final nameParts = displayName.split(' ');
        user.setFirstName = nameParts[0];
        user.setLastName = nameParts.length > 1 ? nameParts[1] : '';
      } else {
        user.setFirstName = displayName ?? '';
        user.setLastName = '';
      }

      user.setEmail = currentUser.email;

      // Step 2: Try to login via backend (user may already exist)
      // FIX: BUG-001 — Distinguish SocketException from "user not found"
      try {
        final linkResult = await _loginWithGoogle(currentUser.id, currentUser.email, currentUser.photoUrl);
        if (linkResult != null) {
          if (linkResult['type'] == 'login_success') {
            // User exists - login successful
            userLoggedIn = true;
            return {'type': 'login_success', 'token': linkResult['token'], 'user': user};
          } else if (linkResult['type'] == 'link_required') {
            // User not found - show intermediate screen to link account
            return {
              'type': 'link_required',
              'googleEmail': linkResult['googleEmail'],
              'googleFirstName': linkResult['googleFirstName'],
              'googleLastName': linkResult['googleLastName'],
              'googleId': linkResult['googleId'],
              'photoUrl': currentUser.photoUrl?.toString(),
            };
          }
        }
      } on SocketException catch (e) {
        // FIX: BUG-001 — Network error, NOT "user not found"
        debugPrint('❌ BUG-001: Google Sign-In network error (SocketException): $e');
        return {
          'type': 'network_error',
          'error': 'Cannot connect to server. Please check your network connection.\nServer: ${e.address?.address}:${e.port}',
        };
      } on http.ClientException catch (e) {
        debugPrint('❌ Google Sign-In network error (ClientException): $e');
        return {
          'type': 'network_error',
          'error': 'Connection error: ${e.message}',
        };
      } catch (e) {
        debugPrint('ℹ️ Google user not found via backend, starting signup flow: $e');
      }

      // Step 3: Return user data for signup flow
      return {'type': 'signup_required', 'user': user, 'googleId': currentUser.id, 'photoUrl': currentUser.photoUrl};
    } on SocketException catch (e) {
      // FIX: BUG-001 — Also catch outer-level network errors
      debugPrint('❌ BUG-001: Google Sign-In outer SocketException: $e');
      return {
        'type': 'network_error',
        'error': 'Cannot connect to server. Please check your network connection.\nServer: ${e.address?.address}:${e.port}',
      };
    } catch (error) {
      debugPrint('❌ Google Sign-In Error: $error');
      return 'Google Sign-In failed: $error';
    }
  }

  /// Login via Google: POST /api/auth/google with ID token
  /// Returns:
  /// - {'type': 'login_success', 'token': ...} if user found
  /// - {'type': 'link_required', 'googleEmail': ..., ...} if user not found (intermediate screen needed)
  /// - null if ID token unavailable
  Future<Map<String, dynamic>?> _loginWithGoogle(String googleId, String email, String? photoUrl) async {
    try {
      final googleAccount = GoogleSignInHelper.instance.currentUser;
      if (googleAccount == null) return null;

      final auth = await googleAccount.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        debugPrint('⚠️ No Google ID token, attempting email lookup');
        return null;
      }

      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      final response = await http.post(
        Uri.parse('$server/api/auth/google'),
        body: jsonEncode({'idToken': idToken}),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final status = body['status'] as String?;

        if (status == 'link_required') {
          // No account found - show intermediate screen
          return {
            'type': 'link_required',
            'googleEmail': body['googleEmail'] as String? ?? email,
            'googleFirstName': body['googleFirstName'] as String? ?? '',
            'googleLastName': body['googleLastName'] as String? ?? '',
            'googleId': body['googleId'] as String? ?? googleId,
          };
        } else {
          // User found - login successful
          final token = body['accessToken'] as String?;
          if (token != null) {
            // Save token to SecureStorage for auto-login persistence
            await _secureStorage.saveAuthToken(token);
            final prefs = await _prefs;
            prefs.setString('token', token);
            this.token = token;
            userLoggedIn = true;
            await getUserDetailsFromServer();
            return {'type': 'login_success', 'token': token, 'user': user};
          }
        }
      }
    } on SocketException {
      // Propagate network errors so the outer googleSignIn() can emit AuthError
      rethrow;
    } on http.ClientException {
      rethrow;
    } catch (e) {
      debugPrint('⚠️ Google login failed: $e');
    }
    return null;
  }

  /// Login via Phone OTP: POST /api/auth/login-otp
  /// Verifies OTP, then either logs in existing user OR returns signup_required
  Future<Map<String, dynamic>> loginViaPhoneOtp(String phone, String otp) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      final response = await http.post(
        Uri.parse('$server/api/auth/login-otp'),
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final body = json.decode(response.body);
      final message = body['message'] as String? ?? '';

      if (response.statusCode == 200) {
        if (body['status'] == 'user_not_found') {
          // OTP verified but user doesn't exist - start signup
          return {
            'type': 'signup_required',
            'phone': phone,
            'signupToken': body['signupToken'] as String? ?? '',
          };
        } else {
          // User exists - login successful
          final token = body['accessToken'] as String?;
          if (token != null) {
            final prefs = await _prefs;
            prefs.setString('token', token);
            this.token = token;
            userLoggedIn = true;
            await getUserDetailsFromServer();
            return {'type': 'login_success', 'token': token, 'user': user};
          }
        }
      }

      return {'error': message};
    } catch (e) {
      debugPrint('❌ Phone OTP login failed: $e');
      return {'error': 'Phone OTP login failed: $e'};
    }
  }

  /// A-1: complete a phone-first signup with a verified phone number and email.
  /// POST /api/auth/phone-signup  (body carries the `signupToken`)
  Future<Map<String, dynamic>> completePhoneSignup({
    required String signupToken,
    required String firstName,
    required String lastName,
    required String email,
    required String emailVerificationToken,
    String address = '',
    String extendedAddr = '',
    String extendedAddr2 = '',
    String city = '',
    String state = '',
    String zip = '',
    String country = '',
  }) async {
    if (signupToken.isEmpty) {
      return {
        'error': 'Phone verification expired. Please verify your number again.',
      };
    }
    if (email.trim().isEmpty || emailVerificationToken.isEmpty) {
      return {
        'error': 'Email verification expired. Please verify your email again.',
      };
    }

    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final httpClient = IOClient(ioc);

      final response = await httpClient.post(
        Uri.parse('$server/api/auth/phone-signup'),
        body: jsonEncode({
          'signupToken': signupToken,
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'email': email.trim(),
          'emailVerificationToken': emailVerificationToken,
          'address': address.trim(),
          'extendedAddr': extendedAddr.trim(),
          'extendedAddr2': extendedAddr2.trim(),
          'city': city.trim(),
          'state': state.trim(),
          'zip': zip.trim(),
          'country': country.trim().toUpperCase(),
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      return await _handleSignupResponse(response);
    } catch (e) {
      debugPrint('❌ Phone signup failed: $e');
      return {'error': 'Could not create your account: $e'};
    }
  }

  /// A-1: complete a Google-first signup. The Google ID token is taken from
  /// the live Google session, never from a client-supplied id.
  /// POST /api/auth/google-signup
  Future<Map<String, dynamic>> completeGoogleSignup({
    required String signupToken,
    required String address,
    required String extendedAddr,
    required String extendedAddr2,
    required String city,
    required String state,
    required String zip,
    required String country,
  }) async {
    if (signupToken.isEmpty) {
      return {
        'error': 'Phone verification expired. Please verify your number again.',
      };
    }

    try {
      final account = GoogleSignInHelper.instance.currentUser;
      if (account == null) {
        return {
          'error': 'Google session expired. Please sign in with Google again.',
        };
      }

      final auth = await account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        return {
          'error': 'Google did not return an identity token. Please try again.',
        };
      }

      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final httpClient = IOClient(ioc);

      final response = await httpClient.post(
        Uri.parse('$server/api/auth/google-signup'),
        body: jsonEncode({
          'idToken': idToken,
          'signupToken': signupToken,
          'address': address.trim(),
          'extendedAddr': extendedAddr.trim(),
          'extendedAddr2': extendedAddr2.trim(),
          'city': city.trim(),
          'state': state.trim(),
          'zip': zip.trim(),
          'country': country.trim().toUpperCase(),
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      return await _handleSignupResponse(response);
    } catch (e) {
      debugPrint('❌ Google signup failed: $e');
      return {'error': 'Could not create your account: $e'};
    }
  }

  /// Shared success path for the passwordless signup endpoints: the server
  /// returns a JWT, so the new account is signed in immediately.
  Future<Map<String, dynamic>> _handleSignupResponse(
    http.Response response,
  ) async {
    final body = const Utf8Decoder().convert(response.bodyBytes);
    Map<String, dynamic> decoded = <String, dynamic>{};
    if (body.isNotEmpty) {
      try {
        decoded = json.decode(body) as Map<String, dynamic>;
      } catch (_) {
        decoded = <String, dynamic>{};
      }
    }

    if (response.statusCode == 200) {
      final accessToken = decoded['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        return {
          'error': 'Account created but sign-in failed. Please sign in again.',
        };
      }
      await _secureStorage.saveAuthToken(accessToken);
      token = accessToken;
      userLoggedIn = true;
      await getUserDetailsFromServer();
      return {'type': 'login_success', 'token': accessToken, 'user': user};
    }

    final message =
        decoded['message'] as String? ?? 'Could not create your account';
    return {'error': message.replaceFirst('Error: ', '')};
  }

  /// #2 UX: Link Google account to existing user
  Future<Map<String, dynamic>> linkGoogleAccount({
    required String phone,
    required String otp,
    required String googleId,
    String? photoUrl,
  }) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      final response = await http.post(
        Uri.parse('$server/api/auth/link-google-account'),
        body: jsonEncode({
          'phone': phone,
          'otp': otp,
          'googleId': googleId,
          if (photoUrl != null) 'photoUrl': photoUrl,
        }),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        final token = body['accessToken'] as String?;
        if (token != null) {
          final prefs = await _prefs;
          prefs.setString('token', token);
          this.token = token;
          userLoggedIn = true;
          await getUserDetailsFromServer();
          return {'type': 'login_success', 'token': token, 'user': user};
        }
      }

      return {'error': body['message'] ?? 'Failed to link Google account'};
    } catch (e) {
      debugPrint('❌ Link Google account failed: $e');
      return {'error': 'Link Google account failed: $e'};
    }
  }

  /// #9 UX: Delete user account (soft delete)
  Future<String> deleteAccount() async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);

      final response = await http.delete(
        Uri.parse('$server/api/auth/account'),
        headers: {
          'authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      final body = const Utf8Decoder().convert(response.bodyBytes);
      if (response.statusCode == 200) {
        // Clear local session
        await logout();
        return json.decode(body)['message'] as String;
      } else {
        return "Error: ${json.decode(body)['message'] ?? 'Failed to delete account'}";
      }
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<void> logout() async {
    await _secureStorage.deleteAuthToken();
    final SharedPreferences sharedPreferences = await _prefs;
    sharedPreferences
      ..remove('username')
      ..remove('customerId');
    userLoggedIn = false;
  }

  Future<void> getUserDetailsFromServer() async {
    ioc.badCertificateCallback =
        (X509Certificate cert, String host, int port) => true;
    final http = IOClient(ioc);
    var response = await http.get(Uri.parse('$server/api/v1/user/profile'), headers: {
      'authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },);
    var body = const Utf8Decoder().convert(response.bodyBytes);
    if (response.statusCode != 200) {
      final fallbackToken = (await _secureStorage.getAuthToken()) ?? '';
      response = await http.get(Uri.parse('$server/api/v1/user/profile'), headers: {
        'authorization': 'Bearer $fallbackToken',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },);
      body = const Utf8Decoder().convert(response.bodyBytes);
    }
    user.setFirstName = json.decode(body)['firstName'] as String? ?? '';
    user.setLastName = json.decode(body)['lastName'] as String? ?? '';
    user.setEmail = json.decode(body)['email'] as String? ?? '';
    // BUG FIX: Prefer 'phone' field from server, fallback to 'username' for backward compatibility
    final serverPhone = json.decode(body)['phone'] as String? ?? '';
    user.setPhone = serverPhone.isNotEmpty ? serverPhone : (json.decode(body)['username'] as String? ?? '');
    user.setAddress = json.decode(body)['address'] as String? ?? '';
    user.setExtendedAddr = json.decode(body)['extendedAddr'] as String? ?? '';
    user.setExtendedAddr2 = json.decode(body)['extendedAddr2'] as String? ?? '';
    user.setCity = json.decode(body)['city'] as String? ?? '';
    user.setState = json.decode(body)['state'] as String? ?? '';
    user.setCountry = json.decode(body)['country'] as String? ?? '';
    user.setId = json.decode(body)['id'].toString();
    user.setZip = json.decode(body)['zip'] as String? ?? '';
    user.setRole = json
        .decode(body)['roles'][0]['name']
        .toString()
        .substring(5, 9)
        .toLowerCase();
  }
  // ==================== Delivery Domain API Methods ====================

  /// FR-DEL-001: Check if a pincode is serviceable
  /// GET /api/v1/delivery/service-areas?pincode={pincode}
  Future<Map<String, dynamic>> checkServiceability(String pincode) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();

      final response = await http.get(
        Uri.parse('$server/api/v1/delivery/service-areas?pincode=$pincode'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final body = const Utf8Decoder().convert(response.bodyBytes);
        return json.decode(body) as Map<String, dynamic>;
      } else if (response.statusCode == 404) {
        return {
          'status': 'error',
          'message': 'Pincode not serviceable',
          'serviced': false,
        };
      } else {
        return {
          'status': 'error',
          'message': 'Failed to check serviceability: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Error checking serviceability: $e',
      };
    }
  }

  /// FR-DEL-002: Get available delivery slots for a service area and date
  /// GET /api/v1/delivery/slots?serviceAreaId={id}&date={date}
  Future<Map<String, dynamic>> getAvailableSlots(
      int serviceAreaId, String date,) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();

      final response = await http.get(
        Uri.parse(
            '$server/api/v1/delivery/slots?serviceAreaId=$serviceAreaId&date=$date',),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final body = const Utf8Decoder().convert(response.bodyBytes);
        return json.decode(body) as Map<String, dynamic>;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to get slots: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error getting slots: $e'};
    }
  }

  /// FR-DEL-003: Get all addresses for the logged-in user
  /// GET /api/v1/delivery/addresses
  Future<Map<String, dynamic>> getUserAddresses() async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();

      final response = await http.get(
        Uri.parse('$server/api/v1/delivery/addresses'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      if (response.statusCode == 200) {
        final body = const Utf8Decoder().convert(response.bodyBytes);
        return json.decode(body) as Map<String, dynamic>;
      } else {
        return {
          'status': 'error',
          'message': 'Failed to get addresses: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error getting addresses: $e'};
    }
  }

  /// FR-DEL-004: Add a new delivery address
  /// POST /api/v1/delivery/addresses
  Future<Map<String, dynamic>> addUserAddress(
      Map<String, dynamic> addressData,) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();

      final response = await http.post(
        Uri.parse('$server/api/v1/delivery/addresses'),
        body: jsonEncode(addressData),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final body = const Utf8Decoder().convert(response.bodyBytes);
      return json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Error adding address: $e'};
    }
  }

  /// FR-DEL-005: Update an existing delivery address
  /// PUT /api/v1/delivery/addresses/{id}
  Future<Map<String, dynamic>> updateUserAddress(
      int id, Map<String, dynamic> addressData,) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();

      final response = await http.put(
        Uri.parse('$server/api/v1/delivery/addresses/$id'),
        body: jsonEncode(addressData),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final body = const Utf8Decoder().convert(response.bodyBytes);
      return json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Error updating address: $e'};
    }
  }

  /// FR-DEL-006: Delete a delivery address
  /// DELETE /api/v1/delivery/addresses/{id}
  Future<Map<String, dynamic>> deleteUserAddress(int id) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();

      final response = await http.delete(
        Uri.parse('$server/api/v1/delivery/addresses/$id'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final body = const Utf8Decoder().convert(response.bodyBytes);
      return json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Error deleting address: $e'};
    }
  }

  /// FR-DEL-007: Set a delivery address as default
  /// PATCH /api/v1/delivery/addresses/{id}/default
  Future<Map<String, dynamic>> setDefaultAddress(int id) async {
    try {
      ioc.badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
      final http = IOClient(ioc);
      final authToken = await _secureStorage.getAuthToken();

      final response = await http.patch(
        Uri.parse('$server/api/v1/delivery/addresses/$id/default'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      );

      final body = const Utf8Decoder().convert(response.bodyBytes);
      return json.decode(body) as Map<String, dynamic>;
    } catch (e) {
      return {'status': 'error', 'message': 'Error setting default address: $e'};
    }
  }

  // Use getCartCheckoutUrl(List<Map<String, dynamic>> cartItems) for cart checkout
}
