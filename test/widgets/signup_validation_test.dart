import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/widgets/AppTextField.dart';

/// Widget Tests for AppTextField and validation helpers
/// 
/// TC-AUTH-001: Email validation
/// TC-AUTH-002: Password validation
/// TC-AUTH-003: Phone validation
/// TC-AUTH-004: Form field validation

void main() {
  group('AppTextField Widget Tests', () {

    testWidgets('AppTextField renders correctly with label',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Test Label',
              hint: 'Test Hint',
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.text('Test Hint'), findsOneWidget);
    });

    testWidgets('AppTextField with prefix icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Email',
              prefixIcon: Icons.email_outlined,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
    });

    testWidgets('AppTextField with validator shows error',
        (WidgetTester tester) async {
      final formKey = GlobalKey<FormState>();
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              key: formKey,
              child: AppTextField(
                label: 'Email',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Field is required';
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Try to validate empty field
      formKey.currentState!.validate();
      await tester.pumpAndSettle();

      expect(find.text('Field is required'), findsOneWidget);
    });
  });

  group('Validation Helper Tests', () {

    // ============================================================
    // TC-AUTH-001: Email validation
    // ============================================================
    group('Email Validation', () {
      test('valid email addresses', () {
        expect(isValidEmail('test@example.com'), isTrue);
        expect(isValidEmail('user.name@domain.co.uk'), isTrue);
        expect(isValidEmail('test123@test.org'), isTrue);
      });

      test('invalid email addresses', () {
        expect(isValidEmail(''), isFalse);
        expect(isValidEmail('invalid'), isFalse);
        expect(isValidEmail('invalid@'), isFalse);
        expect(isValidEmail('@invalid.com'), isFalse);
        expect(isValidEmail('invalid@.com'), isFalse);
      });
    });

    // ============================================================
    // TC-AUTH-002: Password validation
    // ============================================================
    group('Password Validation', () {
      test('valid passwords', () {
        expect(isValidPassword('SecurePass123!'), isTrue);
        expect(isValidPassword('Test@1234'), isTrue);
        expect(isValidPassword('MyP@ssw0rd'), isTrue);
      });

      test('invalid passwords - too short', () {
        expect(isValidPassword('Ab1!'), isFalse);
        expect(isValidPassword('Short1!'), isFalse);
      });

      test('invalid passwords - missing uppercase', () {
        expect(isValidPassword('lowercase123!'), isFalse);
      });

      test('invalid passwords - missing lowercase', () {
        expect(isValidPassword('UPPERCASE123!'), isFalse);
      });

      test('invalid passwords - missing number', () {
        expect(isValidPassword('NoNumbers!@#'), isFalse);
      });

      test('invalid passwords - missing special character', () {
        expect(isValidPassword('NoSpecial123'), isFalse);
      });
    });

    // ============================================================
    // TC-AUTH-003: Phone validation
    // ============================================================
    group('Phone Validation', () {
      test('valid Indian phone numbers', () {
        expect(isValidPhone('9876543210'), isTrue);
        expect(isValidPhone('8765432109'), isTrue);
        expect(isValidPhone('7654321098'), isTrue);
        expect(isValidPhone('6543210987'), isTrue);
      });

      test('invalid phone numbers - wrong length', () {
        expect(isValidPhone('12345'), isFalse);
        expect(isValidPhone('123456789'), isFalse);
        expect(isValidPhone('12345678901'), isFalse);
      });

      test('invalid phone numbers - wrong starting digit', () {
        expect(isValidPhone('1234567890'), isFalse);
        expect(isValidPhone('2345678901'), isFalse);
        expect(isValidPhone('3456789012'), isFalse);
        expect(isValidPhone('4567890123'), isFalse);
        expect(isValidPhone('5678901234'), isFalse);
      });

      test('invalid phone numbers - non-numeric', () {
        expect(isValidPhone('abcdefghij'), isFalse);
        expect(isValidPhone('987654321a'), isFalse);
      });
    });

    // ============================================================
    // TC-AUTH-004: ZIP code validation
    // ============================================================
    group('ZIP Code Validation', () {
      test('valid Indian PIN codes', () {
        expect(isValidZipCode('400001'), isTrue);
        expect(isValidZipCode('560001'), isTrue);
        expect(isValidZipCode('110001'), isTrue);
      });

      test('invalid PIN codes', () {
        expect(isValidZipCode(''), isFalse);
        expect(isValidZipCode('12345'), isFalse);
        expect(isValidZipCode('1234567'), isFalse);
        expect(isValidZipCode('abcdef'), isFalse);
      });
    });

    // ============================================================
    // TC-AUTH-005: Country code validation
    // ============================================================
    group('Country Code Validation', () {
      test('valid country codes', () {
        expect(isValidCountryCode('IN'), isTrue);
        expect(isValidCountryCode('US'), isTrue);
        expect(isValidCountryCode('GB'), isTrue);
      });

      test('invalid country codes', () {
        expect(isValidCountryCode(''), isFalse);
        expect(isValidCountryCode('I'), isFalse);
        expect(isValidCountryCode('IND'), isFalse);
        expect(isValidCountryCode('in'), isFalse);
        expect(isValidCountryCode('12'), isFalse);
      });
    });
  });
}
