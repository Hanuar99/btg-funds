import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:dartz/dartz.dart';

abstract class FundsRepository {
  Future<Either<Failure, List<Fund>>> getFunds();

  Future<Either<Failure, Fund>> subscribeFund({
    required String fundId,
    required double amount,
  });
  Future<Either<Failure, Fund>> cancelFund({
    required String fundId,
  });
}
