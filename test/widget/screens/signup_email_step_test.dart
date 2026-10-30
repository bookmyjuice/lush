/// Widget tests for the mandatory-email signup step.
///
/// Covers [SignupEmailVerificationScreen] (email -> code -> proof) and the
/// optional-address contract on [AddressEntryScreen] ("Skip for now").
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/get_it.dart';
import 'package:lush/views/screens/address_entry_screen.dart';
import 'package:lush/views/screens/signup_email_verification_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:toastification/toastification.dart';

class _MockUserRepository extends Mock implements UserRepository {}

void main() {
  late _MockUserRepository repo;

  setUp(() {
    repo = _MockUserRepository();
    if (getIt.isRegistered<UserRepository>()) {
      getIt.unregister<UserRepository>();
    }
    getIt.registerSingleton<UserRepository>(repo);
  });

  tearDown(() {
    if (getIt.isRegistered<UserRepository>()) {
      getIt.unregister<UserRepository>();
    }
  });

  Widget buildEmailApp(
    Map<String, dynamic> args,
    List<Map<String, dynamic>> captured,
  ) {
    return ToastificationWrapper(
      child: MaterialApp(
        onGenerateRoute: (settings) {
          if (settings.name == '/address-entry') {
            captured.add(settings.arguments as Map<String, dynamic>);
            return MaterialPageRoute(
              builder: (_) => const Scaffold(body: Text('ADDRESS_STEP')),
            );
          }
          return MaterialPageRoute(
            settings: RouteSettings(name: settings.name, arguments: args),
            builder: (_) => const SignupEmailVerificationScreen(),
          );
        },
        initialRoute: '/signup-email-verification',
      ),
    );
  }

  group('SignupEmailVerificationScreen', () {
    testWidgets('requires a valid email before sending a code', (tester) async {
      await tester.pumpWidget(buildEmailApp(<String, dynamic>{
        'phone': '9999999933',
        'signupToken': 'phone-token',
      }, <Map<String, dynamic>>[]));

      await tester.tap(find.byKey(const Key('send_email_code_button')));
      await tester.pump();
      expect(find.text('Email is required'), findsOneWidget);

      await tester.enterText(
          find.byKey(const Key('signup_email_field')), 'not-an-email');
      await tester.tap(find.byKey(const Key('send_email_code_button')));
      await tester.pump();
      expect(find.text('Enter a valid email address'), findsOneWidget);

      verifyNever(() => repo.sendEmailVerification(any()));
    });

    testWidgets('sends a code, then hands the email proof to the address step',
        (tester) async {
      when(() => repo.sendEmailVerification('asha@example.com')).thenAnswer(
          (_) async => 'Success: Verification code sent to asha@example.com');
      when(() => repo.verifyEmailCode('asha@example.com', '123456'))
          .thenAnswer((_) async => <String, dynamic>{
                'status': 'success',
                'email': 'asha@example.com',
                'emailVerificationToken': 'email-proof-token',
              });

      final captured = <Map<String, dynamic>>[];
      await tester.pumpWidget(buildEmailApp(<String, dynamic>{
        'phone': '9999999933',
        'signupToken': 'phone-token',
      }, captured));

      await tester.enterText(
          find.byKey(const Key('signup_email_field')), 'asha@example.com');
      await tester.tap(find.byKey(const Key('send_email_code_button')));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('signup_email_code_field')), findsOneWidget);
      verify(() => repo.sendEmailVerification('asha@example.com')).called(1);

      await tester.enterText(
          find.byKey(const Key('signup_email_code_field')), '123456');
      await tester.tap(find.byKey(const Key('verify_email_code_button')));
      await tester.pump();
      await tester.pump();

      expect(captured, hasLength(1));
      expect(captured.single['email'], 'asha@example.com');
      expect(captured.single['emailVerificationToken'], 'email-proof-token');
      expect(captured.single['signupToken'], 'phone-token');
      expect(captured.single['isGoogleSignup'], isFalse);
    });

    testWidgets('stays on the email step when the backend refuses',
        (tester) async {
      when(() => repo.sendEmailVerification(any()))
          .thenAnswer((_) async => 'Error: Email is already registered!');

      await tester.pumpWidget(buildEmailApp(<String, dynamic>{
        'phone': '9999999933',
        'signupToken': 'phone-token',
      }, <Map<String, dynamic>>[]));

      await tester.enterText(
          find.byKey(const Key('signup_email_field')), 'taken@example.com');
      await tester.tap(find.byKey(const Key('send_email_code_button')));
      await tester.pump();
      await tester.pump();

      expect(find.byKey(const Key('signup_email_code_field')), findsNothing);
      expect(find.byKey(const Key('signup_email_field')), findsOneWidget);
    });
  });

  group('AddressEntryScreen (optional address)', () {
    Widget buildAddressApp({
      required _MockUserRepository repository,
      required Map<String, dynamic> args,
    }) {
      final bloc = AuthenticationBloc(repo: repository);
      addTearDown(bloc.close);
      return ToastificationWrapper(
        child: BlocProvider<AuthenticationBloc>.value(
          value: bloc,
          child: MaterialApp(
            onGenerateRoute: (settings) => MaterialPageRoute(
              settings: RouteSettings(name: settings.name, arguments: args),
              builder: (_) => const AddressEntryScreen(),
            ),
            initialRoute: '/address-entry',
          ),
        ),
      );
    }

    testWidgets('shows a verified, read-only email and a skip action',
        (tester) async {
      await tester.pumpWidget(buildAddressApp(
        repository: repo,
        args: <String, dynamic>{
          'signupToken': 'phone-token',
          'email': 'asha@example.com',
          'emailVerificationToken': 'email-proof-token',
        },
      ));
      await tester.pump();

      final emailField = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('address_email_field')),
          matching: find.byType(EditableText),
        ),
      );
      expect(emailField.readOnly, isTrue);
      expect(find.text('Delivery address (optional)'), findsOneWidget);
      expect(find.byKey(const Key('address_skip_now_button')), findsOneWidget);
    });

    testWidgets('name is mandatory even when the address is skipped',
        (tester) async {
      await tester.pumpWidget(buildAddressApp(
        repository: repo,
        args: <String, dynamic>{
          'signupToken': 'phone-token',
          'email': 'asha@example.com',
          'emailVerificationToken': 'email-proof-token',
        },
      ));
      await tester.pump();

      await tester.ensureVisible(find.byKey(const Key('address_skip_now_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('address_skip_now_button')));
      await tester.pump();

      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      verifyNever(
        () => repo.completePhoneSignup(
          signupToken: 'phone-token',
          firstName: 'Asha',
          lastName: 'Rao',
          email: 'asha@example.com',
          emailVerificationToken: 'email-proof-token',
        ),
      );
    });

    testWidgets('skip sends blank address fields with the email proof',
        (tester) async {
      when(() => repo.completePhoneSignup(
            signupToken: 'phone-token',
            firstName: 'Asha',
            lastName: 'Rao',
            email: 'asha@example.com',
            emailVerificationToken: 'email-proof-token',
            address: '',
            extendedAddr: '',
            extendedAddr2: '',
            city: '',
            state: '',
            zip: '',
            country: 'IN',
          )).thenAnswer((_) async => <String, dynamic>{'error': 'offline'});

      await tester.pumpWidget(buildAddressApp(
        repository: repo,
        args: <String, dynamic>{
          'signupToken': 'phone-token',
          'email': 'asha@example.com',
          'emailVerificationToken': 'email-proof-token',
        },
      ));
      await tester.pump();

      await tester.enterText(
          find.byKey(const Key('address_first_name_field')), 'Asha');
      await tester.enterText(
          find.byKey(const Key('address_last_name_field')), 'Rao');
      // Half-typed address: it must not block the skip.
      await tester.enterText(
          find.byKey(const Key('address_line1_field')), 'Flat 101');
      await tester.ensureVisible(find.byKey(const Key('address_skip_now_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('address_skip_now_button')));
      await tester.pump();
      await tester.pump();

      verify(() => repo.completePhoneSignup(
            signupToken: 'phone-token',
            firstName: 'Asha',
            lastName: 'Rao',
            email: 'asha@example.com',
            emailVerificationToken: 'email-proof-token',
            address: '',
            extendedAddr: '',
            extendedAddr2: '',
            city: '',
            state: '',
            zip: '',
            country: 'IN',
          )).called(1);
    });
  });
}
