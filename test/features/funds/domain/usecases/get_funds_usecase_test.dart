import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/get_funds_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks/mock_classes.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetFundsUseCase sut;
  late MockFundsRepository mockFundsRepository;

  setUp(() {
    mockFundsRepository = MockFundsRepository();
    sut = GetFundsUseCase(mockFundsRepository);
    registerFallbackValue(const NoParams());
  });

  group('GetFundsUseCase', () {
    group('contrato UseCase', () {
      test('es instancia de GetFundsUseCase', () {
        // Assert
        expect(sut, isA<GetFundsUseCase>());
      });
    });

    group('happy path', () {
      test(
        'retorna Right con la lista de fondos cuando el repositorio responde ok',
        () async {
          // Arrange
          when(
            () => mockFundsRepository.getFunds(),
          ).thenAnswer((_) async => const Right(TestFixtures.tAllFunds));

          // Act
          final result = await sut(const NoParams());

          // Assert
          expect(result, const Right<Failure, dynamic>(TestFixtures.tAllFunds));
        },
      );

      test('llama a getFunds() exactamente una vez', () async {
        // Arrange
        when(
          () => mockFundsRepository.getFunds(),
        ).thenAnswer((_) async => const Right(TestFixtures.tAllFunds));

        // Act
        await sut(const NoParams());

        // Assert
        verify(() => mockFundsRepository.getFunds()).called(1);
      });

      test(
        'una lista vacía no es un error — retorna Right con lista vacía',
        () async {
          // Arrange
          when(
            () => mockFundsRepository.getFunds(),
          ).thenAnswer((_) async => const Right([]));

          // Act
          final result = await sut(const NoParams());

          // Assert
          expect(result, Right<Failure, List<Fund>>(const <Fund>[]));
        },
      );
    });

    group('error path', () {
      test('propaga el CacheFailure cuando el repositorio falla', () async {
        // Arrange
        when(
          () => mockFundsRepository.getFunds(),
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
        when(
          () => mockFundsRepository.getFunds(),
        ).thenAnswer((_) async => const Left(TestFixtures.tUnexpectedFailure));

        // Act
        final result = await sut(const NoParams());

        // Assert
        expect(
          result,
          const Left<Failure, dynamic>(TestFixtures.tUnexpectedFailure),
        );
      });

      test('no llama getFunds() más de una vez aunque falle', () async {
        // Arrange
        when(
          () => mockFundsRepository.getFunds(),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        await sut(const NoParams());

        // Assert
        verify(() => mockFundsRepository.getFunds()).called(1);
      });
    });
  });
}
