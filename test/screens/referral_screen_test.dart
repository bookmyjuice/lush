import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/ReferralBloc/referral_bloc.dart';
import 'package:lush/bloc/ReferralBloc/referral_state.dart';
import 'package:lush/models/referral_info.dart';
import 'package:lush/views/screens/referral/referral_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockReferralBloc extends Mock implements ReferralBloc {}

Widget createTestWidget(ReferralBloc bloc) {
  return MaterialApp(
    home: BlocProvider<ReferralBloc>.value(
      value: bloc,
      child: const ReferralScreen(),
    ),
  );
}

void main() {
  late MockReferralBloc mockBloc;

  setUp(() {
    mockBloc = MockReferralBloc();
  });

  testWidgets('shows loading indicator when state is ReferralLoading',
      (tester) async {
    when(() => mockBloc.state).thenReturn(const ReferralLoading());
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(const ReferralLoading()));

    await tester.pumpWidget(createTestWidget(mockBloc));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows referral code when state is ReferralLoaded',
      (tester) async {
    final info = const ReferralInfo(referralCode: 'TEST123', referralCount: 2, totalRewardAmount: 100.0);
    when(() => mockBloc.state).thenReturn(ReferralLoaded(info: info));
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(ReferralLoaded(info: info)));

    await tester.pumpWidget(createTestWidget(mockBloc));
    expect(find.text('TEST123'), findsOneWidget);
  });

  testWidgets('shows 3 Card widgets when state is ReferralLoaded',
      (tester) async {
    final info = const ReferralInfo(referralCode: 'TEST123', referralCount: 2, totalRewardAmount: 100.0);
    when(() => mockBloc.state).thenReturn(ReferralLoaded(info: info));
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(ReferralLoaded(info: info)));

    await tester.pumpWidget(createTestWidget(mockBloc));
    expect(find.byType(Card), findsNWidgets(3));
  });

  testWidgets('Copy button shows SnackBar with Copied', (tester) async {
    final info = const ReferralInfo(referralCode: 'TEST123', referralCount: 2, totalRewardAmount: 100.0);
    when(() => mockBloc.state).thenReturn(ReferralLoaded(info: info));
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(ReferralLoaded(info: info)));

    await tester.pumpWidget(createTestWidget(mockBloc));
    await tester.tap(find.text('Copy Code'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('copied'), findsNWidgets(1));
  });

  testWidgets('Share button is present when state is ReferralLoaded',
      (tester) async {
    final info = const ReferralInfo(referralCode: 'TEST123', referralCount: 2, totalRewardAmount: 100.0);
    when(() => mockBloc.state).thenReturn(ReferralLoaded(info: info));
    when(() => mockBloc.stream).thenAnswer((_) => Stream.value(ReferralLoaded(info: info)));

    await tester.pumpWidget(createTestWidget(mockBloc));
    expect(find.text('Share'), findsOneWidget);
  });
}