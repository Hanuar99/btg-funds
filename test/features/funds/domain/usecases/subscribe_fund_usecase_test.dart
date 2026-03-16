import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/subscribe_fund_usecase.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks/mock_classes.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late SubscribeFundUseCase sut;
  late MockFundsRepository mockFundsRepository;
  late MockUserRepository mockUserRepository;
  late MockTransactionsRepository mockTransactionsRepository;

  // Fixture local: usuario con saldo exactamente igual al mínimo del fondo
  const tUserExactBalance = User(id: 'user-001', balance: 75000);

  setUp(() {
    mockFundsRepository = MockFundsRepository();
    mockUserRepository = MockUserRepository();
    mockTransactionsRepository = MockTransactionsRepository();
    sut = SubscribeFundUseCase(
      mockFundsRepository,
      mockUserRepository,
      mockTransactionsRepository,
    );
    // Fallback values para mocktail
    registerFallbackValues();
    registerFallbackValue(TestFixtures.tTransactionSubscription);
  });

  /// Configura el happy path completo en los mocks.
  void _stubHappyPath({User user = TestFixtures.tUser}) {
    when(
      () => mockUserRepository.getUser(),
    ).thenAnswer((_) async => Right(user));
    when(
      () => mockFundsRepository.subscribeFund(
        fundId: any(named: 'fundId'),
        amount: any(named: 'amount'),
      ),
    ).thenAnswer((_) async => Right(TestFixtures.tFundSubscribed));
    when(
      () => mockUserRepository.updateBalance(any()),
    ).thenAnswer((_) async => Right(TestFixtures.tUserAfterSubscription));
    when(
      () => mockUserRepository.addSubscribedFund(any(), any()),
    ).thenAnswer((_) async => Right(TestFixtures.tUserAfterSubscription));
    when(
      () => mockTransactionsRepository.addTransaction(any()),
    ).thenAnswer((_) async => Right(TestFixtures.tTransactionSubscription));
  }

  group('SubscribeFundUseCase', () {
    // ─── Happy path ──────────────────────────────────────────────────────────

    group('happy path', () {
      test(
        'retorna Right con el fondo suscrito cuando todo funciona',
        () async {
          // Arrange
          _stubHappyPath();

          // Act
          final result = await sut(TestFixtures.tSubscribeFundParams);

          // Assert
          expect(result, Right<Failure, Fund>(TestFixtures.tFundSubscribed));
        },
      );

      test('llama updateBalance con el saldo_actual - amount exacto', () async {
        // Arrange — user.balance=500000, params.amount=75000 → nuevo saldo=425000
        _stubHappyPath();

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        verify(() => mockUserRepository.updateBalance(425000)).called(1);
      });

      test('llama addSubscribedFund con fundId y amount correctos', () async {
        // Arrange
        _stubHappyPath();

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        verify(
          () => mockUserRepository.addSubscribedFund('1', 75000),
        ).called(1);
      });

      test('la transacción registrada tiene type=subscription', () async {
        // Arrange
        _stubHappyPath();

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert — captura la transacción pasada a addTransaction
        final captured = verify(
          () => mockTransactionsRepository.addTransaction(captureAny()),
        ).captured;
        final transaction = captured.first as Transaction;
        expect(transaction.type, TransactionType.subscription);
      });

      test('la transacción registrada tiene el amount de params', () async {
        // Arrange
        _stubHappyPath();

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        final captured = verify(
          () => mockTransactionsRepository.addTransaction(captureAny()),
        ).captured;
        final transaction = captured.first as Transaction;
        expect(transaction.amount, 75000);
      });

      test(
        'la transacción usa fundId y fundName del FONDO devuelto, no de params',
        () async {
          // Arrange — el fondo devuelto por subscribeFund es tFundSubscribed (id='1', name=RECAUDADORA)
          _stubHappyPath();

          // Act
          await sut(TestFixtures.tSubscribeFundParams);

          // Assert
          final captured = verify(
            () => mockTransactionsRepository.addTransaction(captureAny()),
          ).captured;
          final transaction = captured.first as Transaction;
          expect(transaction.fundId, TestFixtures.tFundSubscribed.id);
          expect(transaction.fundName, TestFixtures.tFundSubscribed.name);
        },
      );

      test('la transacción incluye el notificationMethod de params', () async {
        // Arrange
        _stubHappyPath();

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        final captured = verify(
          () => mockTransactionsRepository.addTransaction(captureAny()),
        ).captured;
        final transaction = captured.first as Transaction;
        expect(transaction.notificationMethod, NotificationMethod.email);
      });
    });

    // ─── Edge case: saldo exactamente igual al mínimo ─────────────────────

    group('edge case - saldo exactamente igual al monto', () {
      test('funciona cuando balance == amount (no es insuficiente)', () async {
        // Arrange — balance=75000, amount=75000 → 75000 < 75000 es false → pasa
        _stubHappyPath(user: tUserExactBalance);

        // Act
        final result = await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        expect(result.isRight(), isTrue);
      });

      test('llama updateBalance con 0 cuando balance == amount', () async {
        // Arrange
        _stubHappyPath(user: tUserExactBalance);

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        verify(() => mockUserRepository.updateBalance(0)).called(1);
      });
    });

    // ─── Saldo insuficiente ───────────────────────────────────────────────

    group('saldo insuficiente', () {
      test(
        'retorna Left(InsufficientBalanceFailure) cuando balance < amount',
        () async {
          // Arrange — tUserLowBalance.balance=10000 < params.amount=75000
          when(
            () => mockUserRepository.getUser(),
          ).thenAnswer((_) async => Right(TestFixtures.tUserLowBalance));

          // Act
          final result = await sut(TestFixtures.tSubscribeFundParams);

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<InsufficientBalanceFailure>()),
            (_) => fail('Debería ser Left'),
          );
        },
      );

      test('NO llama subscribeFund cuando el saldo es insuficiente', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUserLowBalance));

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        verifyNever(
          () => mockFundsRepository.subscribeFund(
            fundId: any(named: 'fundId'),
            amount: any(named: 'amount'),
          ),
        );
      });

      test('NO llama updateBalance cuando el saldo es insuficiente', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUserLowBalance));

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        verifyNever(() => mockUserRepository.updateBalance(any()));
      });

      test(
        'NO llama addSubscribedFund cuando el saldo es insuficiente',
        () async {
          // Arrange
          when(
            () => mockUserRepository.getUser(),
          ).thenAnswer((_) async => Right(TestFixtures.tUserLowBalance));

          // Act
          await sut(TestFixtures.tSubscribeFundParams);

          // Assert
          verifyNever(() => mockUserRepository.addSubscribedFund(any(), any()));
        },
      );

      test('NO registra transacción cuando el saldo es insuficiente', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUserLowBalance));

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        verifyNever(
          () => mockTransactionsRepository.addTransaction(any()),
        );
      });
    });

    // ─── Propagación de failures ──────────────────────────────────────────

    group('propagación de failures', () {
      test('propaga el failure cuando getUser falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        final result = await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        expect(result, const Left<Failure, Fund>(TestFixtures.tCacheFailure));
      });

      test('propaga el failure cuando subscribeFund falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.subscribeFund(
            fundId: any(named: 'fundId'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer(
          (_) async => const Left(TestFixtures.tAlreadySubscribedFailure),
        );

        // Act
        final result = await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        expect(
          result,
          const Left<Failure, Fund>(TestFixtures.tAlreadySubscribedFailure),
        );
      });

      test('NO llama updateBalance cuando subscribeFund falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.subscribeFund(
            fundId: any(named: 'fundId'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer(
          (_) async => const Left(TestFixtures.tAlreadySubscribedFailure),
        );

        // Act
        await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        verifyNever(() => mockUserRepository.updateBalance(any()));
      });

      test('propaga el failure cuando updateBalance falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.subscribeFund(
            fundId: any(named: 'fundId'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer((_) async => Right(TestFixtures.tFundSubscribed));
        when(
          () => mockUserRepository.updateBalance(any()),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        final result = await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        expect(result, const Left<Failure, Fund>(TestFixtures.tCacheFailure));
      });

      test('propaga el failure cuando addSubscribedFund falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.subscribeFund(
            fundId: any(named: 'fundId'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer((_) async => Right(TestFixtures.tFundSubscribed));
        when(
          () => mockUserRepository.updateBalance(any()),
        ).thenAnswer((_) async => Right(TestFixtures.tUserAfterSubscription));
        when(
          () => mockUserRepository.addSubscribedFund(any(), any()),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        final result = await sut(TestFixtures.tSubscribeFundParams);

        // Assert
        expect(result, const Left<Failure, Fund>(TestFixtures.tCacheFailure));
      });

      test('propaga el failure cuando addTransaction falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => Right(TestFixtures.tUser));
        when(
          () => mockFundsRepository.subscribeFund(
            fundId: any(named: 'fundId'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer((_) async => Right(TestFixtures.tFundSubscribed));
        when(
          () => mockUserRepository.updateBalance(any()),
        ).thenAnswer((_) async => Right(TestFixtures.tUserAfterSubscription));
        when(
          () => mockUserRepository.addSubscribedFund(any(), any()),
        ).thenAnswer((_) async => Right(TestFixtures.tUserAfterSubscription));
        when(
          () => mockTransactionsRepository.addTransaction(any()),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        final result = await sut(TestFixtures.tSubscribeFundParams);

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
          _stubHappyPath();

          // Act
          await sut(TestFixtures.tSubscribeFundParams);

          // Assert — verifica el orden: getUser → subscribeFund → updateBalance
          //          → addSubscribedFund → addTransaction
          verifyInOrder([
            () => mockUserRepository.getUser(),
            () => mockFundsRepository.subscribeFund(
              fundId: any(named: 'fundId'),
              amount: any(named: 'amount'),
            ),
            () => mockUserRepository.updateBalance(any()),
            () => mockUserRepository.addSubscribedFund(any(), any()),
            () => mockTransactionsRepository.addTransaction(any()),
          ]);
        },
      );
    });
  });
}
