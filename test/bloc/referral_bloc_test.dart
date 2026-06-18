import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lush/bloc/ReferralBloc/referral_bloc.dart';
import 'package:lush/bloc/ReferralBloc/referral_event.dart';
import 'package:lush/bloc/ReferralBloc/referral_state.dart';
import 'package:lush/models/referral_info.dart';
import 'package:lush/repositories/referral_repository.dart';
import 'package:lush/utils/analytics_service.dart';
import 'package:mocktail/mocktail.dart';

class MockReferralRepository extends Mock implements ReferralRepository {}

void main() {
  late MockReferralRepository mockRepo;

  setUp(() {
    mockRepo = MockReferralRepository();
  });

  tearDown(() {
    // No bloc to close since we create inline
  });

  test('initial state is ReferralInitial', () {
    final bloc = ReferralBloc(
      referralRepository: mockRepo,
      analyticsService: AnalyticsService(),
    );
    expect(bloc.state, isA<ReferralInitial>());
    bloc.close();
  });

  blocTest<ReferralBloc, ReferralState>(
    'emits [ReferralLoading, ReferralLoaded] on success',
    build: () {
      when(() => mockRepo.getReferralInfo()).thenAnswer((_) async => const ReferralInfo(
            referralCode: 'TEST123',
            referralCount: 2,
            totalRewardAmount: 100.0,
          ),);
      return ReferralBloc(
        referralRepository: mockRepo,
        analyticsService: AnalyticsService(),
      );
    },
    act: (bloc) => bloc.add(const LoadReferralInfo()),
    expect: () => [
      isA<ReferralLoading>(),
      isA<ReferralLoaded>(),
    ],
    verify: (bloc) {
      final state = bloc.state as ReferralLoaded;
      expect(state.info.referralCode, 'TEST123');
      expect(state.info.referralCount, 2);
      expect(state.info.totalRewardAmount, 100.0);
    },
  );

  blocTest<ReferralBloc, ReferralState>(
    'emits [ReferralLoading, ReferralError] on failure',
    build: () {
      when(() => mockRepo.getReferralInfo()).thenThrow(Exception('network error'));
      return ReferralBloc(
        referralRepository: mockRepo,
        analyticsService: AnalyticsService(),
      );
    },
    act: (bloc) => bloc.add(const LoadReferralInfo()),
    expect: () => [
      isA<ReferralLoading>(),
      isA<ReferralError>(),
    ],
  );

  blocTest<ReferralBloc, ReferralState>(
    'ShareReferralCode does not change state',
    build: () => ReferralBloc(
      referralRepository: mockRepo,
      analyticsService: AnalyticsService(),
    ),
    act: (bloc) => bloc.add(const ShareReferralCode()),
    expect: () => [],
  );
}