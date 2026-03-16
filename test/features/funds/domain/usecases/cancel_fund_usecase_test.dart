import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/cancel_fund_usecase.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks/mock_classes.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late CancelFundUseCase sut;
  late MockFundsRepository mockFundsRepository;
  late MockUserRepository mockUserRepository;
  late MockTransactionsRepository mockTransactionsRepository;

  setUp(() {
    mockFundsRepository = MockFundsRepository();
    mockUserRepository = MockUserRepository();
    mockTransactionsRepository = MockTransactionsRepository();
    sut = CancelFundUseCase(
      mockFundsRepository,
      mockUserRepository,
      mockTransactionsRepository,
    );
    registerFallbackValues();
    registerFallbackValue(TestFixtures.tTransactionCancellation);
  });

  /// Configura el happy path completo en los mocks.
  /// [cancelledFund] es el fondo devuelto por cancelFund() — debe tener subscribedAmount.
  void stubHappyPath({
    User user = TestFixtures.tUser,
    Fund? cancelledFund,
  }) {
    final fund = cancelledFund ?? TestFixtures.tFundSubscribed;
    when(
      () => mockUserRepository.getUser(),
    ).thenAnswer((_) async => Right(user));
    when(
      () => mockFundsRepository.cancelFund(fundId: any(named: 'fundId')),
    ).thenAnswer((_) async => Right(fund));
    when(
      () => mockUserRepository.updateBalance(any()),
    ).thenAnswer((_) async => Right(user));
    when(
      () => mockUserRepository.removeSubscribedFund(any()),
    ).thenAnswer((_) async => Right(user));
    when(
      () => mockTransactionsRepository.addTransaction(any()),
    ).thenAnswer((_) async => Right(TestFixtures.tTransactionCancellation));
  }

  group('CancelFundUseCase', () {
    // ─── Happy path ──────────────────────────────────────────────────────────

    group('happy path', () {
      test(
        'retorna Right con el fondo cancelado cuando todo funciona',
        () async {
          // Arrange
          stubHappyPath();

          // Act
          final result = await sut(TestFixtures.tCancelFundParams);

          // Assert
          expect(result, Right<Failure, Fund>(TestFixtures.tFundSubscribed));
        },
      );

      test(
        'llama updateBalance con saldo_actual + fund.subscribedAmount exacto',
        () async {
          // Arrange — user.balance=500000, fund.subscribedAmount=75000 → 575000
          stubHappyPath();

          // Act
          await sut(TestFixtures.tCancelFundParams);

          // Assert — EL TEST MÁS IMPORTANTE: devuelve el dinero correcto
          verify(() => mockUserRepository.updateBalance(575000)).called(1);
        },
      );

      test('llama removeSubscribedFund con el fundId correcto', () async {
        // Arrange
        stubHappyPath();

        // Act
        await sut(TestFixtures.tCancelFundParams);

        // Assert — método exacto: removeSubscribedFund, no otro
        verify(() => mockUserRepository.removeSubscribedFund('1')).called(1);
      });

      test('la transacción registrada tiene type=cancellation', () async {
        // Arrange
        stubHappyPath();

        // Act
        await sut(TestFixtures.tCancelFundParams);

        // Assert
        final captured = verify(
          () => mockTransactionsRepository.addTransaction(captureAny()),
        ).captured;
        final transaction = captured.first as Transaction;
        expect(transaction.type, TransactionType.cancellation);
      });

      test(
        'la transacción registrada NO tiene notificationMethod (es null)',
        () async {
          // Arrange
          stubHappyPath();

          // Act
          await sut(TestFixtures.tCancelFundParams);

          // Assert
          final captured = verify(
            () => mockTransactionsRepository.addTransaction(captureAny()),
          ).captured;
          final transaction = captured.first as Transaction;
          expect(transaction.notificationMethod, isNull);
        },
      );

      test('el amount de la transacción es fund.subscribedAmount', () async {
        // Arrange — tFundSubscribed.subscribedAmount = 75000
        stubHappyPath();

        // Act
        await sut(TestFixtures.tCancelFundParams);

        // Assert
        final captured = verify(
          () => mockTransactionsRepository.addTransaction(captureAny()),
        ).captured;
        final transaction = captured.first as Transaction;
        expect(
          transaction.amount,
          TestFixtures.tFundSubscribed.subscribedAmount,
        );
      });

      test(
        'la transacción usa fundId y fundName del FONDO devuelto por cancelFund',
        () async {
          // Arrange
          stubHappyPath();

          // Act
          await sut(TestFixtures.tCancelFundParams);

          // Assert
          final captured = verify(
            () => mockTransactionsRepository.addTransaction(captureAny()),
          ).captured;
          final transaction = captured.first as Transaction;
          expect(transaction.fundId, TestFixtures.tFundSubscribed.id);
          expect(transaction.fundName, TestFixtures.tFundSubscribed.name);
        },
      );
    });

    // ─── Cálculo de refund ────────────────────────────────────────────────

    group('cálculo del refund', () {
      test(
        'devuelve el monto correcto para un fondo con subscribeAmount distinto',
        () async {
          // Arrange — fondo con subscribedAmount=125000 y usuario con balance=300000
          const tUserConSaldo = User(id: 'user-001', balance: 300000);
          final tFondoSuscrito125k = TestFixtures.tFund2.copyWith(
            isSubscribed: true,
            subscribedAmount: 125000,
          );
          stubHappyPath(user: tUserConSaldo, cancelledFund: tFondoSuscrito125k);

          // Act
          await sut(const CancelFundParams(fundId: '2'));

          // Assert — 300000 + 125000 = 425000
          verify(() => mockUserRepository.updateBalance(425000)).called(1);
        },
      );
    });

    // ─── Propagación de failures ──────────────────────────────────────────

    group('propagación de failures', () {
      test('propaga el failure cuando getUser falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        final result = await sut(TestFixtures.tCancelFundParams);

        // Assert
        expect(result, const Left<Failure, Fund>(TestFixtures.tCacheFailure));
      });

      test('propaga el failure cuando cancelFund falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.cancelFund(fundId: any(named: 'fundId')),
        ).thenAnswer(
          (_) async => const Left(TestFixtures.tNotSubscribedFailure),
        );

        // Act
        final result = await sut(TestFixtures.tCancelFundParams);

        // Assert
        expect(
          result,
          const Left<Failure, Fund>(TestFixtures.tNotSubscribedFailure),
        );
      });

      test('NO llama updateBalance cuando cancelFund falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.cancelFund(fundId: any(named: 'fundId')),
        ).thenAnswer(
          (_) async => const Left(TestFixtures.tNotSubscribedFailure),
        );

        // Act
        await sut(TestFixtures.tCancelFundParams);

        // Assert
        verifyNever(() => mockUserRepository.updateBalance(any()));
      });

      test('NO llama removeSubscribedFund cuando cancelFund falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.cancelFund(fundId: any(named: 'fundId')),
        ).thenAnswer(
          (_) async => const Left(TestFixtures.tFundNotFoundFailure),
        );

        // Act
        await sut(TestFixtures.tCancelFundParams);

        // Assert
        verifyNever(() => mockUserRepository.removeSubscribedFund(any()));
      });

      test('NO registra transacción cuando cancelFund falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.cancelFund(fundId: any(named: 'fundId')),
        ).thenAnswer(
          (_) async => const Left(TestFixtures.tFundNotFoundFailure),
        );

        // Act
        await sut(TestFixtures.tCancelFundParams);

        // Assert
        verifyNever(
          () => mockTransactionsRepository.addTransaction(any()),
        );
      });

      test('propaga el failure cuando updateBalance falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.cancelFund(fundId: any(named: 'fundId')),
        ).thenAnswer((_) async => Right(TestFixtures.tFundSubscribed));
        when(
          () => mockUserRepository.updateBalance(any()),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        final result = await sut(TestFixtures.tCancelFundParams);

        // Assert
        expect(result, const Left<Failure, Fund>(TestFixtures.tCacheFailure));
      });

      test('propaga el failure cuando addTransaction falla', () async {
        // Arrange
        stubHappyPath();
        // Sobreescribe addTransaction para que falle
        when(
          () => mockTransactionsRepository.addTransaction(any()),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        final result = await sut(TestFixtures.tCancelFundParams);

        // Assert
        expect(result, const Left<Failure, Fund>(TestFixtures.tCacheFailure));
      });
    });

    // ─── Orden de llamadas ────────────────────────────────────────────────

    group('orden de llamadas', () {
      test(
        'llama a los repositorios en el orden correcto en el happy path',
        () async {
          // Arrange
          stubHappyPath();

          // Act
          await sut(TestFixtures.tCancelFundParams);

          // Assert — getUser → cancelFund → updateBalance → removeSubscribedFund → addTransaction
          verifyInOrder([
            () => mockUserRepository.getUser(),
            () => mockFundsRepository.cancelFund(fundId: any(named: 'fundId')),
            () => mockUserRepository.updateBalance(any()),
            () => mockUserRepository.removeSubscribedFund(any()),
            () => mockTransactionsRepository.addTransaction(any()),
          ]);
        },
      );
    });
  });
}
