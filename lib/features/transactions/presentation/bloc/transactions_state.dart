import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transactions_state.freezed.dart';

@freezed
class TransactionsState with _$TransactionsState {
  const factory TransactionsState.initial() = _Initial;

  const factory TransactionsState.loading() = _Loading;

  const factory TransactionsState.loaded({
    required List<Transaction> transactions,
  }) = _Loaded;

  const factory TransactionsState.failure({required String message}) = _Failure;
}
