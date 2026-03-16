import 'package:bloc_test/bloc_test.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/user/domain/usecases/get_user_usecase.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_event.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helpers.dart';

class MockGetUserUseCase extends Mock implements GetUserUseCase {}

void main() {
  late UserBloc sut;
  late MockGetUserUseCase mockGetUserUseCase;

  setUp(() {
    mockGetUserUseCase = MockGetUserUseCase();
    sut = UserBloc(mockGetUserUseCase);
    registerFallbackValue(const NoParams());
  });

  tearDown(() => sut.close());

  // ─── Estado inicial ────────────────────────────────────────────────────────

  test('el estado inicial debe ser UserState.initial()', () {
    expect(sut.state, const UserState.initial());
  });

  // ─── UserEvent.started ────────────────────────────────────────────────────

  group('UserEvent.started', () {
    blocTest<UserBloc, UserState>(
      'emite [loading, loaded] cuando getUser retorna el usuario correctamente',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer((_) async => const Right(TestFixtures.tUser));
        return sut;
      },
      act: (bloc) => bloc.add(const UserEvent.started()),
      expect: () => [
        const UserState.loading(),
        const UserState.loaded(user: TestFixtures.tUser),
      ],
      verify: (_) {
        verify(() => mockGetUserUseCase(const NoParams())).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emite [loading, loaded] con usuario con saldo bajo',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer(
          (_) async => const Right(TestFixtures.tUserLowBalance),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const UserEvent.started()),
      expect: () => [
        const UserState.loading(),
        const UserState.loaded(user: TestFixtures.tUserLowBalance),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emite [loading, loaded] con usuario con fondos suscritos',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer(
          (_) async => const Right(TestFixtures.tUserAfterSubscription),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const UserEvent.started()),
      expect: () => [
        const UserState.loading(),
        const UserState.loaded(user: TestFixtures.tUserAfterSubscription),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emite [loading, failure] cuando getUser retorna CacheFailure',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer(
          (_) async => const Left(
            CacheFailure('Error al leer del almacenamiento local'),
          ),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const UserEvent.started()),
      expect: () => [
        const UserState.loading(),
        const UserState.failure(
          message: 'Error al leer del almacenamiento local',
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emite [loading, failure] cuando getUser retorna UnexpectedFailure',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer(
          (_) async =>
              const Left(UnexpectedFailure('Error inesperado en el sistema')),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const UserEvent.started()),
      expect: () => [
        const UserState.loading(),
        const UserState.failure(message: 'Error inesperado en el sistema'),
      ],
    );

    blocTest<UserBloc, UserState>(
      'llama a getUser exactamente una vez',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer((_) async => const Right(TestFixtures.tUser));
        return sut;
      },
      act: (bloc) => bloc.add(const UserEvent.started()),
      verify: (_) {
        verify(() => mockGetUserUseCase(const NoParams())).called(1);
        verifyNoMoreInteractions(mockGetUserUseCase);
      },
    );
  });

  // ─── UserEvent.refreshRequested ───────────────────────────────────────────

  group('UserEvent.refreshRequested', () {
    blocTest<UserBloc, UserState>(
      'emite [loaded] sin loading cuando el refresh es exitoso',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer((_) async => const Right(TestFixtures.tUser));
        return sut;
      },
      seed: () => const UserState.loaded(user: TestFixtures.tUserLowBalance),
      act: (bloc) => bloc.add(const UserEvent.refreshRequested()),
      expect: () => [
        const UserState.loaded(user: TestFixtures.tUser),
      ],
      verify: (_) {
        verify(() => mockGetUserUseCase(const NoParams())).called(1);
      },
    );

    blocTest<UserBloc, UserState>(
      'emite [failure] sin loading cuando el refresh falla',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer(
          (_) async => const Left(
            CacheFailure('Error al leer del almacenamiento local'),
          ),
        );
        return sut;
      },
      seed: () => const UserState.loaded(user: TestFixtures.tUser),
      act: (bloc) => bloc.add(const UserEvent.refreshRequested()),
      expect: () => [
        const UserState.failure(
          message: 'Error al leer del almacenamiento local',
        ),
      ],
    );

    blocTest<UserBloc, UserState>(
      'NO emite estado loading durante el refresh',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer((_) async => const Right(TestFixtures.tUser));
        return sut;
      },
      seed: () => const UserState.loaded(user: TestFixtures.tUserLowBalance),
      act: (bloc) => bloc.add(const UserEvent.refreshRequested()),
      expect: () => isNot(contains(const UserState.loading())),
    );

    blocTest<UserBloc, UserState>(
      'puede recuperarse de un failure previo con refresh exitoso',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer((_) async => const Right(TestFixtures.tUser));
        return sut;
      },
      seed: () => const UserState.failure(message: 'Error previo'),
      act: (bloc) => bloc.add(const UserEvent.refreshRequested()),
      expect: () => [
        const UserState.loaded(user: TestFixtures.tUser),
      ],
    );

    blocTest<UserBloc, UserState>(
      'emite [loaded] con datos actualizados cuando el balance cambia',
      build: () {
        when(
          () => mockGetUserUseCase(const NoParams()),
        ).thenAnswer(
          (_) async => const Right(TestFixtures.tUserAfterSubscription),
        );
        return sut;
      },
      seed: () => const UserState.loaded(user: TestFixtures.tUser),
      act: (bloc) => bloc.add(const UserEvent.refreshRequested()),
      expect: () => [
        const UserState.loaded(user: TestFixtures.tUserAfterSubscription),
      ],
    );
  });
}
