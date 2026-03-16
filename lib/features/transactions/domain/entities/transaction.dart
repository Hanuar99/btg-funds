import 'package:equatable/equatable.dart';

/// Tipo de transaccion registrada sobre un fondo.
enum TransactionType { subscription, cancellation }

/// Metodo de notificacion asociado a la transaccion.
enum NotificationMethod { email, sms }

/// Entidad inmutable - representa un registro del historial de transacciones.
class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.fundId,
    required this.fundName,
    required this.type,
    required this.amount,
    required this.date,
    this.notificationMethod,
  });

  /// Identificador unico de la transaccion.
  final String id;

  /// ID del fondo relacionado.
  final String fundId;

  /// Nombre del fondo para mostrar en historial.
  final String fundName;

  /// Tipo de operacion realizada sobre el fondo.
  final TransactionType type;

  /// Monto de la transaccion en COP.
  final double amount;

  /// Fecha y hora en que se registro la transaccion.
  final DateTime date;

  /// Metodo de notificacion usado; solo aplica en suscripciones.
  final NotificationMethod? notificationMethod;

  @override
  List<Object?> get props => [
    id,
    fundId,
    fundName,
    type,
    amount,
    date,
    notificationMethod,
  ];
}
