import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'funds_event.freezed.dart';

@freezed
class FundsEvent with _$FundsEvent {
  const factory FundsEvent.started() = _Started;

  const factory FundsEvent.subscribeRequested({
    required Fund fund,
    required double amount,
    required NotificationMethod notificationMethod,
  }) = _SubscribeRequested;

  const factory FundsEvent.cancelRequested({required Fund fund}) =
      _CancelRequested;
}
