/// Widget tests for [LoginPage] after the password UI removal.
///
/// The page is now a two-provider surface: Google Sign-In and Phone OTP.
/// There is no email field, no password field and no forgot-password link.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/get_it.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/screens/login_page.dart';
import 'package:mockito/mockito.dart';
import 'package:toastification/toastification.dart';
import '../../mocks.mocks.dart';

Widget buildTestApp({
  Map<String, WidgetBuilder>? routes,
  String toastMessage = '',
  String toastHeading = '',
}) {
  final mockAuthBloc = MockAuthenticationBloc();
  final streamController = StreamController<AuthenticationState>.broadcast();

  when(mockAuthBloc.state).thenReturn(AuthenticationInProgress());
  when(mockAuthBloc.stream).thenAnswer((_) => streamController.stream);
  when(mockAuthBloc.close()).thenAnswer((_) async {
    await streamController.close();
  });
  when(mockAuthBloc.isClosed).thenAnswer((_) => false);

  addTearDown(streamController.close);

  return ToastificationWrapper(
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
      ],
      child: MaterialApp(
        home: LoginPage(
          toastMessage: toastMessage,
          toastHeading: toastHeading,
        ),
        routes: routes ?? <String, WidgetBuilder>{},
      ),
    ),
  );
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(registerRepositories);

  group('LoginPage structure', () {
    testWidgets('renders the brand surface and both providers', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Fresh Juices, Delivered Daily'), findsOneWidget);
      expect(find.byKey(const Key('login_google_button')), findsOneWidget);
      expect(find.byKey(const Key('login_phone_button')), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue with Phone'), findsOneWidget);
    });

    testWidgets('has no password or email field', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('login_password_field')), findsNothing);
      expect(find.byKey(const Key('login_email_field')), findsNothing);
      expect(find.text('Forgot Password?'), findsNothing);
      expect(find.byType(TextFormField), findsNothing);
    });

    testWidgets('tabs still switch between Sign In and Sign Up', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back!'), findsOneWidget);

      await tapVisible(tester, find.text('Sign Up').last);
      expect(find.text('Create Your Account'), findsOneWidget);
      expect(find.text('Welcome Back!'), findsNothing);

      await tapVisible(tester, find.text('Sign In').last);
      expect(find.text('Welcome Back!'), findsOneWidget);
    });
  });

  group('LoginPage navigation', () {
    testWidgets('phone CTA opens /phone-entry', (tester) async {
      await tester.pumpWidget(buildTestApp(routes: {
        '/phone-entry': (_) => const Scaffold(body: Text('PHONE_ENTRY')),
      }),);
      await tester.pumpAndSettle();

      await tapVisible(tester, find.byKey(const Key('login_phone_button')));

      expect(find.text('PHONE_ENTRY'), findsOneWidget);
    });

    testWidgets('sign-up phone card opens /phone-entry', (tester) async {
      await tester.pumpWidget(buildTestApp(routes: {
        '/phone-entry': (_) => const Scaffold(body: Text('PHONE_ENTRY')),
      }),);
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('Sign Up').last);
      await tapVisible(tester, find.text('Sign up with Phone'));

      expect(find.text('PHONE_ENTRY'), findsOneWidget);
    });

    testWidgets('sign-up tab shows only Phone and Google cards', (tester) async {
      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      await tapVisible(tester, find.text('Sign Up').last);

      expect(find.text('Sign up with Phone'), findsOneWidget);
      expect(find.text('Sign up with Google'), findsOneWidget);
      expect(find.text('Sign up with Email'), findsNothing);
    });
  });

  group('Toast messages', () {
    testWidgets('renders with an initial toast message', (tester) async {
      await tester.pumpWidget(buildTestApp(
        toastHeading: 'Test Heading',
        toastMessage: 'Test Message',
      ),);
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Fresh Juices, Delivered Daily'), findsOneWidget);
    });
  });
}
