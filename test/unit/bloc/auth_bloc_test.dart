/// Unit tests for [AuthenticationBloc].
///
/// Covers all auth events: Login, AutoLogin, Logout, Signup flow,
/// Google Sign-In, OTP, Email Verification.
///
/// References test cases from docs/test-cases/TC_AUTH.md
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {}

/// Helper to create a test User
User createTestUser({
  String id = 'test-id',
  String email = 'test@example.com',
  String phone = '9876543210',
  String firstName = 'Test',
  String lastName = 'User',
  String password = 'SecurePass123!',
  String address = '123 Test St',
  String city = 'Mumbai',
  String state = 'Maharashtra',
  String zip = '400001',
  String country = 'IN',
}) {
  return User(
    id: id,
    email: email,
    phone: phone,
    role: 'user',
    firstName: firstName,
    lastName: lastName,
    password: password,
    address: address,
    city: city,
    country: country,
    extendedAddr: '',
    extendedAddr2: '',
    state: state,
    zip: zip,
  );
}

void main() {
  late MockUserRepository mockRepo;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRepo = MockUserRepository();
  });

  // ─── AutoLogIn ─────────────────────────────────────────────
  group('AutoLogIn', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'AutoLogIn success emits AuthenticationSuccess',
      build: () {
        when(() => mockRepo.isInternetAvailable()).thenAnswer((_) async => true);
        when(() => mockRepo.autoLogin()).thenAnswer((_) async => true);
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(AutoLogIn()),
      expect: () => [
        isA<AuthenticationInProgress>(),
        isA<AuthenticationSuccess>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'AutoLogIn failure emits AutoLoginFailed',
      build: () {
        when(() => mockRepo.isInternetAvailable()).thenAnswer((_) async => true);
        when(() => mockRepo.autoLogin()).thenAnswer((_) async => false);
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(AutoLogIn()),
      expect: () => [
        isA<AuthenticationInProgress>(),
        isA<AutoLoginFailed>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'AutoLogIn no internet emits InternetIssue',
      build: () {
        when(() => mockRepo.isInternetAvailable()).thenAnswer((_) async => false);
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(AutoLogIn()),
      expect: () => [
        isA<AuthenticationInProgress>(),
        isA<InternetIssue>(),
      ],
    );
  });

  // ─── LogIn ─────────────────────────────────────────────────
  group('LogIn', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'LogIn success emits AuthenticationSuccess',
      build: () {
        when(() => mockRepo.isInternetAvailable()).thenAnswer((_) async => true);
        when(() => mockRepo.login(any<String>(), any<String>(), any<bool>())).thenAnswer((_) async => true);
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(LogIn('test@example.com', 'SecurePass123!', false)),
      expect: () => [
        isA<AuthenticationInProgress>(),
        isA<AuthenticationSuccess>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'LogIn failure emits LogInFailed',
      build: () {
        when(() => mockRepo.isInternetAvailable()).thenAnswer((_) async => true);
        when(() => mockRepo.login(any<String>(), any<String>(), any<bool>())).thenAnswer((_) async => false);
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(LogIn('test@example.com', 'wrong', false)),
      expect: () => [
        isA<AuthenticationInProgress>(),
        isA<LogInFailed>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'LogIn no internet emits InternetIssue',
      build: () {
        when(() => mockRepo.isInternetAvailable()).thenAnswer((_) async => false);
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(LogIn('test@example.com', 'pwd', false)),
      expect: () => [
        isA<AuthenticationInProgress>(),
        isA<InternetIssue>(),
      ],
    );
  });

  // ─── LogOut ────────────────────────────────────────────────
  group('LogOut', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'LogOut emits AuthenticationInProgress then LoggedOut',
      build: () {
        when(() => mockRepo.logout()).thenAnswer((_) async => {});
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(LogOut()),
      expect: () => [
        isA<AuthenticationInProgress>(),
        isA<LoggedOut>(),
      ],
    );
  });

  // ─── ChooseSignupMethod ────────────────────────────────────
  group('ChooseSignupMethod', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'ChooseSignupMethod(phone) emits SignupMethodSelected with phone',
      build: () => AuthenticationBloc(repo: mockRepo),
      act: (bloc) => bloc.add(const ChooseSignupMethod(method: 'phone')),
      expect: () => [isA<SignupMethodSelected>()],
      verify: (bloc) {
        final state = bloc.state as SignupMethodSelected;
        expect(state.method, 'phone');
      },
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'ChooseSignupMethod(email) emits SignupMethodSelected with email',
      build: () => AuthenticationBloc(repo: mockRepo),
      act: (bloc) => bloc.add(const ChooseSignupMethod(method: 'email')),
      expect: () => [isA<SignupMethodSelected>()],
      verify: (bloc) {
        final state = bloc.state as SignupMethodSelected;
        expect(state.method, 'email');
      },
    );
  });

  // ─── EnterEmail ────────────────────────────────────────────
  group('EnterEmail', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'EnterEmail success emits EmailEntered then EmailVerificationCodeSent',
      build: () {
        when(() => mockRepo.sendEmailVerification(any<String>()))
            .thenAnswer((_) async => 'Success: Code sent');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const EnterEmail(email: 'test@example.com')),
      expect: () => [
        isA<EmailEntered>(),
        isA<EmailVerificationCodeSent>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'EnterEmail failure emits EmailEntered then EmailVerificationFailed',
      build: () {
        when(() => mockRepo.sendEmailVerification(any<String>()))
            .thenAnswer((_) async => 'Error: Already registered');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const EnterEmail(email: 'test@example.com')),
      expect: () => [
        isA<EmailEntered>(),
        isA<EmailVerificationFailed>(),
      ],
    );
  });

  // ─── VerifyEmail ───────────────────────────────────────────
  group('VerifyEmail', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'VerifyEmail success emits EmailVerified',
      build: () {
        when(() => mockRepo.sendEmailVerification(any<String>()))
            .thenAnswer((_) async => 'Success: Code sent');
        when(() => mockRepo.verifyEmailCode(any<String>(), any<String>()))
            .thenAnswer((_) async => 'Success: Email verified');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const EnterEmail(email: 'test@example.com'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const VerifyEmail(
          email: 'test@example.com',
          verificationCode: '123456',
        ));
      },
      expect: () => [
        isA<EmailEntered>(),
        isA<EmailVerificationCodeSent>(),
        isA<EmailVerified>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'VerifyEmail wrong code fails',
      build: () {
        when(() => mockRepo.sendEmailVerification(any<String>()))
            .thenAnswer((_) async => 'Success: Code sent');
        when(() => mockRepo.verifyEmailCode(any<String>(), any<String>()))
            .thenAnswer((_) async => 'Error: Invalid code');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const EnterEmail(email: 'test@example.com'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const VerifyEmail(
          email: 'test@example.com',
          verificationCode: 'wrongcode',
        ));
      },
      expect: () => [
        isA<EmailEntered>(),
        isA<EmailVerificationCodeSent>(),
        isA<EmailVerificationFailed>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'VerifyEmail with mismatched email fails immediately',
      build: () {
        when(() => mockRepo.sendEmailVerification(any<String>()))
            .thenAnswer((_) async => 'Error: Invalid email');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const EnterEmail(email: 'different@example.com'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const VerifyEmail(
          email: 'other@example.com',
          verificationCode: '123456',
        ));
      },
      expect: () => [
        isA<EmailEntered>(),
        isA<EmailVerificationFailed>(),
        isA<EmailVerificationFailed>(),
      ],
    );
  });

  // ─── SendOTP ───────────────────────────────────────────────
  group('SendOTP', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'SendOTP success emits PhoneEntered then OTPSent',
      build: () {
        when(() => mockRepo.sendOTP(any<String>())).thenAnswer((_) async => 'OTP_SENT');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const SendOTP(phoneNumber: '9876543210')),
      expect: () => [
        isA<PhoneEntered>(),
        isA<OTPSent>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'SendOTP failure emits PhoneEntered then OTPSendFailed',
      build: () {
        when(() => mockRepo.sendOTP(any<String>()))
            .thenAnswer((_) async => 'Error: Invalid phone number');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const SendOTP(phoneNumber: '12345')),
      expect: () => [
        isA<PhoneEntered>(),
        isA<OTPSendFailed>(),
      ],
    );
  });

  // ─── VerifyOTP ─────────────────────────────────────────────
  group('VerifyOTP', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'VerifyOTP success emits PhoneVerified + OTPVerificationSuccess',
      build: () {
        when(() => mockRepo.verifyOTP(any<String>()))
            .thenAnswer((_) async => 'OTP_VERIFIED');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const VerifyOTP(otp: '123456')),
      expect: () => [
        isA<PhoneVerified>(),
        isA<OTPVerificationSuccess>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'VerifyOTP failure emits OTPVerificationFailed',
      build: () {
        when(() => mockRepo.verifyOTP(any<String>()))
            .thenAnswer((_) async => 'Error: Invalid OTP');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const VerifyOTP(otp: 'wrong')),
      expect: () => [
        isA<OTPVerificationFailed>(),
      ],
    );
  });

  // ─── EnterAddress ──────────────────────────────────────────
  group('EnterAddress', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'EnterAddress emits AddressEntered then ReadyForFinalSignup',
      build: () => AuthenticationBloc(repo: mockRepo),
      act: (bloc) => bloc.add(const EnterAddress(
        firstName: 'Test',
        lastName: 'User',
        address: '123 Test St',
        extendedAddr: '',
        extendedAddr2: '',
        city: 'Mumbai',
        state: 'Maharashtra',
        zip: '400001',
        country: 'IN',
      )),
      expect: () => [
        isA<AddressEntered>(),
        isA<ReadyForFinalSignup>(),
      ],
      verify: (bloc) {
        final state = bloc.state as ReadyForFinalSignup;
        expect(state.city, 'Mumbai');
        expect(state.country, 'IN');
      },
    );
  });

  // ─── CompleteSignup ────────────────────────────────────────
  group('CompleteSignup', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'CompleteSignup with password mismatch emits SignUpFailed',
      build: () {
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const CompleteSignup(
        password: 'Pass123!',
        confirmPassword: 'Different456!',
      )),
      expect: () => [isA<SignUpFailed>()],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'CompleteSignup success emits AuthenticationSuccess when logged in',
      build: () {
        when(() => mockRepo.signUp()).thenAnswer((_) async => 'Success');
        when(() => mockRepo.userLoggedIn).thenReturn(true);
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const EnterAddress(
          firstName: 'Test',
          lastName: 'User',
          address: '123 Test St',
          extendedAddr: '',
          extendedAddr2: '',
          city: 'Mumbai',
          state: 'Maharashtra',
          zip: '400001',
          country: 'IN',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const CompleteSignup(
          password: 'SecurePass123!',
          confirmPassword: 'SecurePass123!',
        ));
      },
      expect: () => [
        isA<AddressEntered>(),
        isA<ReadyForFinalSignup>(),
        isA<AuthenticationInProgress>(),
        isA<AuthenticationSuccess>(),
      ],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'CompleteSignup failure emits SignUpFailed',
      build: () {
        when(() => mockRepo.signUp())
            .thenAnswer((_) async => 'Error: Email already exists');
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) async {
        bloc.add(const EnterAddress(
          firstName: 'Test',
          lastName: 'User',
          address: '123 Test St',
          extendedAddr: '',
          extendedAddr2: '',
          city: 'Mumbai',
          state: 'Maharashtra',
          zip: '400001',
          country: 'IN',
        ));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const CompleteSignup(
          password: 'SecurePass123!',
          confirmPassword: 'SecurePass123!',
        ));
      },
      expect: () => [
        isA<AddressEntered>(),
        isA<ReadyForFinalSignup>(),
        isA<AuthenticationInProgress>(),
        isA<SignUpFailed>(),
      ],
    );
  });

  // ─── GoogleSignIn ──────────────────────────────────────────
  group('GoogleSignIn', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'GoogleSignIn login_success emits AuthenticationSuccess',
      build: () {
        when(() => mockRepo.googleSignIn_()).thenAnswer((_) async => {
          'type': 'login_success',
          'token': 'mock-token',
        });
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<AuthenticationSuccess>()],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'GoogleSignIn link_required emits GoogleLinkRequired',
      build: () {
        when(() => mockRepo.googleSignIn_()).thenAnswer((_) async => {
          'type': 'link_required',
          'googleEmail': 'test@google.com',
          'googleFirstName': 'Test',
          'googleLastName': 'User',
          'googleId': 'google-123',
          'photoUrl': null,
        });
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<GoogleLinkRequired>()],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'GoogleSignIn signup_required emits SignUpStarted',
      build: () {
        when(() => mockRepo.googleSignIn_()).thenAnswer((_) async => {
          'type': 'signup_required',
          'user': createTestUser(),
        });
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<SignUpStarted>()],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'GoogleSignIn failure emits SignUpFailed',
      build: () {
        when(() => mockRepo.googleSignIn_())
            .thenAnswer((_) async => 'Google Sign-In cancelled');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<SignUpFailed>()],
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'GoogleSignIn null result emits SignUpFailed',
      build: () {
        when(() => mockRepo.googleSignIn_()).thenAnswer((_) async => null);
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<SignUpFailed>()],
    );
  });

  // ─── ResendOTP ─────────────────────────────────────────────
  group('ResendOTP', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'ResendOTP with phone set emits OTPSent',
      build: () {
        when(() => mockRepo.sendOTP(any<String>())).thenAnswer((_) async => 'OTP_SENT');
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) {
        bloc.add(const SendOTP(phoneNumber: '9876543210'));
        bloc.add(const ResendOTP());
      },
      expect: () => [
        isA<PhoneEntered>(),
        isA<OTPSent>(),
      ],
      verify: (bloc) {
        verify(() => mockRepo.sendOTP('9876543210')).called(2);
      },
      wait: const Duration(milliseconds: 100),
    );

    blocTest<AuthenticationBloc, AuthenticationState>(
      'ResendOTP with no phone set emits OTPSendFailed',
      build: () => AuthenticationBloc(repo: mockRepo),
      act: (bloc) => bloc.add(const ResendOTP()),
      expect: () => [isA<OTPSendFailed>()],
    );
  });

  // ─── MobileSignUp ──────────────────────────────────────────
  group('MobileSignUp', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'MobileSignUp sets phone and emits SignUpStarted',
      build: () {
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo);
      },
      act: (bloc) => bloc.add(const MobileSignUp(mobileNumber: '9876543210')),
      expect: () => [isA<SignUpStarted>()],
    );
  });
}
