import 'package:bloc/bloc.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/user/domain/usecases/get_user_usecase.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_event.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._getUserUseCase) : super(const UserState.initial()) {
    on<UserEvent>(_onEvent);
  }

  final GetUserUseCase _getUserUseCase;

  Future<void> _onEvent(UserEvent event, Emitter<UserState> emit) {
    return event.map(
      started: (_) => _onStarted(emit),
      refreshRequested: (_) => _onRefreshRequested(emit),
    );
  }

  Future<void> _onStarted(Emitter<UserState> emit) async {
    emit(const UserState.loading());
    await _fetchUser(emit);
  }

  Future<void> _onRefreshRequested(Emitter<UserState> emit) => _fetchUser(emit);

  Future<void> _fetchUser(Emitter<UserState> emit) async {
    final result = await _getUserUseCase(const NoParams());
    result.fold(
      (failure) => emit(UserState.failure(message: failure.message)),
      (user) => emit(UserState.loaded(user: user)),
    );
  }
}
