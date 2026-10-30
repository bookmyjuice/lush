import 'package:equatable/equatable.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

class LogOut extends AuthenticationEvent {}

class AutoLogIn extends AuthenticationEvent {}

class LogIn extends AuthenticationEvent {
  final String username;
  final String password;
  final bool remember;
  const LogIn(this.username, this.password, this.remember);
  @override
  List<Object> get props => [username, password, remember];
}

class GoogleSignIn extends AuthenticationEvent {
  const GoogleSignIn();

  @override
  List<Object> get props => [];
}

// ============================================================
// NEW: Unified Signup Flow Events
// ============================================================

// Step 1: Choose signup method
class ChooseSignupMethod extends AuthenticationEvent {
  final String method; // 'email', 'phone', 'google'

  const ChooseSignupMethod({required this.method});

  @override
  List<Object> get props => [method];
}

// Step 2a: Email-first flow
class EnterEmail extends AuthenticationEvent {
  final String email;

  const EnterEmail({required this.email});

  @override
  List<Object> get props => [email];
}

class VerifyEmail extends AuthenticationEvent {
  final String email;
  final String verificationCode;

  const VerifyEmail({required this.email, required this.verificationCode});

  @override
  List<Object> get props => [email, verificationCode];
}

// Step 2b: Phone-first flow
class EnterPhone extends AuthenticationEvent {
  final String phone;

  const EnterPhone({required this.phone});

  @override
  List<Object> get props => [phone];
}

class SendOTP extends AuthenticationEvent {
  final String phoneNumber;

  const SendOTP({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyOTP extends AuthenticationEvent {
  final String otp;
  final String phone;

  const VerifyOTP({required this.otp, required this.phone});

  @override
  List<Object> get props => [otp, phone];
}


class ResendOTP extends AuthenticationEvent {
  const ResendOTP();

  @override
  List<Object> get props => [];
}

// Step 2c: Google signup (email auto-verified)
// Note: Google may not always provide lastName, so it's optional
class GoogleSignUpEnterPhone extends AuthenticationEvent {
  final String phone;
  final String email;
  final String firstName;
  final String? lastName; // Optional - Google may not provide this

  // Additional fields for complete Google signup
  final String? address;
  final String? extendedAddr;
  final String? extendedAddr2;
  final String? city;
  final String? state;
  final String? zip;
  final String? country;
  final String? password;
  final String? confirmPassword;
  final String? googleId;
  final String? photoUrl;

  const GoogleSignUpEnterPhone({
    required this.phone,
    required this.email,
    required this.firstName,
    this.lastName,
    this.address,
    this.extendedAddr,
    this.extendedAddr2,
    this.city,
    this.state,
    this.zip,
    this.country,
    this.password,
    this.confirmPassword,
    this.googleId,
    this.photoUrl,
  });

  @override
  List<Object> get props => [
        phone,
        email,
        firstName,
        lastName ?? '',
        address ?? '',
        extendedAddr ?? '',
        extendedAddr2 ?? '',
        city ?? '',
        state ?? '',
        zip ?? '',
        country ?? '',
        password ?? '',
        confirmPassword ?? '',
        googleId ?? '',
        photoUrl ?? '',
      ];
}

// Step 3: Address entry (common for all flows)
class EnterAddress extends AuthenticationEvent {
  final String firstName;
  final String lastName;
  final String address;
  final String extendedAddr;
  final String extendedAddr2;
  final String city;
  final String state;
  final String zip;
  final String country;

  const EnterAddress({
    required this.firstName,
    required this.lastName,
    required this.address,
    required this.extendedAddr,
    required this.extendedAddr2,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  @override
  List<Object> get props => [
        firstName,
        lastName,
        address,
        extendedAddr,
        extendedAddr2,
        city,
        state,
        zip,
        country,
      ];
}

// Step 4: Final signup with password
class CompleteSignup extends AuthenticationEvent {
  final String password;
  final String confirmPassword;
  final String? referralCode;

  const CompleteSignup({
    required this.password,
    required this.confirmPassword,
    this.referralCode,
  });

  @override
  List<Object> get props => [password, confirmPassword, referralCode ?? ''];
}

// Legacy events (keep for backward compatibility)
class MobileSignUp extends AuthenticationEvent {
  final String mobileNumber;

  const MobileSignUp({required this.mobileNumber});
  @override
  List<Object> get props => [mobileNumber];
}

class FacebookSignUp extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}

class SignUp extends AuthenticationEvent {
  @override
  List<Object> get props => [];
}

// ============================================================
// Passwordless signup completion (A-1)
// ============================================================

/// Complete a phone-first signup with the verified [signupToken].
class PhoneSignupRequested extends AuthenticationEvent {
  final String signupToken;
  final String firstName;
  final String lastName;
  final String email;

  /// Proof that [email] passed the email OTP check (mandatory at signup).
  final String emailVerificationToken;
  final String address;
  final String extendedAddr;
  final String extendedAddr2;
  final String city;
  final String state;
  final String zip;
  final String country;

  const PhoneSignupRequested({
    required this.signupToken,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.emailVerificationToken,
    required this.address,
    required this.extendedAddr,
    required this.extendedAddr2,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  @override
  List<Object> get props => [
        signupToken,
        firstName,
        lastName,
        email,
        emailVerificationToken,
        address,
        extendedAddr,
        extendedAddr2,
        city,
        state,
        zip,
        country,
      ];
}

/// Complete a Google signup: Google ID token + verified phone [signupToken].
class GoogleSignupRequested extends AuthenticationEvent {
  final String signupToken;
  final String address;
  final String extendedAddr;
  final String extendedAddr2;
  final String city;
  final String state;
  final String zip;
  final String country;

  const GoogleSignupRequested({
    required this.signupToken,
    required this.address,
    required this.extendedAddr,
    required this.extendedAddr2,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  @override
  List<Object> get props => [
        signupToken,
        address,
        extendedAddr,
        extendedAddr2,
        city,
        state,
        zip,
        country,
      ];
}
// ============================================================
// FIX: FLAG-004 — Phone OTP Login Event (backend OTP flow)
// ============================================================

/// Phone OTP login: verify OTP and login via backend.
/// BR-011: If user exists, login. If not, route to signup.
class PhoneOtpLogin extends AuthenticationEvent {
  final String phone;
  final String otp;

  const PhoneOtpLogin({required this.phone, required this.otp});

  @override
  List<Object> get props => [phone, otp];
}
