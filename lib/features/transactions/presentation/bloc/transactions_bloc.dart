import 'package:bloc/bloc.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  TransactionsBloc(this._getTransactionsUseCase)
    : super(const TransactionsState.initial()) {
    on<TransactionsEvent>(_onEvent);
  }
  final GetTransactionsUseCase _getTransactionsUseCase;

  Future<void> _onEvent(
    TransactionsEvent event,
    Emitter<TransactionsState> emit,
  ) {
    return event.map(
      started: (_) => _onStarted(emit),
      refreshRequested: (_) => _onRefreshRequested(emit),
    );
  }

  Future<void> _onStarted(Emitter<TransactionsState> emit) async {
    emit(const TransactionsState.loading());

    final result = await _getTransactionsUseCase(const NoParams());
    result.fold(
      (failure) => emit(TransactionsState.failure(message: failure.message)),
      (transactions) {
        final sorted = [...transactions]
          ..sort((left, right) => right.date.compareTo(left.date));
        emit(TransactionsState.loaded(transactions: sorted));
      },
    );
  }

  Future<void> _onRefreshRequested(Emitter<TransactionsState> emit) async {
    // Emitimos loading para asegurar una transicion de estado durante pull-to-refresh.
    emit(const TransactionsState.loading());
    final result = await _getTransactionsUseCase(const NoParams());
    result.fold(
      (failure) => emit(TransactionsState.failure(message: failure.message)),
      (transactions) {
        final sorted = [...transactions]
          ..sort((left, right) => right.date.compareTo(left.date));
        emit(TransactionsState.loaded(transactions: sorted));
      },
    );
  }
}
