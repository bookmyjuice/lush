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

/// Widget Tests for SignUpScreen
///
/// TC-AUTH-002: Email validation
/// TC-AUTH-003: Password validation
/// TC-AUTH-004: Phone validation
/// TC-AUTH-005: Form submission

/// Wraps the SignUpScreen with required providers using a mocked bloc.
Widget buildTestApp(User user, {Map<String, WidgetBuilder>? routes}) {
  final mockAuthBloc = MockAuthenticationBloc();
  final streamController = StreamController<AuthenticationState>.broadcast();

  when(mockAuthBloc.state).thenReturn(SignUpStarted(user: user));
  when(mockAuthBloc.stream).thenAnswer((_) => streamController.stream);
  when(mockAuthBloc.close()).thenAnswer((_) async {
    await streamController.close();
  });
  when(mockAuthBloc.isClosed).thenAnswer((_) => false);

  addTearDown(() {
    streamController.close();
  });

  return ToastificationWrapper(
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>.value(value: mockAuthBloc),
        BlocProvider<ThemeCubit>(
          create: (_) => ThemeCubit(),
        ),
      ],
      child: MaterialApp(
        home: SignUpScreen(user: user),
        routes: routes ?? {},
      ),
    ),
  );
}

/// Tap a button by its text, scrolling into view first if needed.
Future<void> tapButton(WidgetTester tester, String label) async {
  final finder = find.widgetWithText(ElevatedButton, label);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('SignUpScreen Widget Tests', () {
    setUpAll(registerRepositories);

    // Helper to create a dummy User object for testing
    User createTestUser({
      String email = '',
      String firstName = '',
      String lastName = '',
      String phone = '',
    }) {
      return User(
        id: 'test-id',
        email: email,
        phone: phone,
        role: 'user',
        firstName: firstName,
        lastName: lastName,
        password: '',
        address: '',
        city: '',
        country: '',
        extendedAddr: '',
        extendedAddr2: '',
        state: '',
        zip: '',
      );
    }

    // ============================================================
    // TC-AUTH-002: Email validation
    // ============================================================
    testWidgets('TC-AUTH-002: Email field validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();

      // Test empty email
      await tester.enterText(find.byType(TextFormField).at(0), '');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Email is required'), findsOneWidget);

      // Test invalid email format
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Enter a valid email'), findsOneWidget);

      // Test valid email
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Enter a valid email'), findsNothing);
      // Drain Toastification auto-dismiss timer
      await tester.pump(const Duration(seconds: 4));
    });

    // ============================================================
    // TC-AUTH-003: Password validation
    // ============================================================
    testWidgets('TC-AUTH-003: Password field validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();

      // Test empty password
      await tester.enterText(find.byType(TextFormField).at(4), '');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Password is required'), findsOneWidget);

      // Test weak password (too short)
      await tester.enterText(find.byType(TextFormField).at(4), 'weak');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Password does not meet requirements'), findsOneWidget);

      // Test password without special character
      await tester.enterText(find.byType(TextFormField).at(4), 'NoSpecial123');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Password does not meet requirements'), findsOneWidget);

      // Test strong password
      await tester.enterText(
          find.byType(TextFormField).at(4), 'SecurePass123!');
      await tester.pumpAndSettle();

      // Verify password requirements are met (green checkmarks)
      expect(find.byIcon(Icons.check_circle), findsWidgets);
      // Drain Toastification auto-dismiss timer
      await tester.pump(const Duration(seconds: 4));
    });

    // ============================================================
    // TC-AUTH-004: Phone validation
    // ============================================================
    testWidgets('TC-AUTH-004: Phone field validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();

      // Test empty phone
      await tester.enterText(find.byType(TextFormField).at(3), '');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Phone number is required'), findsOneWidget);

      // Test invalid phone (less than 10 digits)
      await tester.enterText(find.byType(TextFormField).at(3), '12345');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Enter a valid 10-digit number'), findsOneWidget);

      // Test invalid phone (starts with wrong digit)
      await tester.enterText(find.byType(TextFormField).at(3), '1234567890');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Enter a valid 10-digit number'), findsOneWidget);

      // Test valid phone
      await tester.enterText(find.byType(TextFormField).at(3), '9876543210');
      await tester.pumpAndSettle();
      await tapButton(tester, 'Create Account');
      expect(find.text('Phone number is required'), findsNothing);
      expect(find.text('Enter a valid 10-digit number'), findsNothing);
      // Drain Toastification auto-dismiss timer
      await tester.pump(const Duration(seconds: 4));
    });

    // ============================================================
    // TC-AUTH-005: Form submission validation
    // ============================================================
    testWidgets('TC-AUTH-005: Form submission with incomplete data',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();

      // Try to submit without filling any fields
      await tapButton(tester, 'Create Account');

      // Verify validation errors are shown
      expect(find.text('Email is required'), findsOneWidget);
      expect(find.text('First name is required'), findsOneWidget);
      expect(find.text('Last name is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
      expect(find.text('Password is required'), findsOneWidget);
      // Drain Toastification auto-dismiss timer
      await tester.pump(const Duration(seconds: 4));
    });

    // ============================================================
    // Additional Tests
    // ============================================================
    testWidgets('Password visibility toggle works',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();

      // Password should be obscured initially
      expect(find.byIcon(Icons.visibility_off_outlined), findsWidgets);

      // Scroll down to make the first password visibility toggle visible
      // The password fields are deep in the scroll view
      final passwordSectionTitle = find.text('Password');
      await tester.ensureVisible(passwordSectionTitle.first);
      await tester.pumpAndSettle();

      // Tap the visibility toggle for the password field
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pumpAndSettle();

      // After toggling, visibility_outlined icon should appear
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('Password requirements update in real-time',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();

      // Initially all requirements should be unmet (circle_outlined icons)
      expect(find.byIcon(Icons.check_circle), findsNothing);

      // Enter a strong password
      await tester.enterText(
        find.byType(TextFormField).at(4),
        'SecurePass123!',
      );
      await tester.pumpAndSettle();

      // All 5 requirements should be met
      expect(find.byIcon(Icons.check_circle), findsNWidgets(5));
    });

    testWidgets('Password mismatch validation',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();

      // Enter different passwords
      await tester.enterText(
        find.byType(TextFormField).at(4),
        'SecurePass123!',
      );
      await tester.enterText(
        find.byType(TextFormField).at(5),
        'DifferentPass456!',
      );
      await tester.pumpAndSettle();

      // Try to submit
      await tapButton(tester, 'Create Account');

      // Verify mismatch error (the form validator fires the password mismatch)
      expect(find.text('Passwords do not match'), findsOneWidget);
      // Drain Toastification auto-dismiss timer
      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets('Navigate to login screen',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(
        createTestUser(),
        routes: {
          '/login': (context) => const Scaffold(body: Text('Login Screen')),
        },
      ));
      await tester.pumpAndSettle();

      // Scroll to make the login TextButton visible
      final loginButton = find.widgetWithText(TextButton, 'Login');
      await tester.ensureVisible(loginButton);
      await tester.pumpAndSettle();

      // Tap the login TextButton
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Verify navigation happened
      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('All required fields are present',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();

      // Verify all required fields exist
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('First Name'), findsOneWidget);
      expect(find.text('Last Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);

      // "Password" text appears twice: once as a section divider title,
      // once as the password field label
      expect(find.text('Password'), findsNWidgets(2));

      expect(find.text('Confirm Password'), findsOneWidget);

      // "Create Account" text appears twice: once in the AppBar title,
      // once as the submit button text
      expect(find.text('Create Account'), findsNWidgets(2));
    });

    testWidgets('AppTextField widgets are used',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestApp(createTestUser()));
      await tester.pumpAndSettle();

      // Verify TextFormField widgets exist (6 form fields)
      expect(find.byType(TextFormField), findsNWidgets(6));
    });
  });
}
