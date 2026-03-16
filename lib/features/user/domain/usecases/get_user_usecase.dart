import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:btg_funds_manager/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetUserUseCase implements UseCase<User, NoParams> {
  const GetUserUseCase(this._repository);

  final UserRepository _repository;

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return _repository.getUser();
  }
}
