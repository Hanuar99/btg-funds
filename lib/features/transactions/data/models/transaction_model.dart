import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

@freezed
abstract class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    @JsonKey(name: 'fund_id') required String fundId,
    @JsonKey(name: 'fund_name') required String fundName,
    required String type,
    required double amount,
    required String date,
    @JsonKey(name: 'notification_method') String? notificationMethod,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}

extension TransactionModelX on TransactionModel {
  Transaction toEntity() {
    return Transaction(
      id: id,
      fundId: fundId,
      fundName: fundName,
      type: type == 'subscription'
          ? TransactionType.subscription
          : TransactionType.cancellation,
      amount: amount,
      date: DateTime.parse(date),
      notificationMethod: notificationMethod == null
          ? null
          : notificationMethod == 'email'
          ? NotificationMethod.email
          : NotificationMethod.sms,
    );
  }
}

extension TransactionX on Transaction {
  TransactionModel toModel() {
    return TransactionModel(
      id: id,
      fundId: fundId,
      fundName: fundName,
      type: type == TransactionType.subscription
          ? 'subscription'
          : 'cancellation',
      amount: amount,
      date: date.toIso8601String(),
      notificationMethod: notificationMethod?.name,
    );
  }
}
