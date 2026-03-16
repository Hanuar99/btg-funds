import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUser();

  Future<Either<Failure, User>> updateBalance(double newBalance);

  Future<Either<Failure, User>> addSubscribedFund(String fundId, double amount);

  Future<Either<Failure, User>> removeSubscribedFund(String fundId);
}
