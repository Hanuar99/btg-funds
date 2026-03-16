import 'package:btg_funds_manager/core/errors/error_handler.dart';
import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/logger/app_logger.dart';
import 'package:btg_funds_manager/core/network/network_info.dart';
import 'package:btg_funds_manager/features/funds/data/datasources/funds_local_datasource.dart';
import 'package:btg_funds_manager/features/funds/data/models/fund_model.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/domain/repositories/funds_repository.dart';
import 'package:btg_funds_manager/features/user/data/datasources/user_local_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: FundsRepository)
class FundsRepositoryImpl implements FundsRepository {
  const FundsRepositoryImpl(
    this._fundsDataSource,
    this._userDataSource,
    this._networkInfo,
  );
  final FundsLocalDatasource _fundsDataSource;
  final UserLocalDatasource _userDataSource;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, List<Fund>>> getFunds() async {
    if (!await _networkInfo.hasInternetConnection) {
      return const Left(NetworkFailure());
    }

    try {
      final models = await _fundsDataSource.getFunds();
      final userModel = await _userDataSource.getUser();
      final subscribedFunds = userModel.subscribedFunds;

      final entities = models.map((model) {
        final amount = subscribedFunds[model.id];
        if (amount != null) {
          return model
              .copyWith(isSubscribed: true, subscribedAmount: amount)
              .toEntity();
        }
        return model.toEntity();
      }).toList();

      AppLogger.debug(
        'getFunds: ${entities.length} fondos, '
        '${subscribedFunds.length} suscritos',
      );

      return Right(entities);
    } on Object catch (e, stackTrace) {
      AppLogger.error(
        'Error obteniendo fondos',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ErrorHandler.handle(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Fund>> subscribeFund({
    required String fundId,
    required double amount,
  }) async {
    if (!await _networkInfo.hasInternetConnection) {
      return const Left(NetworkFailure());
    }

    try {
      // El repositorio coordina: verifica estado del usuario antes de actuar.
      final userModel = await _userDataSource.getUser();
      if (userModel.subscribedFunds.containsKey(fundId)) {
        return Left(
          AlreadySubscribedFailure('Ya está suscrito al fondo $fundId'),
        );
      }

      final model = await _fundsDataSource.subscribeFund(
        fundId: fundId,
        amount: amount,
      );
      return Right(
        model.copyWith(isSubscribed: true, subscribedAmount: amount).toEntity(),
      );
    } on BusinessException catch (e) {
      if (e.message.contains('no encontrado')) {
        return Left(FundNotFoundFailure(e.message));
      }
      return Left(UnexpectedFailure(e.message));
    } on Object catch (e, stackTrace) {
      AppLogger.error(
        'Error suscribiendo fondo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ErrorHandler.handle(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, Fund>> cancelFund({required String fundId}) async {
    if (!await _networkInfo.hasInternetConnection) {
      return const Left(NetworkFailure());
    }

    try {
      // El repositorio verifica datos del usuario — fuente de verdad persistida.
      final userModel = await _userDataSource.getUser();
      final subscribedAmount = userModel.subscribedFunds[fundId];
      if (subscribedAmount == null) {
        return Left(NotSubscribedFailure('No está suscrito al fondo $fundId'));
      }

      final model = await _fundsDataSource.cancelFund(fundId: fundId);
      // Retornamos el monto previo para que el use case pueda reintegrarlo.
      return Right(
        model
            .copyWith(isSubscribed: false, subscribedAmount: subscribedAmount)
            .toEntity(),
      );
    } on BusinessException catch (e) {
      if (e.message.contains('no encontrado')) {
        return Left(FundNotFoundFailure(e.message));
      }
      return Left(UnexpectedFailure(e.message));
    } on Object catch (e, stackTrace) {
      AppLogger.error(
        'Error cancelando fondo',
        error: e,
        stackTrace: stackTrace,
      );
      return Left(ErrorHandler.handle(e, stackTrace));
    }
  }
}
