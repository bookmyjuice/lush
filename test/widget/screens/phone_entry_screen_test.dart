/// Widget tests for [PhoneEntryScreen] - the single phone entry point.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/AuthBloc/auth_bloc.dart';
import 'package:lush/bloc/AuthBloc/auth_events.dart';
import 'package:lush/bloc/AuthBloc/auth_state.dart';
import 'package:lush/theme/theme_cubit.dart';
import 'package:lush/views/screens/phone_entry_screen.dart';
import 'package:mockito/mockito.dart';
import 'package:toastification/toastification.dart';
import '../../mocks.mocks.dart';

Widget buildTestApp(
  MockAuthenticationBloc bloc, {
  Map<String, WidgetBuilder>? routes,
}) {
  final controller = StreamController<AuthenticationState>.broadcast();
  when(bloc.state).thenReturn(AuthenticationInProgress());
  when(bloc.stream).thenAnswer((_) => controller.stream);
  when(bloc.close()).thenAnswer((_) async => controller.close());
  when(bloc.isClosed).thenAnswer((_) => false);
  addTearDown(controller.close);

  return ToastificationWrapper(
    child: MultiBlocProvider(
      providers: [
        BlocProvider<AuthenticationBloc>.value(value: bloc),
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
      ],
      child: MaterialApp(
        home: const PhoneEntryScreen(),
        routes: routes ?? <String, WidgetBuilder>{},
      ),
    ),
  );
}

void main() {
  testWidgets('requires a phone number', (tester) async {
    final bloc = MockAuthenticationBloc();
    await tester.pumpWidget(buildTestApp(bloc));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('phone_entry_send_otp')));
    await tester.pumpAndSettle();

    expect(find.text('Phone number is required'), findsOneWidget);
    verifyNever(bloc.add(any));
  });

  testWidgets('rejects a non-mobile number', (tester) async {
    final bloc = MockAuthenticationBloc();
    await tester.pumpWidget(buildTestApp(bloc));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('phone_entry_field')), '12345');
    await tester.tap(find.byKey(const Key('phone_entry_send_otp')));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid 10-digit Indian number'), findsOneWidget);
    verifyNever(bloc.add(any));
  });

  testWidgets('dispatches SendOTP for a valid number', (tester) async {
    final bloc = MockAuthenticationBloc();
    await tester.pumpWidget(buildTestApp(bloc));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('phone_entry_field')), '9876543210');
    await tester.tap(find.byKey(const Key('phone_entry_send_otp')));
    await tester.pump();

    verify(bloc.add(argThat(isA<SendOTP>()
        .having((e) => e.phoneNumber, 'phoneNumber', '9876543210')))).called(1);
  });

  testWidgets('offers no Firebase alternative', (tester) async {
    final bloc = MockAuthenticationBloc();
    await tester.pumpWidget(buildTestApp(bloc));
    await tester.pumpAndSettle();

    expect(find.textContaining('Firebase'), findsNothing);
    expect(find.textContaining('Verify via'), findsNothing);
  });
}
