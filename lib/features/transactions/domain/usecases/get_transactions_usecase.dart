import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class GetTransactionsUseCase implements UseCase<List<Transaction>, NoParams> {
  const GetTransactionsUseCase(this._repository);
  final TransactionsRepository _repository;

  @override
  Future<Either<Failure, List<Transaction>>> call(NoParams params) {
    return _repository.getTransactions();
  }
}
