import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_state.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState.initial() = _Initial;

  const factory UserState.loading() = _Loading;

  const factory UserState.loaded({required User user}) = _Loaded;

  const factory UserState.failure({required String message}) = _Failure;
}
