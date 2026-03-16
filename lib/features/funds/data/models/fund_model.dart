import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'fund_model.freezed.dart';
part 'fund_model.g.dart';

/// DTO de la capa Data - NUNCA pasar al Domain directamente, usar toEntity().
@freezed
abstract class FundModel with _$FundModel {
  const factory FundModel({
    required String id,
    required String name,
    @JsonKey(name: 'minimum_amount') required double minimumAmount,
    required String category,
    @JsonKey(name: 'is_subscribed') @Default(false) bool isSubscribed,
    @JsonKey(name: 'subscribed_amount') @Default(0.0) double subscribedAmount,
  }) = _FundModel;

  factory FundModel.fromJson(Map<String, dynamic> json) =>
      _$FundModelFromJson(json);
}

extension FundModelX on FundModel {
  Fund toEntity() {
    return Fund(
      id: id,
      name: name,
      minimumAmount: minimumAmount,
      category: category == 'FPV' ? FundCategory.fpv : FundCategory.fic,
      isSubscribed: isSubscribed,
      subscribedAmount: subscribedAmount,
    );
  }
}
