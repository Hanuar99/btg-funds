import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'funds_state.freezed.dart';

@freezed
class FundsState with _$FundsState {
  const factory FundsState.initial() = _Initial;

  const factory FundsState.loading() = _Loading;

  const factory FundsState.loaded({required List<Fund> funds}) = _Loaded;

  const factory FundsState.subscribing({
    required List<Fund> funds,
    required String processingFundId,
  }) = _Subscribing;

  const factory FundsState.subscribeSuccess({
    required List<Fund> funds,
    required Fund subscribedFund,
  }) = _SubscribeSuccess;

  const factory FundsState.cancelSuccess({
    required List<Fund> funds,
    required Fund cancelledFund,
  }) = _CancelSuccess;

  const factory FundsState.failure({
    required List<Fund> funds,
    required String message,
  }) = _Failure;
}
