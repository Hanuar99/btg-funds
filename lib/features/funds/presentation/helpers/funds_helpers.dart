import 'package:btg_funds_manager/core/utils/currency_formatter.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_state.dart';

/// Retorna una lista vacía para estados sin fondos (initial, loading).
List<Fund> extractFunds(FundsState state) {
  return state.maybeMap(
    loaded: (s) => s.funds,
    subscribing: (s) => s.funds,
    subscribeSuccess: (s) => s.funds,
    cancelSuccess: (s) => s.funds,
    failure: (s) => s.funds,
    orElse: () => const <Fund>[],
  );
}

/// Formatea un monto en pesos colombianos con código de moneda.
String formatCOP(double amount) => CurrencyFormatter.copWithCode(amount);
