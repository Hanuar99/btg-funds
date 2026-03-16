import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/domain/repositories/funds_repository.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:btg_funds_manager/features/user/domain/repositories/user_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

class CancelFundParams extends Equatable {
  const CancelFundParams({required this.fundId});
  final String fundId;

  @override
  List<Object?> get props => [fundId];
}

@lazySingleton
class CancelFundUseCase implements UseCase<Fund, CancelFundParams> {
  const CancelFundUseCase(
    this._fundsRepository,
    this._userRepository,
    this._transactionsRepository,
  );
  final FundsRepository _fundsRepository;
  final UserRepository _userRepository;
  final TransactionsRepository _transactionsRepository;

  @override
  Future<Either<Failure, Fund>> call(CancelFundParams params) async {
    final userResult = await _userRepository.getUser();

    return userResult.fold<Future<Either<Failure, Fund>>>(
      (failure) async => Left(failure),
      (user) async {
        final cancelResult = await _fundsRepository.cancelFund(
          fundId: params.fundId,
        );

        return cancelResult.fold<Future<Either<Failure, Fund>>>(
          (failure) async => Left(failure),
          (fund) async {
            final updateBalanceResult = await _userRepository.updateBalance(
              user.balance + fund.subscribedAmount,
            );
            final updateBalanceFailure = updateBalanceResult.fold<Failure?>(
              (failure) => failure,
              (_) => null,
            );
            if (updateBalanceFailure != null) {
              return Left(updateBalanceFailure);
            }

            final removeSubscribedFundResult = await _userRepository
                .removeSubscribedFund(params.fundId);
            final removeSubscribedFundFailure = removeSubscribedFundResult
                .fold<Failure?>(
                  (failure) => failure,
                  (_) => null,
                );
            if (removeSubscribedFundFailure != null) {
              return Left(removeSubscribedFundFailure);
            }

            final addTransactionResult = await _transactionsRepository
                .addTransaction(
                  Transaction(
                    id: const Uuid().v4(),
                    fundId: fund.id,
                    fundName: fund.name,
                    type: TransactionType.cancellation,
                    amount: fund.subscribedAmount,
                    date: DateTime.now(),
                  ),
                );

            return addTransactionResult.fold<Either<Failure, Fund>>(
              Left.new,
              (_) => Right(fund),
            );
          },
        );
      },
    );
  }
}
