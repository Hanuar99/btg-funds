import 'package:bloc_test/bloc_test.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helpers.dart';

class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsUseCase {}

void main() {
  late TransactionsBloc sut;
  late MockGetTransactionsUseCase mockGetTransactions;

  // ─── Fixtures ──────────────────────────────────────────────────────────────

  // tTransactionSubscription: date = DateTime(2024, 1, 15) — más antigua
  // tTransactionCancellation: date = DateTime(2024, 1, 20) — más reciente
  final tTransactionNewer = TestFixtures.tTransactionCancellation;
  final tTransactionOlder = TestFixtures.tTransactionSubscription;

  final tUnsortedTransactions = [tTransactionOlder, tTransactionNewer];
  final tSortedTransactions = [tTransactionNewer, tTransactionOlder];

  setUpAll(() {
    registerFallbackValue(const NoParams());
  });

  setUp(() {
    mockGetTransactions = MockGetTransactionsUseCase();
    sut = TransactionsBloc(mockGetTransactions);
  });

  tearDown(() => sut.close());

  // ─── Estado inicial ────────────────────────────────────────────────────────

  test('el estado inicial debe ser TransactionsState.initial()', () {
    expect(sut.state, const TransactionsState.initial());
  });

  // ─── TransactionsEvent.started ────────────────────────────────────────────

  group('TransactionsEvent.started', () {
    blocTest<TransactionsBloc, TransactionsState>(
      'emite [loading, loaded] con transacciones ordenadas por fecha descendente',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer((_) async => Right(tUnsortedTransactions));
        return sut;
      },
      act: (bloc) => bloc.add(const TransactionsEvent.started()),
      expect: () => [
        const TransactionsState.loading(),
        TransactionsState.loaded(transactions: tSortedTransactions),
      ],
      verify: (_) {
        verify(() => mockGetTransactions(const NoParams())).called(1);
      },
    );

    blocTest<TransactionsBloc, TransactionsState>(
      'emite [loading, loaded] con lista vacía cuando no hay transacciones',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer((_) async => const Right([]));
        return sut;
      },
      act: (bloc) => bloc.add(const TransactionsEvent.started()),
      expect: () => [
        const TransactionsState.loading(),
        const TransactionsState.loaded(transactions: []),
      ],
    );

    blocTest<TransactionsBloc, TransactionsState>(
      'emite [loading, failure] cuando el use case retorna CacheFailure',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer(
          (_) async => const Left(CacheFailure('Error al leer el historial')),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const TransactionsEvent.started()),
      expect: () => [
        const TransactionsState.loading(),
        const TransactionsState.failure(
          message: 'Error al leer el historial',
        ),
      ],
    );

    blocTest<TransactionsBloc, TransactionsState>(
      'emite [loading, failure] cuando el use case retorna UnexpectedFailure',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer(
          (_) async =>
              const Left(UnexpectedFailure('Error inesperado en el sistema')),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const TransactionsEvent.started()),
      expect: () => [
        const TransactionsState.loading(),
        const TransactionsState.failure(
          message: 'Error inesperado en el sistema',
        ),
      ],
    );

    blocTest<TransactionsBloc, TransactionsState>(
      'llama al use case exactamente una vez con NoParams',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer((_) async => Right(tSortedTransactions));
        return sut;
      },
      act: (bloc) => bloc.add(const TransactionsEvent.started()),
      verify: (_) {
        verify(() => mockGetTransactions(const NoParams())).called(1);
        verifyNoMoreInteractions(mockGetTransactions);
      },
    );
  });

  // ─── TransactionsEvent.refreshRequested ───────────────────────────────────

  group('TransactionsEvent.refreshRequested', () {
    blocTest<TransactionsBloc, TransactionsState>(
      'emite [loading, loaded] con transacciones ordenadas tras pull-to-refresh',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer((_) async => Right(tUnsortedTransactions));
        return sut;
      },
      seed: () => TransactionsState.loaded(transactions: tSortedTransactions),
      act: (bloc) => bloc.add(const TransactionsEvent.refreshRequested()),
      expect: () => [
        const TransactionsState.loading(),
        TransactionsState.loaded(transactions: tSortedTransactions),
      ],
      verify: (_) {
        verify(() => mockGetTransactions(const NoParams())).called(1);
      },
    );

    blocTest<TransactionsBloc, TransactionsState>(
      'emite [loading, failure] cuando el refresh falla',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer(
          (_) async => const Left(NetworkFailure()),
        );
        return sut;
      },
      seed: () => TransactionsState.loaded(transactions: tSortedTransactions),
      act: (bloc) => bloc.add(const TransactionsEvent.refreshRequested()),
      expect: () => [
        const TransactionsState.loading(),
        const TransactionsState.failure(
          message:
              'Sin conexion a internet. Revise su red e intente nuevamente.',
        ),
      ],
    );

    blocTest<TransactionsBloc, TransactionsState>(
      'puede volver a cargar correctamente después de un failure previo',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer((_) async => Right(tSortedTransactions));
        return sut;
      },
      seed: () => const TransactionsState.failure(message: 'Error previo'),
      act: (bloc) => bloc.add(const TransactionsEvent.refreshRequested()),
      expect: () => [
        const TransactionsState.loading(),
        TransactionsState.loaded(transactions: tSortedTransactions),
      ],
    );
  });

  // ─── Ordenamiento de transacciones ────────────────────────────────────────

  group('Ordenamiento por fecha descendente', () {
    blocTest<TransactionsBloc, TransactionsState>(
      'ordena correctamente cuando llegan desordenadas del use case',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer(
          (_) async => Right([tTransactionOlder, tTransactionNewer]),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const TransactionsEvent.started()),
      expect: () => [
        const TransactionsState.loading(),
        TransactionsState.loaded(
          transactions: [tTransactionNewer, tTransactionOlder],
        ),
      ],
    );

    blocTest<TransactionsBloc, TransactionsState>(
      'mantiene el orden si ya llegan en orden descendente',
      build: () {
        when(
          () => mockGetTransactions(any()),
        ).thenAnswer(
          (_) async => Right([tTransactionNewer, tTransactionOlder]),
        );
        return sut;
      },
      act: (bloc) => bloc.add(const TransactionsEvent.started()),
      expect: () => [
        const TransactionsState.loading(),
        TransactionsState.loaded(
          transactions: [tTransactionNewer, tTransactionOlder],
        ),
      ],
    );
  });
}
