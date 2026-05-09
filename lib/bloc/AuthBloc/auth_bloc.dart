import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/get_it.dart';

import '../../UserRepository/user_repository.dart';
import 'auth_events.dart';
import 'auth_state.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository userRepository = getIt.get();

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

  AuthenticationBloc() : super(AuthenticationInProgress()) {
    on<AutoLogIn>((event, emit) async {
      emit(AuthenticationInProgress());
      await userRepository.isInternetAvailable()
          ? await userRepository.autoLogin()
              ? emit(AuthenticationSuccess(userRepository.user))
              : emit(AutoLoginFailed(
                  toast_heading: "AutoLogin Failed!",
                  toast_message: "Please login again or register"))
          : emit(InternetIssue(
              toast_heading: "No Internet Connection!",
              toast_message: "Please check your internet connection!"));
    });

    on<LogIn>((event, emit) async {
      emit(AuthenticationInProgress());
      await userRepository.isInternetAvailable()
          ? {
              await userRepository.login(event.username, event.password, event.remember)
                  ? emit(AuthenticationSuccess(userRepository.user))
                  : emit(LogInFailed(
                      toast_heading: "Login Failed!",
                      toast_message: "Please check your credentials!"))
            }
          : emit(InternetIssue(
              toast_heading: "No Internet Connection!",
              toast_message: "Please check your internet connection!"));
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
      if (event.email.toLowerCase().trim() != _signupEmail) {
        emit(const EmailVerificationFailed(error: 'Email mismatch. Please try again.'));
        return;
      }

      // BR-001: Call backend to verify email code
      try {
        final response = await userRepository.verifyEmailCode(
            event.email, event.verificationCode);
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
      _signupPhone = event.phoneNumber.trim();
      emit(PhoneEntered(phone: _signupPhone));

      final result = await userRepository.sendOTP(event.phoneNumber);
      if (result.startsWith("Error:")) {
        final errorMsg = result.replaceFirst("Error: ", "");
        emit(OTPSendFailed(error: errorMsg));
      } else {
        emit(OTPSent());
      }
    });

    // Verify OTP
    on<VerifyOTP>((event, emit) async {
      final result = await userRepository.verifyOTP(event.otp);
      if (result.startsWith("Error:")) {
        final errorMsg = result.replaceFirst("Error: ", "");
        emit(OTPVerificationFailed(error: errorMsg));
      } else {
        emit(PhoneVerified(phone: _signupPhone));
        emit(OTPVerificationSuccess());
      }
    });

    // Resend OTP
    on<ResendOTP>((event, emit) async {
      if (_signupPhone.isNotEmpty) {
        final result = await userRepository.sendOTP(_signupPhone);
        if (result.startsWith("Error:")) {
          final errorMsg = result.replaceFirst("Error: ", "");
          emit(OTPSendFailed(error: errorMsg));
        } else {
          emit(OTPSent());
        }
      } else {
        emit(const OTPSendFailed(error: "Phone number not set"));
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
      emit(GoogleSignupEmailVerified(
        email: _signupEmail,
        firstName: _signupFirstName,
        lastName: _signupLastName,
      ));

      // If all fields are provided, proceed with signup
      if (event.password != null && event.password!.isNotEmpty) {
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

        if (result.startsWith("Error:")) {
          final errorMsg = result.replaceFirst("Error: ", "");
          emit(SignUpFailed(error: errorMsg, error_heading: "SignUp Failed!"));
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
      _signupFirstName = event.firstName.trim();
      _signupLastName = event.lastName.trim();
      _signupAddress = event.address.trim();
      _signupExtendedAddr = event.extendedAddr.trim();
      _signupExtendedAddr2 = event.extendedAddr2.trim();
      _signupCity = event.city.trim();
      _signupState = event.state.trim();
      _signupZip = event.zip.trim();
      _signupCountry = event.country.trim().toUpperCase();

      emit(AddressEntered(
        firstName: _signupFirstName,
        lastName: _signupLastName,
        email: _signupEmail,
        phone: _signupPhone,
        address: _signupAddress,
        extendedAddr: _signupExtendedAddr,
        extendedAddr2: _signupExtendedAddr2,
        city: _signupCity,
        state: _signupState,
        zip: _signupZip,
        country: _signupCountry,
      ));

      emit(ReadyForFinalSignup(
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
      ));
    });

    // Step 4: Complete signup with password
    on<CompleteSignup>((event, emit) async {
      if (event.password != event.confirmPassword) {
        emit(const SignUpFailed(
            error_heading: "Password Mismatch", error: "Passwords do not match"));
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

      if (res.startsWith("Error:")) {
        final errorMsg = res.replaceFirst("Error: ", "");
        emit(SignUpFailed(error: errorMsg, error_heading: "SignUp Failed!"));
      } else {
        if (userRepository.userLoggedIn) {
          emit(AuthenticationSuccess(userRepository.user));
        } else {
          emit(SignUpSuccessful());
        }
      }

      // Reset signup state
      _resetSignupState();
    });

    // Legacy events
    on<GoogleSignIn>((event, emit) async {
      final res = await userRepository.googleSignIn_();
      if (res == null) {
        emit(const SignUpFailed(
            error: 'Google Sign-In Failed', error_heading: "Google Sign-In Failed!"));
      } else if (res is Map && res['type'] == 'login_success') {
        // User found - login successful
        emit(AuthenticationSuccess(userRepository.user));
      } else if (res is Map && res['type'] == 'link_required') {
        // No account found - show intermediate screen
        emit(GoogleLinkRequired(
          googleEmail: res['googleEmail'] as String,
          googleFirstName: res['googleFirstName'] as String,
          googleLastName: res['googleLastName'] as String,
          googleId: res['googleId'] as String,
          photoUrl: res['photoUrl'] as String?,
        ));
      } else if (res is Map && res['type'] == 'signup_required') {
        // User not found - start signup flow
        emit(SignUpStarted(user: userRepository.user));
      } else {
        // Error case
        emit(SignUpFailed(
            error: res.toString(), error_heading: "Google Sign-In Failed!"));
      }
    });

    on<MobileSignUp>((event, emit) {
      userRepository.user.setPhone = event.mobileNumber;
      emit(SignUpStarted(user: userRepository.user));
    });

    on<SignUp>((event, emit) async {
      emit(AuthenticationInProgress());

      final res = await userRepository.signUp();

      if (res.startsWith("Error:")) {
        final errorMsg = res.replaceFirst("Error: ", "");
        emit(SignUpFailed(error: errorMsg, error_heading: "SignUp Failed!"));
      } else {
        if (userRepository.userLoggedIn) {
          emit(AuthenticationSuccess(userRepository.user));
        } else {
          emit(SignUpSuccessful());
        }
      }
    });

    on<FacebookSignUp>((event, emit) {});

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
