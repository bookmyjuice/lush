import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/get_it.dart';
import 'package:lush/views/models/firebase_phone_auth.dart';
import '../../CartRepository/cart_repository.dart';
import '../../UserRepository/user_repository.dart';
import '../../utils/analytics_service.dart';
import 'auth_events.dart';
import 'auth_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository;
  final CartRepository? cartRepository;
  // Signup flow state storage
  String _signupEmail = '';
  String _signupPhone = '';
  String _signupFirstName = '';
  String _signupLastName = '';
  String _signupAddress = '';
  String _signupExtendedAddr = '';
  String _signupExtendedAddr2 = '';
  String _signupCity = '';
  String _signupState = '';
  String _signupZip = '';
  String _signupCountry = '';
  // BUG FIX 11: Loading guard to prevent double-tap sending multiple OTPs
  bool _isSendingOTP = false;

  AuthenticationBloc({UserRepository? repo, CartRepository? cartRepo})
      : userRepository = repo ?? getIt.get(),
        cartRepository = cartRepo,
        super(AuthenticationInProgress()) {
    on<AutoLogIn>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        final success = await userRepository.autoLogin();
        if (success) {
          emit(AuthenticationSuccess(userRepository.user));
          _syncCartAfterAuth();
        } else {
          emit(AutoLoginFailed(
              toastHeading: "AutoLogin Failed!", toastMessage: "Please login again or register"));
        }
      } catch (e) {
        debugPrint('AutoLogIn error: $e');
        emit(AutoLoginFailed(
            toastHeading: "AutoLogin Failed!", toastMessage: "Please login again or register"));
      }
    });
    on<LogIn>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        final loginSuccess =
            await userRepository.login(event.username, event.password, event.remember);
        if (loginSuccess) {
          await AnalyticsService.logLogin();
          emit(AuthenticationSuccess(userRepository.user));
          _syncCartAfterAuth();
        } else {
          emit(LogInFailed(
              toastHeading: "Login Failed!", toastMessage: "Please check your credentials!"));
        }
      } on SocketException catch (e) {
        emit(AuthError(error: 'Cannot connect to server.\n${e.address?.address}:${e.port}'));
      } catch (e) {
        emit(AuthError(error: 'Sign-In failed: $e'));
      }
    });
    on<LogOut>((event, emit) async {
      emit(AuthenticationInProgress());
      await userRepository.logout();
      emit(LoggedOut());
    });
    // ============================================================
    // NEW: Unified Signup Flow Handlers
    // ============================================================
    // Step 1: Choose signup method
    on<ChooseSignupMethod>((event, emit) {
      emit(SignupMethodSelected(method: event.method));
    });
    // Step 2a: Email-first flow - Enter email
    on<EnterEmail>((event, emit) async {
      // BUG FIX 3: Reset stale signup state when re-entering signup flow
      _resetSignupState();
      _signupEmail = event.email.toLowerCase().trim();
      emit(EmailEntered(email: _signupEmail));
      // BR-001: Call backend to send email verification code
      try {
        final response = await userRepository.sendEmailVerification(_signupEmail);
        if (response.contains('Success') || response.contains('sent')) {
          emit(EmailVerificationCodeSent(email: _signupEmail));
        } else {
          emit(EmailVerificationFailed(error: response));
        }
      } catch (e) {
        emit(EmailVerificationFailed(error: 'Failed to send verification code: $e'));
      }
    });

    // Step 2a: Verify email code
    on<VerifyEmail>((event, emit) async {
      // BUG FIX 4: Check for empty _signupEmail (never entered email flow)
      if (_signupEmail.isEmpty) {
        emit(const EmailVerificationFailed(
            error: 'No email in session. Please enter your email first.'));
        return;
      }

      if (event.email.toLowerCase().trim() != _signupEmail) {
        emit(const EmailVerificationFailed(error: 'Email mismatch. Please try again.'));
        return;
      }
      // BR-001: Call backend to verify email code
      try {
        final response = await userRepository.verifyEmailCode(event.email, event.verificationCode);
        if (response.contains('Success') || response.contains('verified')) {
          emit(EmailVerified(email: _signupEmail));
        } else {
          emit(EmailVerificationFailed(error: response));
        }
      } catch (e) {
        emit(EmailVerificationFailed(error: 'Verification failed: $e'));
      }
    });
    // Step 2b: Phone-first flow - Enter phone
    on<EnterPhone>((event, emit) {
      _signupPhone = event.phone.trim();
      emit(PhoneEntered(phone: _signupPhone));
    });
    // Send OTP to phone
    on<SendOTP>((event, emit) async {
      // BUG FIX 11: Prevent double-tap sending multiple OTPs
      if (_isSendingOTP) {
        emit(const OTPSendFailed(error: 'OTP already being sent. Please wait.'));
        return;
      }
      _isSendingOTP = true;
      _signupPhone = event.phoneNumber.trim();
      emit(PhoneEntered(phone: _signupPhone));
      final result = await userRepository.sendOTP(event.phoneNumber);
      _isSendingOTP = false;
      if (result.startsWith('Error:')) {
        final errorMsg = result.replaceFirst('Error: ', '');
        emit(OTPSendFailed(error: errorMsg));
      } else {
        emit(OTPSent(phoneNumber: _signupPhone));
      }
    });

    // Verify OTP

    on<VerifyOTP>((event, emit) async {
      final result = await userRepository.verifyOTP(event.otp);

      if (result.startsWith('Error:')) {
        final errorMsg = result.replaceFirst('Error: ', '');

        emit(OTPVerificationFailed(error: errorMsg));
      } else {
        emit(PhoneVerified(phone: _signupPhone));

        emit(OTPVerificationSuccess());
      }
    });

    // Resend OTP

    on<ResendOTP>((event, emit) async {
      // BUG FIX 11: Also guard resend against double-tap

      if (_isSendingOTP) {
        emit(const OTPSendFailed(error: 'OTP already being sent. Please wait.'));

        return;
      }

      if (_signupPhone.isNotEmpty) {
        _isSendingOTP = true;

        final result = await userRepository.sendOTP(_signupPhone);

        _isSendingOTP = false;

        if (result.startsWith('Error:')) {
          final errorMsg = result.replaceFirst('Error: ', '');

          emit(OTPSendFailed(error: errorMsg));
        } else {
          emit(OTPSent(phoneNumber: _signupPhone));
        }
      } else {
        emit(const OTPSendFailed(error: 'Phone number not set'));
      }
    });

    // Step 2c: Google signup - complete signup with all fields

    on<GoogleSignUpEnterPhone>((event, emit) async {
      _signupEmail = event.email.toLowerCase().trim();

      _signupPhone = event.phone.trim();

      _signupFirstName = event.firstName.trim();

      _signupLastName = event.lastName?.trim() ?? ''; // Handle nullable lastName

      // Store additional Google signup fields

      if (event.address != null) _signupAddress = event.address!.trim();

      if (event.extendedAddr != null) _signupExtendedAddr = event.extendedAddr!.trim();

      if (event.extendedAddr2 != null) _signupExtendedAddr2 = event.extendedAddr2!.trim();

      if (event.city != null) _signupCity = event.city!.trim();

      if (event.state != null) _signupState = event.state!.trim();

      if (event.zip != null) _signupZip = event.zip!.trim();

      if (event.country != null) _signupCountry = event.country!.trim().toUpperCase();

      // Email is already verified from Google

      emit(
        GoogleSignupEmailVerified(
          email: _signupEmail,
          firstName: _signupFirstName,
          lastName: _signupLastName,
        ),
      );

      // If all fields are provided, proceed with signup

      if (event.password != null && event.password!.isNotEmpty) {
        // BUG FIX: Check password confirmation before proceeding

        if (event.confirmPassword == null || event.password != event.confirmPassword) {
          emit(const SignUpFailed(
            errorHeading: 'Password Mismatch',
            error: 'Passwords do not match',
          ));

          return;
        }

        // Store password and trigger complete signup

        emit(AuthenticationInProgress());

        final result = await userRepository.signUpWithGoogle(
          email: _signupEmail,

          phone: _signupPhone,

          firstName: _signupFirstName,

          lastName: _signupLastName, // May be empty if Google didn't provide

          password: event.password!,

          address: _signupAddress,

          extendedAddr: _signupExtendedAddr,

          extendedAddr2: _signupExtendedAddr2,

          city: _signupCity,

          state: _signupState,

          zip: _signupZip,

          country: _signupCountry,

          googleId: event.googleId,

          photoUrl: event.photoUrl,
        );

        if (result.startsWith('Error:')) {
          final errorMsg = result.replaceFirst('Error: ', '');

          emit(SignUpFailed(error: errorMsg, errorHeading: 'SignUp Failed!'));
        } else {
          if (userRepository.userLoggedIn) {
            emit(AuthenticationSuccess(userRepository.user));
          } else {
            emit(SignUpSuccessful());
          }
        }
      }
    });

    // Step 3: Enter address

    on<EnterAddress>((event, emit) {
      // BUG FIX: Validate required address fields

      if (event.firstName.trim().isEmpty) {
        emit(const SignUpFailed(errorHeading: 'Validation Error', error: 'First name is required'));

        return;
      }

      if (event.lastName.trim().isEmpty) {
        emit(const SignUpFailed(errorHeading: 'Validation Error', error: 'Last name is required'));

        return;
      }

      if (event.address.trim().isEmpty) {
        emit(const SignUpFailed(errorHeading: 'Validation Error', error: 'Address is required'));

        return;
      }

      if (event.city.trim().isEmpty) {
        emit(const SignUpFailed(errorHeading: 'Validation Error', error: 'City is required'));

        return;
      }

      if (event.state.trim().isEmpty) {
        emit(const SignUpFailed(errorHeading: 'Validation Error', error: 'State is required'));
        return;
      }

      if (event.zip.trim().isEmpty) {
        emit(const SignUpFailed(errorHeading: 'Validation Error', error: 'ZIP code is required'));

        return;
      }

      if (event.country.trim().isEmpty) {
        emit(const SignUpFailed(errorHeading: 'Validation Error', error: 'Country is required'));

        return;
      }

      _signupFirstName = event.firstName.trim();

      _signupLastName = event.lastName.trim();

      _signupAddress = event.address.trim();

      _signupExtendedAddr = event.extendedAddr.trim();

      _signupExtendedAddr2 = event.extendedAddr2.trim();

      _signupCity = event.city.trim();

      _signupState = event.state.trim();

      _signupZip = event.zip.trim();

      _signupCountry = event.country.trim().toUpperCase();

      // BUG FIX: Emit only ReadyForFinalSignup (single state emission)

      // AddressEntered was always swallowed immediately by ReadyForFinalSignup

      emit(
        ReadyForFinalSignup(
          email: _signupEmail,
          phone: _signupPhone,
          firstName: _signupFirstName,
          lastName: _signupLastName,
          address: _signupAddress,
          extendedAddr: _signupExtendedAddr,
          extendedAddr2: _signupExtendedAddr2,
          city: _signupCity,
          state: _signupState,
          zip: _signupZip,
          country: _signupCountry,
        ),
      );
    });

    // Step 4: Complete signup with password

    on<CompleteSignup>((event, emit) async {
      if (event.password != event.confirmPassword) {
        emit(
            const SignUpFailed(errorHeading: 'Password Mismatch', error: 'Passwords do not match'));

        return;
      }

      emit(AuthenticationInProgress());

      // Prepare user data for signup

      userRepository.user.setEmail = _signupEmail;

      userRepository.user.setPhone = _signupPhone;

      userRepository.user.setFirstName = _signupFirstName;

      userRepository.user.setLastName = _signupLastName;

      userRepository.user.setPassword = event.password;

      userRepository.user.setAddress = _signupAddress;

      userRepository.user.setExtendedAddr = _signupExtendedAddr;

      userRepository.user.setExtendedAddr2 = _signupExtendedAddr2;

      userRepository.user.setCity = _signupCity;

      userRepository.user.setState = _signupState;

      userRepository.user.setZip = _signupZip;

      userRepository.user.setCountry = _signupCountry;

      final res = await userRepository.signUp();

      // BUG FIX 5: Reset signup state BEFORE emitting terminal state

      // _resetSignupState was being called AFTER emit, which means the state

      // was wiped but nobody could receive the last state.

      _resetSignupState();

      if (res.startsWith('Error:')) {
        final errorMsg = res.replaceFirst('Error: ', '');

        emit(SignUpFailed(error: errorMsg, errorHeading: 'SignUp Failed!'));
      } else {
        // BUG FIX 17: Clear plaintext password from User object after successful signup

        userRepository.user.setPassword = '';

        await AnalyticsService.logSignup(referralUsed: event.referralCode);

        if (userRepository.userLoggedIn) {
          emit(AuthenticationSuccess(userRepository.user));
          _syncCartAfterAuth();
        } else {
          emit(SignUpSuccessful());
        }
      }
    });

    // Legacy events

    // FIX: GoogleSignIn handler - distinguish new vs returning users
    on<GoogleSignIn>((event, emit) async {
      final res = await userRepository.googleSignIn();
      if (res == null) {
        emit(
          const AuthError(
            error: 'Google Sign-In Failed',
          ),
        );
      } else if (res is Map && res['type'] == 'login_success') {
        // User found - login successful
        emit(AuthenticationSuccess(userRepository.user));
        _syncCartAfterAuth();
      } else if (res is Map && res['type'] == 'network_error') {
        // BUG-001: Backend unreachable — show error, don't navigate to signup
        emit(AuthError(error: res['error'] as String));
      } else if (res is Map && res['type'] == 'link_required') {
        // BUG FIX: Use null-safe casts to prevent crash if keys are missing
        emit(
          GoogleLinkRequired(
            googleEmail: (res['googleEmail'] as String?) ?? '',
            googleFirstName: (res['googleFirstName'] as String?) ?? '',
            googleLastName: (res['googleLastName'] as String?) ?? '',
            googleId: (res['googleId'] as String?) ?? '',
            photoUrl: res['photoUrl'] as String?,
          ),
        );
      } else if (res is Map && res['type'] == 'signup_required') {
        // FIX: Check if user email already exists in backend before routing to signup
        final email = userRepository.user.getEmail;
        if (email.isNotEmpty) {
          final userExists = await userRepository.checkEmailExists(email);
          if (userExists) {
            // User already registered — sign them in directly
            debugPrint('✅ GoogleSignIn: Email $email found in system. Signing in existing user.');
            userRepository.userLoggedIn = true;
            emit(AuthenticationSuccess(userRepository.user));
            return;
          }
        }
        // User not found in backend — start signup flow for new user
        emit(SignUpStarted(user: userRepository.user));
      } else {
        // Error case
        emit(SignUpFailed(error: res.toString(), errorHeading: 'Google Sign-In Failed!'));
      }
    });

    on<MobileSignUp>((event, emit) {
      userRepository.user.setPhone = event.mobileNumber;

      emit(SignUpStarted(user: userRepository.user));
    });

    on<SignUp>((event, emit) async {
      emit(AuthenticationInProgress());

      final res = await userRepository.signUp();

      if (res.startsWith('Error:')) {
        final errorMsg = res.replaceFirst('Error: ', '');

        emit(SignUpFailed(error: errorMsg, errorHeading: 'SignUp Failed!'));
      } else {
        if (userRepository.userLoggedIn) {
          emit(AuthenticationSuccess(userRepository.user));
        } else {
          emit(SignUpSuccessful());
        }
      }
    });

    on<FacebookSignUp>((event, emit) {
      // BUG FIX 21: Provide meaningful response instead of no-op handler

      emit(const SignUpFailed(
        errorHeading: 'Coming Soon',
        error: 'Facebook sign-up is not yet available. Please use Email or Google sign-up.',
      ));
    });

    // ============================================================

    // Firebase Phone Auth Handlers (alternative to backend OTP)

    // ============================================================

    // Initiate Firebase Phone Auth verification

    on<FirebasePhoneSignIn>((event, emit) async {
      final phone = event.phoneNumber.trim();

      _signupPhone = phone;

      emit(PhoneEntered(phone: phone));

      emit(FirebasePhoneAuthInProgress(phone: phone));

      try {
        await FirebasePhoneAuth.instance.initiatePhoneVerification(
          phone: phone,
          onCodeSent: (verificationId) {
            // Dispatch event to update state

            add(FirebasePhoneOtpSent(verificationId: verificationId));
          },
          onError: (error) {
            add(FirebasePhoneAuthError(error: error));
          },
          onTimeout: () {
            add(const FirebasePhoneAuthError(error: 'SMS delivery timed out'));
          },
        );
      } catch (e) {
        emit(FirebasePhoneVerificationFailed(error: 'Firebase Phone Auth failed: $e'));
      }
    });

    // Firebase has sent the SMS code

    on<FirebasePhoneOtpSent>((event, emit) {
      emit(FirebasePhoneOtpSentState(
        phone: _signupPhone,
        verificationId: event.verificationId,
      ));
    });

    // Verify Firebase OTP code

    on<VerifyFirebaseOtp>((event, emit) async {
      final success = await FirebasePhoneAuth.instance.verifyPhoneOtp(event.smsCode);

      if (success) {
        emit(FirebasePhoneVerified(phone: _signupPhone));

        emit(PhoneVerified(phone: _signupPhone));
      } else {
        emit(const FirebasePhoneVerificationFailed(error: 'Invalid or expired verification code'));
      }
    });

    // Firebase Phone Auth error

    on<FirebasePhoneAuthError>((event, emit) {
      emit(FirebasePhoneVerificationFailed(error: event.error));
    });

    // FIX: FLAG-004 — Phone OTP Login handler (backend OTP flow, BR-011)
    on<PhoneOtpLogin>((event, emit) async {
      emit(AuthenticationInProgress());
      try {
        final result = await userRepository.loginViaPhoneOtp(event.phone, event.otp);

        if (result['type'] == 'login_success') {
          // User exists — login successful
          emit(AuthenticationSuccess(userRepository.user));
          _syncCartAfterAuth();
        } else if (result['type'] == 'signup_required') {
          // User doesn't exist — route to signup
          emit(SignUpStarted(user: userRepository.user));
        } else if (result['type'] == 'network_error') {
          emit(AuthError(error: result['error'] as String? ?? 'Cannot connect to server'));
        } else {
          emit(AuthError(error: result['error'] as String? ?? 'Login failed'));
        }
      } on SocketException catch (e) {
        emit(AuthError(error: 'Cannot connect to server.\n${e.address?.address}:${e.port}'));
      } catch (e) {
        emit(AuthError(error: 'Phone OTP login failed: $e'));
      }
    });
  }

  @override
  void onChange(Change<AuthenticationState> change) {
    super.onChange(change);

    debugPrint(change.toString());
  }

  @override
  void onTransition(Transition<AuthenticationEvent, AuthenticationState> transition) {
    super.onTransition(transition);

    debugPrint(transition.toString());
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);

    debugPrint(error.toString());
  }

  @override
  void onEvent(AuthenticationEvent event) {
    super.onEvent(event);

    debugPrint(event.toString());
  }

  /// FIX: P1-5 — Sync guest cart with backend after successful authentication.
  void _syncCartAfterAuth() {
    final repo = cartRepository ?? getIt.get<CartRepository>();
    repo.mergeGuestCartToBackend();
    repo.syncWithBackend();
  }

  void _resetSignupState() {
    _signupEmail = '';

    _signupPhone = '';

    _signupFirstName = '';

    _signupLastName = '';

    _signupAddress = '';

    _signupExtendedAddr = '';

    _signupExtendedAddr2 = '';

    _signupCity = '';

    _signupState = '';

    _signupZip = '';

    _signupCountry = '';
  }
}
