import 'package:intl/intl.dart';

/// Formatter de fechas para presentación del historial de transacciones.
abstract class TransactionDateFormatter {
  static String transactionDateTime(DateTime date) {
    return DateFormat('d MMM · h:mm a', 'es').format(date.toLocal());
  }

  static String dateGroupLabel(DateTime date, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final yesterday = current.subtract(const Duration(days: 1));

    final isToday =
        date.year == current.year &&
        date.month == current.month &&
        date.day == current.day;
    final isYesterday =
        date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;

    if (isToday) {
      return 'HOY';
    }
    if (isYesterday) {
      return 'AYER';
    }
    return DateFormat('d MMM yyyy', 'es').format(date).toUpperCase();
  }
}
