import 'package:freezed_annotation/freezed_annotation.dart';

part 'transactions_event.freezed.dart';

@freezed
class TransactionsEvent with _$TransactionsEvent {
  const factory TransactionsEvent.started() = _Started;

  const factory TransactionsEvent.refreshRequested() = _RefreshRequested;
}
