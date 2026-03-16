import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required double balance,
    @JsonKey(name: 'subscribed_funds')
    @Default(<String, double>{})
    Map<String, double> subscribedFunds,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
}

extension UserModelX on UserModel {
  User toEntity() {
    return User(
      id: id,
      balance: balance,
      subscribedFunds: subscribedFunds,
    );
  }
}

extension UserX on User {
  UserModel toModel() {
    return UserModel(
      id: id,
      balance: balance,
      subscribedFunds: subscribedFunds,
    );
  }
}
