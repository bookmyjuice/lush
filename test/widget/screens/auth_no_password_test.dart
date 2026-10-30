/// Guardrail for the auth simplification wave (A0-G2).
///
/// Static file scan, not a widget test: it fails when email/password auth, a
/// password field, or the Firebase phone-auth path is reintroduced anywhere in
/// the shipped UI.
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Screens retired by `AUTH_SIMPLIFICATION_PLAN.md` §4 / §5.
const List<String> retiredScreens = <String>[
  'sign_up_screen.dart',
  'signup_method_selection_screen.dart',
  'email_signup_screen.dart',
  'email_verification_screen.dart',
  'phone_entry_after_email_screen.dart',
  'email_entry_after_phone_screen.dart',
  'email_verification_after_phone_screen.dart',
  'create_password_screen.dart',
  'forgot_password_page.dart',
  'forgot_password_screen.dart',
  'reset_password_mobile_screen.dart',
  'reset_password_email_screen.dart',
  'phone_login_screen.dart',
  'phone_signup_screen.dart',
  'google_phone_entry_screen.dart',
  'otp_login_page.dart',
];

/// Tokens that only belong to a password UI.
const List<String> passwordUiMarkers = <String>[
  'obscureText',
  'obscurePassword',
  'passwordController',
  'confirmPassword',
  "'Password'",
  '"Password"',
  'Create Password',
  'Forgot Password',
  'Reset Password',
];

void main() {
  group('A0-G2 auth surface guardrail', () {
    test('retired auth screens are gone', () {
      final screens = Directory('lib/views/screens');
      expect(screens.existsSync(), isTrue,
          reason: 'run from the package root (x:\\BMJ\\lush)');

      for (final name in retiredScreens) {
        expect(File('${screens.path}/$name').existsSync(), isFalse,
            reason: '$name must stay deleted');
      }

      expect(File('lib/views/models/firebase_phone_auth.dart').existsSync(),
          isFalse,
          reason: 'Firebase phone auth is retired; use the backend OTP path');
    });

    test('no password UI remains in any screen', () {
      final offenders = <String>[];

      for (final entity in Directory('lib/views/screens').listSync()) {
        if (entity is! File || !entity.path.endsWith('.dart')) continue;
        final source = entity.readAsStringSync();
        for (final marker in passwordUiMarkers) {
          if (source.contains(marker)) {
            offenders.add('${entity.path} -> $marker');
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'password UI is not allowed:\n${offenders.join('\n')}');
    });

    test('Firebase phone auth is not imported anywhere', () {
      final offenders = <String>[];

      for (final dir in ['lib', 'test', 'integration_test']) {
        final root = Directory(dir);
        if (!root.existsSync()) continue;
        for (final entity in root.listSync(recursive: true)) {
          if (entity is! File || !entity.path.endsWith('.dart')) continue;
          final source = entity.readAsStringSync();
          if (source.contains('firebase_phone_auth.dart') &&
              !source.contains('A0-G2')) {
            offenders.add(entity.path);
          }
        }
      }

      expect(offenders, isEmpty,
          reason: 'Firebase OTP path is retired:\n${offenders.join('\n')}');
    });

    test('email + password signup has no live route', () {
      final main = File('lib/main.dart').readAsStringSync();
      for (final route in <String>[
        "'/email-signup'",
        "'/create-password'",
        "'/email-verification'",
        "'/signup-method-selection'",
        "'/forgot-password'",
      ]) {
        final asRedirect = RegExp(
          '$route:\\s*\\(_?\\)?\\s*=>\\s*_?redirectToLogin',
        ).hasMatch(main);
        expect(asRedirect || !main.contains('$route: (_) =>'),
            isTrue,
            reason: '$route must not open an email/password screen');
      }
    });
  });
}
