import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/cancel_fund_usecase.dart';
import 'package:btg_funds_manager/features/funds/domain/usecases/subscribe_fund_usecase.dart';
import 'package:btg_funds_manager/features/transactions/data/models/transaction_model.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/user/data/models/user_model.dart';
import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:mocktail/mocktail.dart';

/// Registra los fallback values necesarios para mocktail.
void registerFallbackValues() {
  registerFallbackValue(const NoParams());
  registerFallbackValue(
    const SubscribeFundParams(
      fundId: '1',
      fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
      amount: 75000,
      notificationMethod: NotificationMethod.email,
    ),
  );
  registerFallbackValue(const CancelFundParams(fundId: '1'));
  registerFallbackValue(const UserModel(id: '', balance: 0));
  registerFallbackValue(
    const TransactionModel(
      id: '',
      fundId: '',
      fundName: '',
      type: 'subscription',
      amount: 0,
      date: '2024-01-01T00:00:00.000',
    ),
  );
}

class TestFixtures {
  TestFixtures._();

  // ─── Fondos individuales ───────────────────────────────────────────────────

  static const Fund tFund1 = Fund(
    id: '1',
    name: 'FPV_BTG_PACTUAL_RECAUDADORA',
    minimumAmount: 75000,
    category: FundCategory.fpv,
  );

  static const Fund tFund2 = Fund(
    id: '2',
    name: 'FPV_BTG_PACTUAL_ECOPETROL',
    minimumAmount: 125000,
    category: FundCategory.fpv,
  );

  static const Fund tFund3 = Fund(
    id: '3',
    name: 'DEUDAPRIVADA',
    minimumAmount: 50000,
    category: FundCategory.fic,
  );

  static const Fund tFund4 = Fund(
    id: '4',
    name: 'FDO-ACCIONES',
    minimumAmount: 250000,
    category: FundCategory.fic,
  );

  static const Fund tFund5 = Fund(
    id: '5',
    name: 'FPV_BTG_PACTUAL_DINAMICA',
    minimumAmount: 100000,
    category: FundCategory.fpv,
  );

  /// Fondo 1 con suscripción activa por el monto mínimo.
  static final Fund tFundSubscribed = tFund1.copyWith(
    isSubscribed: true,
    subscribedAmount: 75000,
  );

  /// Lista completa de 5 fondos BTG (todos sin suscribir).
  static const List<Fund> tAllFunds = [
    tFund1,
    tFund2,
    tFund3,
    tFund4,
    tFund5,
  ];

  // ─── Usuarios ─────────────────────────────────────────────────────────────

  /// Usuario con saldo inicial estándar (500 000 COP).
  static const User tUser = User(id: 'user-001', balance: 500000);

  /// Usuario sin saldo suficiente para ningún fondo (saldo bajo).
  static const User tUserLowBalance = User(id: 'user-001', balance: 10000);

  /// Usuario con saldo cero.
  static const User tUserZeroBalance = User(id: 'user-001', balance: 0);

  /// Usuario después de suscribirse al fondo 1 con 75 000 COP.
  static const User tUserAfterSubscription = User(
    id: 'user-001',
    balance: 425000,
    subscribedFunds: {'1': 75000},
  );

  // ─── Transacciones ────────────────────────────────────────────────────────

  /// Transacción de suscripción al fondo 1, notificada por email.
  static final Transaction tTransactionSubscription = Transaction(
    id: 'txn-001',
    fundId: '1',
    fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
    type: TransactionType.subscription,
    amount: 75000,
    date: DateTime(2024, 1, 15, 10, 30),
    notificationMethod: NotificationMethod.email,
  );

  /// Transacción de cancelación del fondo 1, sin método de notificación.
  static final Transaction tTransactionCancellation = Transaction(
    id: 'txn-002',
    fundId: '1',
    fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
    type: TransactionType.cancellation,
    amount: 75000,
    date: DateTime(2024, 1, 20, 14, 0),
  );

  // Alias de compatibilidad con tests existentes
  static final Transaction tTransaction = tTransactionSubscription;

  // ─── Params de use cases ──────────────────────────────────────────────────

  static const NoParams tNoParams = NoParams();

  static const SubscribeFundParams tSubscribeFundParams = SubscribeFundParams(
    fundId: '1',
    fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
    amount: 75000,
    notificationMethod: NotificationMethod.email,
  );

  static const CancelFundParams tCancelFundParams = CancelFundParams(
    fundId: '1',
  );

  // ─── Failures ─────────────────────────────────────────────────────────────

  static const InsufficientBalanceFailure
  tInsufficientBalanceFailure = InsufficientBalanceFailure(
    'No tiene saldo disponible para vincularse al fondo FPV_BTG_PACTUAL_RECAUDADORA',
  );

  static const FundNotFoundFailure tFundNotFoundFailure = FundNotFoundFailure(
    'Fondo 1 no encontrado',
  );

  static const AlreadySubscribedFailure tAlreadySubscribedFailure =
      AlreadySubscribedFailure(
        'Ya está suscrito al fondo FPV_BTG_PACTUAL_RECAUDADORA',
      );

  static const NotSubscribedFailure tNotSubscribedFailure =
      NotSubscribedFailure('No está suscrito al fondo 1');

  static const CacheFailure tCacheFailure = CacheFailure(
    'Error al leer del almacenamiento local',
  );

  static const NetworkFailure tNetworkFailure = NetworkFailure();

  static const UnexpectedFailure tUnexpectedFailure = UnexpectedFailure(
    'Error inesperado en el sistema',
  );
}
