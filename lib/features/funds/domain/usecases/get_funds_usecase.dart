import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/domain/repositories/funds_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

/// Caso de uso para obtener la lista de fondos disponibles.
@lazySingleton
class GetFundsUseCase implements UseCase<List<Fund>, NoParams> {
  const GetFundsUseCase(this._repository);
  final FundsRepository _repository;

  @override
  Future<Either<Failure, List<Fund>>> call(NoParams params) {
    return _repository.getFunds();
  }
}
