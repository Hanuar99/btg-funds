import 'package:intl/intl.dart';

/// Centraliza el formato de moneda para evitar inconsistencias visuales.
abstract class CurrencyFormatter {
  static final NumberFormat _copDecimal = NumberFormat.decimalPattern('es_CO');

  /// Formatea un valor en COP con prefijo '$'.
  static String cop(double amount) {
    return '\$${_copDecimal.format(amount)}';
  }

  /// Formatea un valor en COP con prefijo explícito de moneda.
  static String copWithCode(double amount) {
    return 'COP ${cop(amount)}';
  }
}
