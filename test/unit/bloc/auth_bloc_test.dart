/// Unit tests for [AuthenticationBloc].
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:lush/utils/analytics_service.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/CartRepository/cart_repository.dart';
import 'package:lush/views/models/cart_item.dart';
import 'package:lush/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockUserRepository extends Mock implements UserRepository {
  @override
  bool userLoggedIn = false;
}
class MockCartRepository extends Mock implements CartRepository {}
class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {}

User createTestUser({
  String id = 'test-id', String email = 'test@example.com', String phone = '9876543210',
  String firstName = 'Test', String lastName = 'User', String password = 'SecurePass123!',
  String address = '123 Test St', String city = 'Mumbai', String state = 'Maharashtra',
  String zip = '400001', String country = 'IN',
}) {
  return User(id: id, email: email, phone: phone, role: 'user',
    firstName: firstName, lastName: lastName, password: password,
    address: address, city: city, country: country,
    extendedAddr: '', extendedAddr2: '', state: state, zip: zip,);
}

void main() {
  late MockUserRepository mockRepo;
  late MockCartRepository mockCartRepo;
  late MockFirebaseAnalytics mockAnalytics;
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockRepo = MockUserRepository();
    mockCartRepo = MockCartRepository();
    mockAnalytics = MockFirebaseAnalytics();
    // Pre-register CartRepository in GetIt so _syncCartAfterAuth doesn't crash
    getIt.allowReassignment = true;
    if (!getIt.isRegistered<CartRepository>()) {
      getIt.registerLazySingleton<CartRepository>(() => mockCartRepo);
    }
    // Stub mergeGuestCartToBackend so _syncCartAfterAuth doesn't crash
    when(() => mockCartRepo.mergeGuestCartToBackend()).thenAnswer((_) async => []);
    // Stub syncWithBackend so _syncCartAfterAuth doesn't crash (needed for AutoLogIn, GoogleSignIn)
    when(() => mockCartRepo.syncWithBackend()).thenAnswer((_) async => <CartItem>[]);
    // Mock Firebase Analytics
    AnalyticsService.setAnalyticsForTesting(mockAnalytics);
  });

  group('AutoLogIn', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'AutoLogIn success emits AuthenticationSuccess',
      build: () {
        when(() => mockRepo.isInternetAvailable()).thenAnswer((_) async => true);
        when(() => mockRepo.autoLogin()).thenAnswer((_) async => true);
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(AutoLogIn()),
      expect: () => [isA<AuthenticationInProgress>(), isA<AuthenticationSuccess>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'AutoLogIn failure emits AutoLoginFailed',
      build: () {
        when(() => mockRepo.isInternetAvailable()).thenAnswer((_) async => true);
        when(() => mockRepo.autoLogin()).thenAnswer((_) async => false);
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(AutoLogIn()),
      expect: () => [isA<AuthenticationInProgress>(), isA<AutoLoginFailed>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'no internet emits AutoLoginFailed',
      build: () {
        when(() => mockRepo.isInternetAvailable()).thenAnswer((_) async => false);
        when(() => mockRepo.autoLogin()).thenAnswer((_) async => false);
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(AutoLogIn()),
      expect: () => [isA<AuthenticationInProgress>(), isA<AutoLoginFailed>()],
    );
  });

  // ─── LogIn ──────────────────────────
  group('LogIn', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'LogIn success emits AuthenticationSuccess',
      build: () {
        when(() => mockRepo.login(any<String>(), any<String>(), any<bool>())).thenAnswer((_) async => true);
        when(() => mockRepo.user).thenReturn(createTestUser());
        when(() => mockAnalytics.logLogin(loginMethod: any(named: 'loginMethod'))).thenAnswer((_) async => {});
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const LogIn('test@example.com', 'SecurePass123!', false)),
      expect: () => [isA<AuthenticationInProgress>(), isA<AuthenticationSuccess>()],
      verify: (_) { verify(() => mockRepo.login('test@example.com', 'SecurePass123!', false)).called(1); },
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'LogIn failure emits LogInFailed',
      build: () {
        when(() => mockRepo.login(any<String>(), any<String>(), any<bool>())).thenAnswer((_) async => false);
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const LogIn('test@example.com', 'wrong', false)),
      expect: () => [isA<AuthenticationInProgress>(), isA<LogInFailed>()],
    );
  });

  // ─── SendOTP ──────────────────────────
  group('SendOTP', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'SendOTP success emits OTPSent',
      build: () {
        when(() => mockRepo.sendOTP(any<String>())).thenAnswer((_) async => 'OTP_SENT');
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const SendOTP(phoneNumber: '9876543210')),
      expect: () => [isA<PhoneEntered>(), isA<OTPSent>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'SendOTP failure emits OTPSendFailed',
      build: () {
        when(() => mockRepo.sendOTP(any<String>())).thenAnswer((_) async => 'Error: Failed to send');
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const SendOTP(phoneNumber: '9876543210')),
      expect: () => [isA<PhoneEntered>(), isA<OTPSendFailed>()],
    );
  });

  // ─── VerifyOTP ──────────────────────────
  group('VerifyOTP', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'VerifyOTP success emits PhoneVerified and OTPVerificationSuccess',
      build: () {
        when(() => mockRepo.verifyOTP('123456')).thenAnswer((_) async => 'OTP_VERIFIED');
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const VerifyOTP(otp: '123456', phone: '9876543210')),
      expect: () => [isA<PhoneVerified>(), isA<OTPVerificationSuccess>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'VerifyOTP success emits PhoneVerified and OTPVerificationSuccess (signup flow)',
      build: () {
        when(() => mockRepo.verifyOTP('123456')).thenAnswer((_) async => 'OTP_VERIFIED');
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const VerifyOTP(otp: '123456', phone: '9876543210')),
      expect: () => [isA<PhoneVerified>(), isA<OTPVerificationSuccess>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'VerifyOTP failure emits OTPVerificationFailed',
      build: () {
        when(() => mockRepo.verifyOTP('123456')).thenAnswer((_) async => 'Error: Invalid OTP');
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const VerifyOTP(otp: '123456', phone: '9876543210')),
      expect: () => [isA<OTPVerificationFailed>()],
    );
  });

  // ─── CompleteSignup — EnterAddress emits ReadyForFinalSignup only ──────────────────────────
  group('CompleteSignup', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'CompleteSignup with password mismatch emits SignUpFailed',
      build: () {
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const CompleteSignup(password: 'Pass123!', confirmPassword: 'Different456!')),
      expect: () => [isA<SignUpFailed>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'CompleteSignup success emits SignUpSuccessful when userLoggedIn field is false',
      build: () {
        when(() => mockRepo.signUp()).thenAnswer((_) async => 'Success');
        when(() => mockRepo.user).thenReturn(createTestUser());
        mockRepo.userLoggedIn = false;
        when(() => mockAnalytics.logEvent(name: any(named: 'name'), parameters: any(named: 'parameters'))).thenAnswer((_) async => {});
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) async {
        bloc.add(const EnterAddress(firstName: 'Test', lastName: 'User', address: '123 Test St', extendedAddr: '', extendedAddr2: '', city: 'Mumbai', state: 'Maharashtra', zip: '400001', country: 'IN'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const CompleteSignup(password: 'SecurePass123!', confirmPassword: 'SecurePass123!'));
      },
      expect: () => [isA<ReadyForFinalSignup>(), isA<AuthenticationInProgress>(), isA<SignUpSuccessful>()],
      verify: (_) { verify(() => mockRepo.signUp()).called(1); },
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'CompleteSignup failure emits SignUpFailed',
      build: () {
        when(() => mockRepo.signUp()).thenAnswer((_) async => 'Error: Email already exists');
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) async {
        bloc.add(const EnterAddress(firstName: 'Test', lastName: 'User', address: '123 Test St', extendedAddr: '', extendedAddr2: '', city: 'Mumbai', state: 'Maharashtra', zip: '400001', country: 'IN'));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const CompleteSignup(password: 'SecurePass123!', confirmPassword: 'SecurePass123!'));
      },
      expect: () => [isA<ReadyForFinalSignup>(), isA<AuthenticationInProgress>(), isA<SignUpFailed>()],
    );
  });

  group('GoogleSignIn', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'login_success emits AuthenticationSuccess',
      build: () {
        when(() => mockRepo.googleSignIn()).thenAnswer((_) async => {'type':'login_success','token':'mock-token'});
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<AuthenticationSuccess>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'link_required emits GoogleLinkRequired',
      build: () {
        when(() => mockRepo.googleSignIn()).thenAnswer((_) async => {'type':'link_required','googleEmail':'test@google.com','googleFirstName':'Test','googleLastName':'User','googleId':'google-123','photoUrl':null});
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<GoogleLinkRequired>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'signup_required emits SignUpStarted',
      build: () {
        when(() => mockRepo.googleSignIn()).thenAnswer((_) async => {'type':'signup_required','user':createTestUser()});
        when(() => mockRepo.user).thenReturn(createTestUser());
        when(() => mockRepo.checkEmailExists(any<String>())).thenAnswer((_) async => false);
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<SignUpStarted>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'failure emits SignUpFailed',
      build: () {
        when(() => mockRepo.googleSignIn()).thenAnswer((_) async => 'Google Sign-In cancelled');
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<SignUpFailed>()],
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'null result emits AuthError',
      build: () {
        when(() => mockRepo.googleSignIn()).thenAnswer((_) async => null);
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const GoogleSignIn()),
      expect: () => [isA<AuthError>()],
    );
  });

  group('ResendOTP', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'with phone set emits OTPSent',
      build: () {
        when(() => mockRepo.sendOTP(any<String>())).thenAnswer((_) async => 'OTP_SENT');
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) { bloc.add(const SendOTP(phoneNumber: '9876543210')); bloc.add(const ResendOTP()); },
      expect: () => [isA<PhoneEntered>(), isA<OTPSent>()],
      verify: (bloc) { verify(() => mockRepo.sendOTP('9876543210')).called(2); },
      wait: const Duration(milliseconds: 100),
    );
    blocTest<AuthenticationBloc, AuthenticationState>(
      'no phone set emits OTPSendFailed',
      build: () => AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo),
      act: (bloc) => bloc.add(const ResendOTP()),
      expect: () => [isA<OTPSendFailed>()],
    );
  });

  group('MobileSignUp', () {
    blocTest<AuthenticationBloc, AuthenticationState>(
      'sets phone and emits SignUpStarted',
      build: () {
        when(() => mockRepo.user).thenReturn(createTestUser());
        return AuthenticationBloc(repo: mockRepo, cartRepo: mockCartRepo);
      },
      act: (bloc) => bloc.add(const MobileSignUp(mobileNumber: '9876543210')),
      expect: () => [isA<SignUpStarted>()],
    );
  });
}