import 'package:equatable/equatable.dart';

/// Falla base del dominio para representar errores de negocio o infraestructura.
abstract class Failure extends Equatable {
  const Failure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// Ocurre cuando el usuario no tiene saldo suficiente para completar la operacion.
class InsufficientBalanceFailure extends Failure {
  const InsufficientBalanceFailure(super.message);
}

/// Ocurre cuando el fondo solicitado no existe en el sistema.
class FundNotFoundFailure extends Failure {
  const FundNotFoundFailure(super.message);
}

/// Ocurre cuando el usuario intenta suscribirse a un fondo ya suscrito.
class AlreadySubscribedFailure extends Failure {
  const AlreadySubscribedFailure(super.message);
}

/// Ocurre cuando el usuario intenta cancelar un fondo al que no esta suscrito.
class NotSubscribedFailure extends Failure {
  const NotSubscribedFailure(super.message);
}

/// Ocurre cuando falla el almacenamiento local o la lectura/escritura en cache.
class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

/// Ocurre cuando no hay conexion de red para completar una operacion remota.
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message =
        'Sin conexion a internet. Revise su red e intente nuevamente.',
  ]);
}

/// Ocurre ante errores inesperados del sistema no contemplados explicitamente.
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message);
}
