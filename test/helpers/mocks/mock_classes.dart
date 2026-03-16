import 'package:btg_funds_manager/core/network/network_info.dart';
import 'package:btg_funds_manager/core/storage/storage_service.dart';
import 'package:btg_funds_manager/features/funds/data/datasources/funds_local_datasource.dart';
import 'package:btg_funds_manager/features/funds/domain/repositories/funds_repository.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/cancel_fund_usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/get_funds_usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/subscribe_fund_usecase.dart';
import 'package:btg_funds_manager/features/transactions/data/datasources/transactions_local_datasource.dart';
import 'package:btg_funds_manager/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:btg_funds_manager/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:btg_funds_manager/features/user/data/datasources/user_local_datasource.dart';
import 'package:btg_funds_manager/features/user/domain/repositories/user_repository.dart';
import 'package:btg_funds_manager/features/user/domain/usecases/get_user_usecase.dart';
import 'package:mocktail/mocktail.dart';

// ─── Repositories ─────────────────────────────────────────────────────────────

class MockFundsRepository extends Mock implements FundsRepository {}

class MockTransactionsRepository extends Mock
    implements TransactionsRepository {}

class MockUserRepository extends Mock implements UserRepository {}

// ─── Datasources ──────────────────────────────────────────────────────────────

class MockFundsLocalDatasource extends Mock implements FundsLocalDatasource {}

class MockTransactionsLocalDatasource extends Mock
    implements TransactionsLocalDatasource {}

class MockUserLocalDatasource extends Mock implements UserLocalDatasource {}

// ─── Services ─────────────────────────────────────────────────────────────────

class MockStorageService extends Mock implements StorageService {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

// ─── Use Cases ────────────────────────────────────────────────────────────────

class MockGetFundsUseCase extends Mock implements GetFundsUseCase {}

class MockSubscribeFundUseCase extends Mock implements SubscribeFundUseCase {}

class MockCancelFundUseCase extends Mock implements CancelFundUseCase {}

class MockGetTransactionsUseCase extends Mock
    implements GetTransactionsUseCase {}

class MockGetUserUseCase extends Mock implements GetUserUseCase {}
