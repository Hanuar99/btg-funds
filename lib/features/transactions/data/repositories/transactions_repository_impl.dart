import 'package:btg_funds_manager/core/errors/error_handler.dart';
import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/logger/app_logger.dart';
import 'package:btg_funds_manager/core/network/network_info.dart';
import 'package:btg_funds_manager/features/transactions/data/datasources/transactions_local_datasource.dart';
import 'package:btg_funds_manager/features/transactions/data/models/transaction_model.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TransactionsRepository)
class TransactionsRepositoryImpl implements TransactionsRepository {
  const TransactionsRepositoryImpl(this._datasource, this._networkInfo);
  final TransactionsLocalDatasource _datasource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions() async {
    if (!await _networkInfo.hasInternetConnection) {
      return const Left(NetworkFailure());
    }

    try {
      final models = await _datasource.getTransactions();
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } on BusinessException catch (e) {
      return Left(UnexpectedFailure(e.message));
    } on Object catch (e, stackTrace) {
      AppLogger.error(
        'Error obteniendo historial de transacciones',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ErrorHandler.handle(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Transaction>> addTransaction(
    Transaction transaction,
  ) async {
    if (!await _networkInfo.hasInternetConnection) {
      return const Left(NetworkFailure());
    }

    try {
      final model = transaction.toModel();
      final savedModel = await _datasource.addTransaction(model);
      return Right(savedModel.toEntity());
    } on BusinessException catch (e) {
      return Left(UnexpectedFailure(e.message));
    } on Object catch (e, stackTrace) {
      AppLogger.error(
        'Error registrando transacción',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ErrorHandler.handle(e, stackTrace));
    }
  }
}
