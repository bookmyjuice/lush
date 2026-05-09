import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:lush/views/models/user.dart';

abstract class AuthenticationState extends Equatable {
  const AuthenticationState({Key? key});
  @override
  List<Object?> get props => [];
}

class AuthenticationInitiated extends AuthenticationState {
  final Key key;
  const AuthenticationInitiated(this.key);
  @override
  List<Object?> get props => [];
}

class AutoLoginFailed extends AuthenticationState {
  final String toast_message, toast_heading;

  const AutoLoginFailed({super.key, required this.toast_message, required this.toast_heading});
  @override
  List<Object?> get props => [toast_heading, toast_message];
}

class LogInFailed extends AuthenticationState {
  final String toast_message, toast_heading;

  const LogInFailed({super.key, required this.toast_message, required this.toast_heading});

  @override
  List<Object?> get props => [toast_heading, toast_message];
}

class AuthenticationSuccess extends AuthenticationState {
  final User user;
  const AuthenticationSuccess(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthenticationState {
  final String error;
  const AuthError({required this.error});
  @override
  List<Object> get props => [error];
}

class AuthenticationInProgress extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class InternetIssue extends AuthenticationState {
  final String toast_message, toast_heading;

  const InternetIssue({super.key, required this.toast_message, required this.toast_heading});
  @override
  List<Object?> get props => [toast_heading, toast_message];
}

class SignUpFailed extends AuthenticationState {
  final String error_heading, error;

  const SignUpFailed({super.key, required this.error_heading, required this.error});

  @override
  List<Object?> get props => [error_heading, error];
}

class SignUpStarted extends AuthenticationState {
  final User user;
  const SignUpStarted({required this.user});
  @override
  List<Object?> get props => [user];
}

class TokenReceived extends AuthenticationState {}

class SignUpSuccessful extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class LoggedOut extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class OTPSent extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class OTPVerificationSuccess extends AuthenticationState {
  @override
  List<Object?> get props => [];
}

class OTPVerificationFailed extends AuthenticationState {
  final String error;

  const OTPVerificationFailed({required this.error});

  @override
  List<Object?> get props => [error];
}

class OTPSendFailed extends AuthenticationState {
  final String error;

  const OTPSendFailed({required this.error});

  @override
  List<Object?> get props => [error];
}

// ============================================================
// NEW: Unified Signup Flow States
// ============================================================

// Step 1: Choose method
class SignupMethodSelected extends AuthenticationState {
  final String method; // 'email', 'phone', 'google'

  const SignupMethodSelected({required this.method});

  @override
  List<Object?> get props => [method];
}

// Step 2a: Email-first flow states
class EmailEntered extends AuthenticationState {
  final String email;

  const EmailEntered({required this.email});

  @override
  List<Object?> get props => [email];
}

class EmailVerificationSent extends AuthenticationState {
  final String email;

  const EmailVerificationSent({required this.email});

  @override
  List<Object?> get props => [email];
}

class EmailVerified extends AuthenticationState {
  final String email;

  const EmailVerified({required this.email});

  @override
  List<Object?> get props => [email];
}

// Step 2b: Phone-first flow states
class PhoneEntered extends AuthenticationState {
  final String phone;

  const PhoneEntered({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class PhoneVerified extends AuthenticationState {
  final String phone;

  const PhoneVerified({required this.phone});

  @override
  List<Object?> get props => [phone];
}

// Step 2c: Google signup state
class GoogleSignupEmailVerified extends AuthenticationState {
  final String email;
  final String firstName;
  final String lastName;

  const GoogleSignupEmailVerified({
    required this.email,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, firstName, lastName];
}

// #2 UX: Google account linking state (when no existing account found)
class GoogleLinkRequired extends AuthenticationState {
  final String googleEmail;
  final String googleFirstName;
  final String googleLastName;
  final String googleId;
  final String? photoUrl;

  const GoogleLinkRequired({
    required this.googleEmail,
    required this.googleFirstName,
    required this.googleLastName,
    required this.googleId,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [googleEmail, googleFirstName, googleLastName, googleId, photoUrl];
}

// Common state: Both email and phone verified
class EmailAndPhoneVerified extends AuthenticationState {
  final String email;
  final String phone;
  final String firstName;
  final String lastName;

  const EmailAndPhoneVerified({
    required this.email,
    required this.phone,
    required this.firstName,
    required this.lastName,
  });

  @override
  List<Object?> get props => [email, phone, firstName, lastName];
}

// Step 3: Address entry state
class AddressEntered extends AuthenticationState {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String address;
  final String extendedAddr;
  final String extendedAddr2;
  final String city;
  final String state;
  final String zip;
  final String country;

  const AddressEntered({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.address,
    required this.extendedAddr,
    required this.extendedAddr2,
    required this.city,
    required this.state,
    required this.zip,
    required this.country,
  });

  @override
  List<Object?> get props => [
        firstName,
        lastName,
        email,
        phone,
        address,
        extendedAddr,
        extendedAddr2,
        city,
        state,
        zip,
        country,
      ];
}

// Step 4: Ready for final signup (password entry)
class ReadyForFinalSignup extends AuthenticationState {
  final String email;
  final String phone;
  final String firstName;
  final String lastName;
  final String address;
  final String extendedAddr;
  final String extendedAddr2;
  final String city;
  final String state;
  final String zip;
  final String country;

  const ReadyForFinalSignup({
    required this.email,
    required this.phone,
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
  List<Object?> get props => [
        email,
        phone,
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

// Verification states
class EmailVerificationFailed extends AuthenticationState {
  final String error;

  const EmailVerificationFailed({required this.error});

  @override
  List<Object?> get props => [error];
}

class EmailVerificationCodeSent extends AuthenticationState {
  final String email;

  const EmailVerificationCodeSent({required this.email});

  @override
  List<Object?> get props => [email];
}
