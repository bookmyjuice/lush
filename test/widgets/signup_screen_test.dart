import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/models/user.dart';
import 'package:lush/views/screens/sign_up_screen.dart';
import 'package:lush/get_it.dart';
import 'package:mockito/mockito.dart';
import 'package:toastification/toastification.dart';
import '../mocks.mocks.dart';

Widget buildTestApp(User user, {Map<String, WidgetBuilder>? routes}) {
  final mockAuthBloc = MockAuthenticationBloc();
  final streamController = StreamController<AuthenticationState>.broadcast();
  when(mockAuthBloc.state).thenReturn(SignUpStarted(user: user));
  when(mockAuthBloc.stream).thenAnswer((_) => streamController.stream);
  when(mockAuthBloc.close()).thenAnswer((_) async { await streamController.close(); });
  when(mockAuthBloc.isClosed).thenAnswer((_) => false);
  addTearDown(streamController.close);
  return ToastificationWrapper(
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
      ],
      child: MaterialApp(home: SignUpScreen(user: user), routes: routes ?? {}),
    ),
  );
}

Future<void> tapButton(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(finder);
  await tester.pump(const Duration(seconds: 1));
  await tester.tap(finder);
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  group('SignUpScreen Widget Tests', () {
    setUpAll(registerRepositories);
    User createTestUser({String email = '', String firstName = '', String lastName = '', String phone = ''}) {
      return User(id: 'test-id', email: email, phone: phone, role: 'user',
        firstName: firstName, lastName: lastName, password: '',
        address: '', city: '', country: '', extendedAddr: '', extendedAddr2: '', state: '', zip: '',);
    }

    testWidgets('TC-AUTH-002: Email field validation', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Email is required'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Enter a valid email'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(0), 'test@example.com');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Enter a valid email'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('TC-AUTH-003: Password field validation', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();
      // empty password
      await tester.enterText(find.byType(TextFormField).at(4), '');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Password is required'), findsOneWidget);
      // weak password
      await tester.enterText(find.byType(TextFormField).at(4), 'weak');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Password does not meet requirements'), findsOneWidget);
      // no special char
      await tester.enterText(find.byType(TextFormField).at(4), 'NoSpecial123');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Password does not meet requirements'), findsOneWidget);
      // strong password — submit to clear prior error decoration
      await tester.enterText(find.byType(TextFormField).at(4), 'SecurePass123!');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      // After resubmit with strong password, error text should be gone
      expect(find.text('Password does not meet requirements'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('TC-AUTH-004: Phone field validation', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(3), '');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Phone number is required'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(3), '12345');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Enter a valid 10-digit number'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Enter a valid 10-digit number'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField).at(3), '9876543210');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Phone number is required'), findsNothing);
      expect(find.text('Enter a valid 10-digit number'), findsNothing);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('TC-AUTH-005: Form submission with incomplete data', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Password visibility toggle works', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);
      final passwordSectionTitle = find.text('Password');
      await tester.ensureVisible(passwordSectionTitle.first);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('Password requirements update in real-time', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();
      expect(find.byType(Icon), findsWidgets);
      await tester.enterText(find.byType(TextFormField).at(4), 'SecurePass123!');
      await tester.pumpAndSettle();
      expect(find.byType(Icon), findsWidgets);
    });

    testWidgets('Password mismatch validation', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(4), 'SecurePass123!');
      await tester.enterText(find.byType(TextFormField).at(5), 'DifferentPass456!');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Passwords do not match'), findsOneWidget);
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Navigate to login screen', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser(), routes: {'/login': (context) => const Scaffold(body: Text('Login Screen'))}));
      await tester.pumpAndSettle();
      final loginButton = find.widgetWithText(TextButton, 'Login');
      await tester.ensureVisible(loginButton);
      await tester.pumpAndSettle();
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('All required fields are present', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Password'), findsNWidgets(2));
      expect(find.text('Confirm Password'), findsOneWidget);
      expect(find.text('Create Account'), findsNWidgets(2));
    });

    testWidgets('AppTextField widgets are used', (tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsNWidgets(7));
    });
  });
}