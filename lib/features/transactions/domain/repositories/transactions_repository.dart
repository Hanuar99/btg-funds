import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:dartz/dartz.dart';

abstract class TransactionsRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions();

  Future<Either<Failure, Transaction>> addTransaction(
    Transaction transaction,
  );
}
