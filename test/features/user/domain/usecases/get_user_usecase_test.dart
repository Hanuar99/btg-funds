import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:btg_funds_manager/features/user/domain/usecases/get_user_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks/mock_classes.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late GetUserUseCase sut;
  late MockUserRepository mockUserRepository;

  setUp(() {
    mockUserRepository = MockUserRepository();
    sut = GetUserUseCase(mockUserRepository);
    registerFallbackValue(const NoParams());
  });

  group('GetUserUseCase', () {
    group('contrato UseCase', () {
      test('es instancia de UseCase<User, NoParams>', () {
        // Assert
        expect(sut, isA<UseCase<User, NoParams>>());
      });
    });

    group('happy path', () {
      test(
        'retorna Right con el usuario cuando el repositorio responde ok',
        () async {
          // Arrange
          when(
            () => mockUserRepository.getUser(),
          ).thenAnswer((_) async => const Right(TestFixtures.tUser));

          // Act
          final result = await sut(const NoParams());

          // Assert
          expect(result, const Right<Failure, User>(TestFixtures.tUser));
        },
      );

      test('llama a getUser() exactamente una vez', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => const Right(TestFixtures.tUser));

        // Act
        await sut(const NoParams());

        // Assert
        verify(() => mockUserRepository.getUser()).called(1);
      });

      test(
        'retorna el usuario con saldo bajo sin tratarlo como error',
        () async {
          // Arrange
          when(
            () => mockUserRepository.getUser(),
          ).thenAnswer(
            (_) async => const Right(TestFixtures.tUserLowBalance),
          );

          // Act
          final result = await sut(const NoParams());

          // Assert
          expect(
            result,
            const Right<Failure, User>(TestFixtures.tUserLowBalance),
          );
        },
      );

      test(
        'retorna el usuario con fondos suscritos correctamente',
        () async {
          // Arrange
          when(
            () => mockUserRepository.getUser(),
          ).thenAnswer(
            (_) async => const Right(TestFixtures.tUserAfterSubscription),
          );

          // Act
          final result = await sut(const NoParams());

          // Assert
          expect(
            result,
            const Right<Failure, User>(TestFixtures.tUserAfterSubscription),
          );
        },
      );
    });

    group('error path', () {
      test('propaga el CacheFailure cuando el repositorio falla', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
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
          () => mockUserRepository.getUser(),
        ).thenAnswer(
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

      test('no llama getUser() más de una vez aunque falle', () async {
        // Arrange
        when(
          () => mockUserRepository.getUser(),
        ).thenAnswer((_) async => const Left(TestFixtures.tCacheFailure));

        // Act
        await sut(const NoParams());

        // Assert
        verify(() => mockUserRepository.getUser()).called(1);
      });
    });
  });
}
