import 'package:bloc/bloc.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/cancel_fund_usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/get_funds_usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/subscribe_fund_usecase.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_event.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_state.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:injectable/injectable.dart';

@injectable
class FundsBloc extends Bloc<FundsEvent, FundsState> {
  FundsBloc(
    this._getFundsUseCase,
    this._subscribeFundUseCase,
    this._cancelFundUseCase,
  ) : super(const FundsState.initial()) {
    on<FundsEvent>(_onEvent);
  }
  final GetFundsUseCase _getFundsUseCase;
  final SubscribeFundUseCase _subscribeFundUseCase;
  final CancelFundUseCase _cancelFundUseCase;

  Future<void> _onEvent(FundsEvent event, Emitter<FundsState> emit) {
    return event.map(
      started: (_) => _onStarted(emit),
      subscribeRequested: (event) => _onSubscribeRequested(
        fund: event.fund,
        amount: event.amount,
        notificationMethod: event.notificationMethod,
        emit: emit,
      ),
      cancelRequested: (event) =>
          _onCancelRequested(fund: event.fund, emit: emit),
    );
  }

  Future<void> _onStarted(Emitter<FundsState> emit) async {
    emit(const FundsState.loading());

    final result = await _getFundsUseCase(const NoParams());
    result.fold(
      (failure) =>
          emit(FundsState.failure(funds: const [], message: failure.message)),
      (funds) => emit(FundsState.loaded(funds: funds)),
    );
  }

  Future<void> _onSubscribeRequested({
    required Fund fund,
    required double amount,
    required NotificationMethod notificationMethod,
    required Emitter<FundsState> emit,
  }) async {
    final currentFunds = _currentFunds;
    emit(
      FundsState.subscribing(
        funds: currentFunds,
        processingFundId: fund.id,
      ),
    );

    final result = await _subscribeFundUseCase(
      SubscribeFundParams(
        fundId: fund.id,
        fundName: fund.name,
        amount: amount,
        notificationMethod: notificationMethod,
      ),
    );

    result.fold(
      (failure) => emit(
        FundsState.failure(funds: currentFunds, message: failure.message),
      ),
      (subscribedFund) {
        final updatedFunds = _updateFundInList(currentFunds, subscribedFund);
        emit(
          FundsState.subscribeSuccess(
            funds: updatedFunds,
            subscribedFund: subscribedFund,
          ),
        );
      },
    );
  }

  Future<void> _onCancelRequested({
    required Fund fund,
    required Emitter<FundsState> emit,
  }) async {
    final currentFunds = _currentFunds;
    emit(
      FundsState.subscribing(
        funds: currentFunds,
        processingFundId: fund.id,
      ),
    );

    final result = await _cancelFundUseCase(
      CancelFundParams(fundId: fund.id),
    );

    result.fold(
      (failure) => emit(
        FundsState.failure(funds: currentFunds, message: failure.message),
      ),
      (cancelledFund) {
        final updatedFunds = _updateFundInList(currentFunds, cancelledFund);
        emit(
          FundsState.cancelSuccess(
            funds: updatedFunds,
            cancelledFund: cancelledFund,
          ),
        );
      },
    );
  }

  List<Fund> get _currentFunds {
    return state.maybeMap(
      loaded: (state) => state.funds,
      subscribing: (state) => state.funds,
      subscribeSuccess: (state) => state.funds,
      cancelSuccess: (state) => state.funds,
      failure: (state) => state.funds,
      orElse: () => const <Fund>[],
    );
  }

  List<Fund> _updateFundInList(List<Fund> funds, Fund updated) {
    return funds
        .map((fund) => fund.id == updated.id ? updated : fund)
        .toList(growable: false);
  }
}
