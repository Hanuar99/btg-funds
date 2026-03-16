import 'package:btg_funds_manager/core/utils/currency_formatter.dart';

abstract final class TransactionsUiHelpers {
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static String signedAmount({
    required bool isSubscription,
    required double amount,
  }) {
    final sign = isSubscription ? '-' : '+';
    return '$sign${CurrencyFormatter.cop(amount)}';
  }
}
