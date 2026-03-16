import 'package:btg_funds_manager/core/errors/error_handler.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/logger/app_logger.dart';
import 'package:btg_funds_manager/core/network/network_info.dart';
import 'package:btg_funds_manager/features/user/data/datasources/user_local_datasource.dart';
import 'package:btg_funds_manager/features/user/data/models/user_model.dart';
import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:btg_funds_manager/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._datasource, this._networkInfo);
  final UserLocalDatasource _datasource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, User>> getUser() async {
    if (!await _networkInfo.hasInternetConnection) {
      return const Left(NetworkFailure());
    }

    try {
      final model = await _datasource.getUser();
      return Right(model.toEntity());
    } on Object catch (e, stack) {
      AppLogger.error(
        'UserRepository.getUser error',
        error: e,
        stackTrace: stack,
      );
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, User>> updateBalance(double newBalance) async {
    if (!await _networkInfo.hasInternetConnection) {
      return const Left(NetworkFailure());
    }

    try {
      final currentModel = await _datasource.getUser();
      final updated = currentModel.copyWith(balance: newBalance);
      final result = await _datasource.updateUser(updated);
      AppLogger.info('Saldo actualizado: COP ${newBalance.toStringAsFixed(0)}');
      return Right(result.toEntity());
    } on Object catch (e, stack) {
      AppLogger.error(
        'UserRepository.updateBalance error',
        error: e,
        stackTrace: stack,
      );
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, User>> addSubscribedFund(
    String fundId,
    double amount,
  ) async {
    if (!await _networkInfo.hasInternetConnection) {
      return const Left(NetworkFailure());
    }

    try {
      final currentModel = await _datasource.getUser();
      // Upsert: si ya existía, actualiza el monto; si no, lo agrega.
      final updatedFunds = {...currentModel.subscribedFunds, fundId: amount};
      final updated = currentModel.copyWith(subscribedFunds: updatedFunds);
      final result = await _datasource.updateUser(updated);
      return Right(result.toEntity());
    } on Object catch (e, stack) {
      AppLogger.error(
        'UserRepository.addSubscribedFund error',
        error: e,
        stackTrace: stack,
      );
      return Left(ErrorHandler.handle(e));
    }
  }

  @override
  Future<Either<Failure, User>> removeSubscribedFund(String fundId) async {
    if (!await _networkInfo.hasInternetConnection) {
      return const Left(NetworkFailure());
    }

    try {
      final currentModel = await _datasource.getUser();
      final updatedFunds = {...currentModel.subscribedFunds}..remove(fundId);
      final updated = currentModel.copyWith(subscribedFunds: updatedFunds);
      final result = await _datasource.updateUser(updated);
      return Right(result.toEntity());
    } on Object catch (e, stack) {
      AppLogger.error(
        'UserRepository.removeSubscribedFund error',
        error: e,
        stackTrace: stack,
      );
      return Left(ErrorHandler.handle(e));
    }
  }
}
