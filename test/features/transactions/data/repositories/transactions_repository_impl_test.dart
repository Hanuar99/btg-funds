import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/features/transactions/data/models/transaction_model.dart';
import 'package:btg_funds_manager/features/transactions/data/repositories/transactions_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks/mock_classes.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late TransactionsRepositoryImpl sut;
  late MockTransactionsLocalDatasource mockDatasource;
  late MockNetworkInfo mockNetworkInfo;

  // ─── Models equivalentes al fixture de entidad ──────────────────────────────

  final tTransactionModel = TransactionModel(
    id: TestFixtures.tTransactionSubscription.id,
    fundId: TestFixtures.tTransactionSubscription.fundId,
    fundName: TestFixtures.tTransactionSubscription.fundName,
    type: 'subscription',
    amount: TestFixtures.tTransactionSubscription.amount,
    date: TestFixtures.tTransactionSubscription.date.toIso8601String(),
  );

  final tSavedTransactionModel = TransactionModel(
    id: 'tx-saved-001',
    fundId: TestFixtures.tTransactionSubscription.fundId,
    fundName: TestFixtures.tTransactionSubscription.fundName,
    type: 'subscription',
    amount: TestFixtures.tTransactionSubscription.amount,
    date: TestFixtures.tTransactionSubscription.date.toIso8601String(),
  );

  void stubOnline() {
    when(
      () => mockNetworkInfo.hasInternetConnection,
    ).thenAnswer((_) async => true);
  }

  void stubOffline() {
    when(
      () => mockNetworkInfo.hasInternetConnection,
    ).thenAnswer((_) async => false);
  }

  setUpAll(registerFallbackValues);

  setUp(() {
    mockDatasource = MockTransactionsLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    sut = TransactionsRepositoryImpl(mockDatasource, mockNetworkInfo);
  });

  group('TransactionsRepositoryImpl', () {
    // ─── getTransactions ───────────────────────────────────────────────────

    group('getTransactions', () {
      test('retorna NetworkFailure cuando no hay conexión', () async {
        // Arrange
        stubOffline();

        // Act
        final result = await sut.getTransactions();

        // Assert
        expect(result, const Left<Failure, dynamic>(NetworkFailure()));
        verifyNever(() => mockDatasource.getTransactions());
      });

      test('retorna Right con la lista de entities en happy path', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getTransactions(),
        ).thenAnswer((_) async => [tTransactionModel]);

        // Act
        final result = await sut.getTransactions();

        // Assert
        result.fold(
          (_) => fail('Debería ser Right'),
          (transactions) {
            expect(transactions, hasLength(1));
            expect(
              transactions.first.fundId,
              TestFixtures.tTransactionSubscription.fundId,
            );
            expect(
              transactions.first.type,
              TestFixtures.tTransactionSubscription.type,
            );
          },
        );
      });

      test('lista vacía de datasource retorna Right con lista vacía', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getTransactions(),
        ).thenAnswer((_) async => []);

        // Act
        final result = await sut.getTransactions();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Debería ser Right'),
          (transactions) => expect(transactions, isEmpty),
        );
      });

      test('CacheException se convierte en CacheFailure', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getTransactions(),
        ).thenThrow(const CacheException('Error de lectura'));

        // Act
        final result = await sut.getTransactions();

        // Assert
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Debería ser Left'),
        );
      });
    });

    // ─── addTransaction ────────────────────────────────────────────────────

    group('addTransaction', () {
      test('retorna NetworkFailure cuando no hay conexión', () async {
        // Arrange
        stubOffline();

        // Act
        final result = await sut.addTransaction(
          TestFixtures.tTransactionSubscription,
        );

        // Assert
        expect(result, const Left<Failure, dynamic>(NetworkFailure()));
        verifyNever(
          () => mockDatasource.addTransaction(any()),
        );
      });

      test('convierte la entity a model y la pasa al datasource', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.addTransaction(any()),
        ).thenAnswer((_) async => tSavedTransactionModel);

        // Act
        await sut.addTransaction(TestFixtures.tTransactionSubscription);

        // Assert
        final captured =
            verify(
                  () => mockDatasource.addTransaction(captureAny()),
                ).captured.first
                as TransactionModel;

        expect(captured.fundId, TestFixtures.tTransactionSubscription.fundId);
        expect(
          captured.type,
          'subscription',
        ); // TransactionModel.type es String
        expect(captured.amount, TestFixtures.tTransactionSubscription.amount);
      });

      test(
        'retorna Right con la entity del model guardado por el datasource',
        () async {
          // Arrange
          stubOnline();
          when(
            () => mockDatasource.addTransaction(any()),
          ).thenAnswer((_) async => tSavedTransactionModel);

          // Act
          final result = await sut.addTransaction(
            TestFixtures.tTransactionSubscription,
          );

          // Assert
          result.fold(
            (_) => fail('Debería ser Right'),
            (transaction) {
              expect(transaction.id, tSavedTransactionModel.id);
              expect(transaction.fundId, tSavedTransactionModel.fundId);
            },
          );
        },
      );

      test('CacheException se convierte en CacheFailure', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.addTransaction(any()),
        ).thenThrow(const CacheException('Error al guardar'));

        // Act
        final result = await sut.addTransaction(
          TestFixtures.tTransactionSubscription,
        );

        // Assert
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Debería ser Left'),
        );
      });
    });
  });
}
