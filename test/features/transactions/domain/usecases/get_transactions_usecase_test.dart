import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks/mock_classes.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetTransactionsUseCase sut;
  late MockTransactionsRepository mockTransactionsRepository;

  setUp(() {
    mockTransactionsRepository = MockTransactionsRepository();
    sut = GetTransactionsUseCase(mockTransactionsRepository);
    registerFallbackValue(const NoParams());
  });

  group('GetTransactionsUseCase', () {
    group('contrato UseCase', () {
      test('es instancia de GetTransactionsUseCase', () {
        // Assert
        expect(sut, isA<GetTransactionsUseCase>());
      });
    });

    group('happy path', () {
      test(
        'retorna Right con la lista de transacciones cuando el repositorio responde ok',
        () async {
          // Arrange
          final tTransactions = [
            TestFixtures.tTransactionSubscription,
            TestFixtures.tTransactionCancellation,
          ];
          when(
            () => mockTransactionsRepository.getTransactions(),
          ).thenAnswer((_) async => Right(tTransactions));

          // Act
          final result = await sut(const NoParams());

          // Assert
          expect(result, Right<Failure, dynamic>(tTransactions));
        },
      );

      test('llama a getTransactions() exactamente una vez', () async {
        // Arrange
        when(() => mockTransactionsRepository.getTransactions()).thenAnswer(
          (_) async => Right<Failure, List<Transaction>>(
            [TestFixtures.tTransactionSubscription],
          ),
        );

        // Act
        await sut(const NoParams());

        // Assert
        verify(() => mockTransactionsRepository.getTransactions()).called(1);
      });

      test(
        'una lista vacía no es un error — retorna Right con lista vacía',
        () async {
          // Arrange
          when(
            () => mockTransactionsRepository.getTransactions(),
          ).thenAnswer((_) async => const Right([]));

          // Act
          final result = await sut(const NoParams());

          // Assert
          expect(
            result,
            Right<Failure, List<Transaction>>(const <Transaction>[]),
          );
        },
      );

      test('retorna la lista con un solo elemento correctamente', () async {
        // Arrange
        final tSingleList = [TestFixtures.tTransactionSubscription];
        when(
          () => mockTransactionsRepository.getTransactions(),
        ).thenAnswer((_) async => Right(tSingleList));

        // Act
        final result = await sut(const NoParams());

        // Assert
        result.fold(
          (_) => fail('Debería ser Right'),
          (transactions) => expect(transactions, hasLength(1)),
        );
      });
    });

    group('error path', () {
      test('propaga el CacheFailure cuando el repositorio falla', () async {
        // Arrange
        when(
          () => mockTransactionsRepository.getTransactions(),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        final result = await sut(const NoParams());

        // Assert
        expect(
          result,
          const Left<Failure, dynamic>(TestFixtures.tCacheFailure),
        );
      });

      test('propaga cualquier tipo de Failure sin modificarlo', () async {
        // Arrange
        when(() => mockTransactionsRepository.getTransactions()).thenAnswer(
          (_) async => const Left(TestFixtures.tUnexpectedFailure),
        );

        // Act
        final result = await sut(const NoParams());

        // Assert
        expect(
          result,
          const Left<Failure, dynamic>(TestFixtures.tUnexpectedFailure),
        );
      });

      test('no llama getTransactions() más de una vez aunque falle', () async {
        // Arrange
        when(
          () => mockTransactionsRepository.getTransactions(),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        await sut(const NoParams());

        // Assert
        verify(() => mockTransactionsRepository.getTransactions()).called(1);
      });
    });
  });
}
