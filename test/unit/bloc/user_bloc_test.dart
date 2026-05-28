/// Unit tests for [UserBloc] — specifically the bottle-related events:
///   - LoadBottleLedger
///   - ReportReturn
///   - ReportBroken
///
/// References test cases from docs/use-cases/UC-BOTTLE-TRACKING.md
library;

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:lush/UserRepository/user_repository.dart';
import 'package:lush/bloc/UserBloc/user_bloc.dart';
import 'package:lush/bloc/UserBloc/user_events.dart';
import 'package:lush/bloc/UserBloc/user_state.dart';
import 'package:lush/services/bottle_service.dart';
import 'package:lush/views/models/bottle_ledger.dart';
import 'package:lush/views/models/user.dart';
import 'package:mocktail/mocktail.dart';

class MockBottleService extends Mock implements BottleService {}

class MockUserRepository extends Mock implements UserRepository {}

/// Helper to create a test BottleLedgerEntry
BottleLedgerEntry createTestLedgerEntry({
  String customerId = 'cb_cus_test123',
  String bottleType = 'glass_500ml',
  int totalIssued = 10,
  int totalReturned = 4,
  int totalBroken = 1,
  String? lastTransactionAt,
}) {
  return BottleLedgerEntry(
    customerId: customerId,
    bottleType: bottleType,
    totalIssued: totalIssued,
    totalReturned: totalReturned,
    totalBroken: totalBroken,
    outstanding: totalIssued - totalReturned - totalBroken,
    lastTransactionAt: lastTransactionAt,
  );
}

/// Helper to create a test BottleTransaction
BottleTransaction createTestTransaction({
  int? id = 1,
  String orderId = 'cb_order_001',
  String customerId = 'cb_cus_test123',
  String bottleType = 'glass_500ml',
  int quantity = 5,
  String action = 'ISSUED',
  String? notes,
  String? createdAt,
}) {
  return BottleTransaction(
    id: id,
    orderId: orderId,
    customerId: customerId,
    bottleType: bottleType,
    quantity: quantity,
    action: action,
    notes: notes,
    createdAt: createdAt,
  );
}

void main() {
  late MockBottleService mockBottleService;
  late MockUserRepository mockUserRepository;

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockBottleService = MockBottleService();
    mockUserRepository = MockUserRepository();
    // Register mocks in GetIt so the default getIt.get() in UserBloc uses them
    final getIt = GetIt.instance;
    if (!getIt.isRegistered<UserRepository>()) {
      getIt.registerFactory<UserRepository>(() => mockUserRepository);
    }
    if (!getIt.isRegistered<BottleService>()) {
      getIt.registerFactory<BottleService>(() => mockBottleService);
    }
  });

  tearDown(() {
    // Reset GetIt to clean state after each test
    GetIt.instance.reset();
  });

  // ─── LoadBottleLedger ──────────────────────────────────────────
  group('LoadBottleLedger', () {
    blocTest<UserBloc, UserState>(
      'LoadBottleLedger success emits BottleLedgerLoaded',
      build: () {
        when(() => mockBottleService.getLedger())
            .thenAnswer((_) async => [
                  createTestLedgerEntry(),
                  createTestLedgerEntry(
                    bottleType: 'plastic_1l',
                    totalIssued: 3,
                    totalReturned: 0,
                    totalBroken: 0,
                  ),
                ]);
        when(() => mockBottleService.getTransactions())
            .thenAnswer((_) async => [
                  createTestTransaction(),
                  createTestTransaction(
                    action: 'RETURNED',
                    quantity: 2,
                  ),
                ]);
        return UserBloc();
      },
      act: (bloc) => bloc.add(const LoadBottleLedger()),
      expect: () => [
        isA<BottleLedgerLoaded>(),
      ],
      verify: (bloc) {
        final state = bloc.state as BottleLedgerLoaded;
        expect(state.ledger.length, 2);
        expect(state.transactions.length, 2);

        // Check glass_500ml entry
        final glassEntry = state.ledger.firstWhere(
          (e) => e.bottleType == 'glass_500ml',
        );
        expect(glassEntry.totalIssued, 10);
        expect(glassEntry.totalReturned, 4);
        expect(glassEntry.totalBroken, 1);
        expect(glassEntry.outstanding, 5);
      },
    );

    blocTest<UserBloc, UserState>(
      'LoadBottleLedger failure emits UserError',
      build: () {
        when(() => mockBottleService.getLedger())
            .thenThrow(Exception('Network error'));
        return UserBloc();
      },
      act: (bloc) => bloc.add(const LoadBottleLedger()),
      expect: () => [
        isA<UserError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as UserError;
        expect(state.message, contains('Network error'));
      },
    );
  });

  // ─── ReportReturn ─────────────────────────────────────────────
  group('ReportReturn', () {
    blocTest<UserBloc, UserState>(
      'ReportReturn success emits BottleReportSuccess then refreshes ledger',
      build: () {
        when(() => mockBottleService.recordReturn(
              any(),
              any(),
              any(),
              notes: any(named: 'notes'),
            )).thenAnswer((_) async => createTestTransaction(
              action: 'RETURNED',
              quantity: 3,
            ));
        // After success, bloc adds LoadBottleLedger to refresh
        when(() => mockBottleService.getLedger())
            .thenAnswer((_) async => [createTestLedgerEntry()]);
        when(() => mockBottleService.getTransactions())
            .thenAnswer((_) async => [createTestTransaction()]);
        return UserBloc();
      },
      act: (bloc) => bloc.add(const ReportReturn(
        orderId: 'cb_order_001',
        bottleType: 'glass_500ml',
        quantity: 3,
      )),
      expect: () => [
        isA<BottleReportSuccess>(),
        isA<BottleLedgerLoaded>(),
      ],
      verify: (bloc) {
        verify(() => mockBottleService.recordReturn(
              'cb_order_001',
              'glass_500ml',
              3,
              notes: any(named: 'notes'),
            )).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'ReportReturn failure emits UserError',
      build: () {
        when(() => mockBottleService.recordReturn(
              any(),
              any(),
              any(),
              notes: any(named: 'notes'),
            )).thenThrow(Exception('Failed to record return'));
        return UserBloc();
      },
      act: (bloc) => bloc.add(const ReportReturn(
        orderId: 'cb_order_001',
        bottleType: 'glass_500ml',
        quantity: 3,
      )),
      expect: () => [
        isA<UserError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as UserError;
        expect(state.message, contains('Failed to record return'));
      },
    );
  });

  // ─── ReportBroken ─────────────────────────────────────────────
  group('ReportBroken', () {
    blocTest<UserBloc, UserState>(
      'ReportBroken success emits BottleReportSuccess then refreshes ledger',
      build: () {
        when(() => mockBottleService.recordBroken(
              any(),
              any(),
              any(),
              notes: any(named: 'notes'),
            )).thenAnswer((_) async => createTestTransaction(
              action: 'BROKEN',
              quantity: 2,
            ));
        // After success, bloc adds LoadBottleLedger to refresh
        when(() => mockBottleService.getLedger())
            .thenAnswer((_) async => [createTestLedgerEntry()]);
        when(() => mockBottleService.getTransactions())
            .thenAnswer((_) async => [createTestTransaction()]);
        return UserBloc();
      },
      act: (bloc) => bloc.add(const ReportBroken(
        orderId: 'cb_order_002',
        bottleType: 'glass_500ml',
        quantity: 2,
      )),
      expect: () => [
        isA<BottleReportSuccess>(),
        isA<BottleLedgerLoaded>(),
      ],
      verify: (bloc) {
        verify(() => mockBottleService.recordBroken(
              'cb_order_002',
              'glass_500ml',
              2,
              notes: any(named: 'notes'),
            )).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'ReportBroken failure emits UserError',
      build: () {
        when(() => mockBottleService.recordBroken(
              any(),
              any(),
              any(),
              notes: any(named: 'notes'),
            )).thenThrow(Exception('Failed to record broken'));
        return UserBloc();
      },
      act: (bloc) => bloc.add(const ReportBroken(
        orderId: 'cb_order_002',
        bottleType: 'glass_500ml',
        quantity: 2,
      )),
      expect: () => [
        isA<UserError>(),
      ],
      verify: (bloc) {
        final state = bloc.state as UserError;
        expect(state.message, contains('Failed to record broken'));
      },
    );
  });
}
