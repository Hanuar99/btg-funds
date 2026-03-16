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

class SubscribeFundParams extends Equatable {
  const SubscribeFundParams({
    required this.fundId,
    required this.fundName,
    required this.amount,
    required this.notificationMethod,
  });
  final String fundId;
  final String fundName;
  final double amount;
  final NotificationMethod notificationMethod;

  @override
  List<Object?> get props => [fundId, fundName, amount, notificationMethod];
}

@lazySingleton
class SubscribeFundUseCase implements UseCase<Fund, SubscribeFundParams> {
  const SubscribeFundUseCase(
    this._fundsRepository,
    this._userRepository,
    this._transactionsRepository,
  );
  final FundsRepository _fundsRepository;
  final UserRepository _userRepository;
  final TransactionsRepository _transactionsRepository;

  @override
  Future<Either<Failure, Fund>> call(SubscribeFundParams params) async {
    final userResult = await _userRepository.getUser();

    return userResult.fold<Future<Either<Failure, Fund>>>(
      (failure) async => Left(failure),
      (user) async {
        if (user.balance < params.amount) {
          return Left(
            InsufficientBalanceFailure(
              'No tiene saldo disponible para vincularse al fondo ${params.fundName}',
            ),
          );
        }

        final fundResult = await _fundsRepository.subscribeFund(
          fundId: params.fundId,
          amount: params.amount,
        );

        return fundResult.fold<Future<Either<Failure, Fund>>>(
          (failure) async => Left(failure),
          (fund) async {
            final updateBalanceResult = await _userRepository.updateBalance(
              user.balance - params.amount,
            );
            final updateBalanceFailure = updateBalanceResult.fold<Failure?>(
              (failure) => failure,
              (_) => null,
            );
            if (updateBalanceFailure != null) {
              return Left(updateBalanceFailure);
            }

            final addSubscribedFundResult = await _userRepository
                .addSubscribedFund(
                  params.fundId,
                  params.amount,
                );
            final addSubscribedFundFailure = addSubscribedFundResult
                .fold<Failure?>(
                  (failure) => failure,
                  (_) => null,
                );
            if (addSubscribedFundFailure != null) {
              return Left(addSubscribedFundFailure);
            }

            final addTransactionResult = await _transactionsRepository
                .addTransaction(
                  Transaction(
                    id: const Uuid().v4(),
                    fundId: fund.id,
                    fundName: fund.name,
                    type: TransactionType.subscription,
                    amount: params.amount,
                    date: DateTime.now(),
                    notificationMethod: params.notificationMethod,
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
