import 'package:bloc_test/bloc_test.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/cancel_fund_usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/get_funds_usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/subscribe_fund_usecase.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_bloc.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_event.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_state.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helpers.dart';

class MockGetFundsUseCase extends Mock implements GetFundsUseCase {}

class MockSubscribeFundUseCase extends Mock implements SubscribeFundUseCase {}

class MockCancelFundUseCase extends Mock implements CancelFundUseCase {}

void main() {
  late FundsBloc sut;
  late MockGetFundsUseCase mockGetFunds;
  late MockSubscribeFundUseCase mockSubscribe;
  late MockCancelFundUseCase mockCancel;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(
      const SubscribeFundParams(
        fundId: '1',
        amount: 75000,
        notificationMethod: NotificationMethod.email,
        fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
      ),
    );
    registerFallbackValue(const CancelFundParams(fundId: '1'));
  });

  setUp(() {
    mockGetFunds = MockGetFundsUseCase();
    mockSubscribe = MockSubscribeFundUseCase();
    mockCancel = MockCancelFundUseCase();
    sut = FundsBloc(mockGetFunds, mockSubscribe, mockCancel);
  });

  tearDown(() => sut.close());

  test('estado inicial debe ser FundsState.initial()', () {
    expect(sut.state, const FundsState.initial());
  });

  group('FundsEvent.started', () {
    blocTest<FundsBloc, FundsState>(
      'emite [loading, loaded] cuando getFunds retorna fondos',
      build: () {
        when(
          () => mockGetFunds(any()),
        ).thenAnswer((_) async => const Right([TestFixtures.tFund1]));
        return sut;
      },
      act: (bloc) => bloc.add(const FundsEvent.started()),
      expect: () => [
        const FundsState.loading(),
        const FundsState.loaded(funds: [TestFixtures.tFund1]),
      ],
      verify: (_) {
        verify(() => mockGetFunds(const NoParams())).called(1);
      },
    );

    blocTest<FundsBloc, FundsState>(
      'emite [loading, loaded] con la lista completa de fondos',
      build: () {
        when(
          () => mockGetFunds(any()),
        ).thenAnswer(
          (_) async => const Right(TestFixtures.tAllFunds),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const FundsEvent.started()),
      expect: () => [
        const FundsState.loading(),
        const FundsState.loaded(funds: TestFixtures.tAllFunds),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [loading, loaded] con lista vacía cuando no hay fondos',
      build: () {
        when(
          () => mockGetFunds(any()),
        ).thenAnswer((_) async => const Right([]));
        return sut;
      },
      act: (bloc) => bloc.add(const FundsEvent.started()),
      expect: () => [
        const FundsState.loading(),
        const FundsState.loaded(funds: []),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [loading, failure] cuando getFunds retorna CacheFailure',
      build: () {
        when(
          () => mockGetFunds(any()),
        ).thenAnswer((_) async => const Left(CacheFailure('Sin conexion')));
        return sut;
      },
      act: (bloc) => bloc.add(const FundsEvent.started()),
      expect: () => [
        const FundsState.loading(),
        const FundsState.failure(funds: [], message: 'Sin conexion'),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [loading, failure] con funds vacío cuando retorna NetworkFailure',
      build: () {
        when(
          () => mockGetFunds(any()),
        ).thenAnswer((_) async => const Left(NetworkFailure()));
        return sut;
      },
      act: (bloc) => bloc.add(const FundsEvent.started()),
      expect: () => [
        const FundsState.loading(),
        const FundsState.failure(
          funds: [],
          message:
              'Sin conexion a internet. Revise su red e intente nuevamente.',
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'llama al use case exactamente una vez con NoParams',
      build: () {
        when(
          () => mockGetFunds(any()),
        ).thenAnswer((_) async => const Right(TestFixtures.tAllFunds));
        return sut;
      },
      act: (bloc) => bloc.add(const FundsEvent.started()),
      verify: (_) {
        verify(() => mockGetFunds(const NoParams())).called(1);
        verifyNoMoreInteractions(mockGetFunds);
      },
    );
  });

  group('FundsEvent.subscribeRequested', () {
    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, subscribeSuccess] cuando la suscripcion es exitosa',
      build: () {
        when(
          () => mockSubscribe(any()),
        ).thenAnswer((_) async => Right(TestFixtures.tFundSubscribed));
        return sut;
      },
      seed: () => const FundsState.loaded(funds: [TestFixtures.tFund1]),
      act: (bloc) => bloc.add(
        const FundsEvent.subscribeRequested(
          fund: TestFixtures.tFund1,
          amount: 75000,
          notificationMethod: NotificationMethod.email,
        ),
      ),
      expect: () => [
        const FundsState.subscribing(
          funds: [TestFixtures.tFund1],
          processingFundId: '1',
        ),
        FundsState.subscribeSuccess(
          funds: [TestFixtures.tFundSubscribed],
          subscribedFund: TestFixtures.tFundSubscribed,
        ),
      ],
      verify: (_) {
        verify(() => mockSubscribe(any())).called(1);
      },
    );

    blocTest<FundsBloc, FundsState>(
      'actualiza solo el fondo suscrito manteniendo el resto sin cambios',
      build: () {
        when(
          () => mockSubscribe(any()),
        ).thenAnswer((_) async => Right(TestFixtures.tFundSubscribed));
        return sut;
      },
      seed: () => const FundsState.loaded(funds: TestFixtures.tAllFunds),
      act: (bloc) => bloc.add(
        const FundsEvent.subscribeRequested(
          fund: TestFixtures.tFund1,
          amount: 75000,
          notificationMethod: NotificationMethod.email,
        ),
      ),
      expect: () => [
        const FundsState.subscribing(
          funds: TestFixtures.tAllFunds,
          processingFundId: '1',
        ),
        FundsState.subscribeSuccess(
          funds: [
            TestFixtures.tFundSubscribed,
            TestFixtures.tFund2,
            TestFixtures.tFund3,
            TestFixtures.tFund4,
            TestFixtures.tFund5,
          ],
          subscribedFund: TestFixtures.tFundSubscribed,
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando el saldo es insuficiente',
      build: () {
        when(() => mockSubscribe(any())).thenAnswer(
          (_) async => const Left(
            InsufficientBalanceFailure(
              'No tiene saldo disponible para vincularse al fondo 1',
            ),
          ),
        );
        return sut;
      },
      seed: () => const FundsState.loaded(funds: [TestFixtures.tFund1]),
      act: (bloc) => bloc.add(
        const FundsEvent.subscribeRequested(
          fund: TestFixtures.tFund1,
          amount: 75000,
          notificationMethod: NotificationMethod.email,
        ),
      ),
      expect: () => [
        const FundsState.subscribing(
          funds: [TestFixtures.tFund1],
          processingFundId: '1',
        ),
        const FundsState.failure(
          funds: [TestFixtures.tFund1],
          message: 'No tiene saldo disponible para vincularse al fondo 1',
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando retorna AlreadySubscribedFailure',
      build: () {
        when(() => mockSubscribe(any())).thenAnswer(
          (_) async => const Left(
            AlreadySubscribedFailure(
              'Ya está suscrito al fondo FPV_BTG_PACTUAL_RECAUDADORA',
            ),
          ),
        );
        return sut;
      },
      seed: () => FundsState.loaded(funds: [TestFixtures.tFundSubscribed]),
      act: (bloc) => bloc.add(
        const FundsEvent.subscribeRequested(
          fund: TestFixtures.tFund1,
          amount: 75000,
          notificationMethod: NotificationMethod.email,
        ),
      ),
      expect: () => [
        FundsState.subscribing(
          funds: [TestFixtures.tFundSubscribed],
          processingFundId: '1',
        ),
        FundsState.failure(
          funds: [TestFixtures.tFundSubscribed],
          message: 'Ya está suscrito al fondo FPV_BTG_PACTUAL_RECAUDADORA',
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'preserva la lista de fondos actual en el estado failure',
      build: () {
        when(() => mockSubscribe(any())).thenAnswer(
          (_) async => const Left(UnexpectedFailure('Error inesperado')),
        );
        return sut;
      },
      seed: () => const FundsState.loaded(funds: TestFixtures.tAllFunds),
      act: (bloc) => bloc.add(
        const FundsEvent.subscribeRequested(
          fund: TestFixtures.tFund1,
          amount: 75000,
          notificationMethod: NotificationMethod.email,
        ),
      ),
      expect: () => [
        const FundsState.subscribing(
          funds: TestFixtures.tAllFunds,
          processingFundId: '1',
        ),
        const FundsState.failure(
          funds: TestFixtures.tAllFunds,
          message: 'Error inesperado',
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando retorna FundNotFoundFailure',
      build: () {
        when(() => mockSubscribe(any())).thenAnswer(
          (_) async => const Left(FundNotFoundFailure('Fondo 1 no encontrado')),
        );
        return sut;
      },
      seed: () => const FundsState.loaded(funds: [TestFixtures.tFund1]),
      act: (bloc) => bloc.add(
        const FundsEvent.subscribeRequested(
          fund: TestFixtures.tFund1,
          amount: 75000,
          notificationMethod: NotificationMethod.email,
        ),
      ),
      expect: () => [
        const FundsState.subscribing(
          funds: [TestFixtures.tFund1],
          processingFundId: '1',
        ),
        const FundsState.failure(
          funds: [TestFixtures.tFund1],
          message: 'Fondo 1 no encontrado',
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando retorna NetworkFailure',
      build: () {
        when(() => mockSubscribe(any())).thenAnswer(
          (_) async => const Left(NetworkFailure()),
        );
        return sut;
      },
      seed: () => const FundsState.loaded(funds: [TestFixtures.tFund1]),
      act: (bloc) => bloc.add(
        const FundsEvent.subscribeRequested(
          fund: TestFixtures.tFund1,
          amount: 75000,
          notificationMethod: NotificationMethod.email,
        ),
      ),
      expect: () => [
        const FundsState.subscribing(
          funds: [TestFixtures.tFund1],
          processingFundId: '1',
        ),
        FundsState.failure(
          funds: const [TestFixtures.tFund1],
          message: const NetworkFailure().message,
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando retorna CacheFailure al suscribir',
      build: () {
        when(() => mockSubscribe(any())).thenAnswer(
          (_) async =>
              const Left(CacheFailure('Error al guardar la suscripcion')),
        );
        return sut;
      },
      seed: () => const FundsState.loaded(funds: [TestFixtures.tFund1]),
      act: (bloc) => bloc.add(
        const FundsEvent.subscribeRequested(
          fund: TestFixtures.tFund1,
          amount: 75000,
          notificationMethod: NotificationMethod.email,
        ),
      ),
      expect: () => [
        const FundsState.subscribing(
          funds: [TestFixtures.tFund1],
          processingFundId: '1',
        ),
        const FundsState.failure(
          funds: [TestFixtures.tFund1],
          message: 'Error al guardar la suscripcion',
        ),
      ],
    );
  });

  group('FundsEvent.cancelRequested', () {
    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, cancelSuccess] cuando la cancelacion es exitosa',
      build: () {
        when(
          () => mockCancel(any()),
        ).thenAnswer((_) async => const Right(TestFixtures.tFund1));
        return sut;
      },
      seed: () => FundsState.loaded(funds: [TestFixtures.tFundSubscribed]),
      act: (bloc) => bloc.add(
        FundsEvent.cancelRequested(fund: TestFixtures.tFundSubscribed),
      ),
      expect: () => [
        FundsState.subscribing(
          funds: [TestFixtures.tFundSubscribed],
          processingFundId: '1',
        ),
        const FundsState.cancelSuccess(
          funds: [TestFixtures.tFund1],
          cancelledFund: TestFixtures.tFund1,
        ),
      ],
      verify: (_) {
        verify(() => mockCancel(any())).called(1);
      },
    );

    blocTest<FundsBloc, FundsState>(
      'actualiza solo el fondo cancelado manteniendo el resto de fondos',
      build: () {
        when(
          () => mockCancel(any()),
        ).thenAnswer((_) async => const Right(TestFixtures.tFund1));
        return sut;
      },
      seed: () => FundsState.loaded(
        funds: [
          TestFixtures.tFundSubscribed,
          TestFixtures.tFund2,
          TestFixtures.tFund3,
        ],
      ),
      act: (bloc) => bloc.add(
        FundsEvent.cancelRequested(fund: TestFixtures.tFundSubscribed),
      ),
      expect: () => [
        FundsState.subscribing(
          funds: [
            TestFixtures.tFundSubscribed,
            TestFixtures.tFund2,
            TestFixtures.tFund3,
          ],
          processingFundId: '1',
        ),
        const FundsState.cancelSuccess(
          funds: [
            TestFixtures.tFund1,
            TestFixtures.tFund2,
            TestFixtures.tFund3,
          ],
          cancelledFund: TestFixtures.tFund1,
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando la cancelacion falla por NotSubscribed',
      build: () {
        when(
          () => mockCancel(any()),
        ).thenAnswer(
          (_) async => const Left(
            NotSubscribedFailure('No está suscrito al fondo 1'),
          ),
        );
        return sut;
      },
      seed: () => FundsState.loaded(funds: [TestFixtures.tFundSubscribed]),
      act: (bloc) => bloc.add(
        FundsEvent.cancelRequested(fund: TestFixtures.tFundSubscribed),
      ),
      expect: () => [
        FundsState.subscribing(
          funds: [TestFixtures.tFundSubscribed],
          processingFundId: '1',
        ),
        FundsState.failure(
          funds: [TestFixtures.tFundSubscribed],
          message: 'No está suscrito al fondo 1',
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando la cancelacion falla por CacheFailure',
      build: () {
        when(
          () => mockCancel(any()),
        ).thenAnswer(
          (_) async =>
              const Left(CacheFailure('Error al guardar la cancelacion')),
        );
        return sut;
      },
      seed: () => FundsState.loaded(funds: [TestFixtures.tFundSubscribed]),
      act: (bloc) => bloc.add(
        FundsEvent.cancelRequested(fund: TestFixtures.tFundSubscribed),
      ),
      expect: () => [
        FundsState.subscribing(
          funds: [TestFixtures.tFundSubscribed],
          processingFundId: '1',
        ),
        FundsState.failure(
          funds: [TestFixtures.tFundSubscribed],
          message: 'Error al guardar la cancelacion',
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando la cancelacion falla por FundNotFoundFailure',
      build: () {
        when(
          () => mockCancel(any()),
        ).thenAnswer(
          (_) async => const Left(FundNotFoundFailure('Fondo 1 no encontrado')),
        );
        return sut;
      },
      seed: () => FundsState.loaded(funds: [TestFixtures.tFundSubscribed]),
      act: (bloc) => bloc.add(
        FundsEvent.cancelRequested(fund: TestFixtures.tFundSubscribed),
      ),
      expect: () => [
        FundsState.subscribing(
          funds: [TestFixtures.tFundSubscribed],
          processingFundId: '1',
        ),
        FundsState.failure(
          funds: [TestFixtures.tFundSubscribed],
          message: 'Fondo 1 no encontrado',
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando la cancelacion falla por NetworkFailure',
      build: () {
        when(
          () => mockCancel(any()),
        ).thenAnswer(
          (_) async => const Left(NetworkFailure()),
        );
        return sut;
      },
      seed: () => FundsState.loaded(funds: [TestFixtures.tFundSubscribed]),
      act: (bloc) => bloc.add(
        FundsEvent.cancelRequested(fund: TestFixtures.tFundSubscribed),
      ),
      expect: () => [
        FundsState.subscribing(
          funds: [TestFixtures.tFundSubscribed],
          processingFundId: '1',
        ),
        FundsState.failure(
          funds: [TestFixtures.tFundSubscribed],
          message: const NetworkFailure().message,
        ),
      ],
    );

    blocTest<FundsBloc, FundsState>(
      'emite [subscribing, failure] cuando la cancelacion falla por UnexpectedFailure',
      build: () {
        when(
          () => mockCancel(any()),
        ).thenAnswer(
          (_) async =>
              const Left(UnexpectedFailure('Error inesperado en cancelacion')),
        );
        return sut;
      },
      seed: () => FundsState.loaded(funds: [TestFixtures.tFundSubscribed]),
      act: (bloc) => bloc.add(
        FundsEvent.cancelRequested(fund: TestFixtures.tFundSubscribed),
      ),
      expect: () => [
        FundsState.subscribing(
          funds: [TestFixtures.tFundSubscribed],
          processingFundId: '1',
        ),
        FundsState.failure(
          funds: [TestFixtures.tFundSubscribed],
          message: 'Error inesperado en cancelacion',
        ),
      ],
    );
  });
}
