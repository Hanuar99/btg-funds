/// Excepcion de la capa Data usada para errores de almacenamiento local (Hive).
class CacheException implements Exception {
  const CacheException(this.message);
  final String message;
}

/// Excepcion de la capa Data usada para errores de validacion de negocio.
class BusinessException implements Exception {
  const BusinessException(this.message);
  final String message;
}

/// Excepcion de la capa Data usada para errores inesperados del sistema.
class UnexpectedException implements Exception {
  const UnexpectedException(this.message);
  final String message;
}

/// Excepcion de infraestructura para operaciones que requieren internet.
class NetworkException implements Exception {
  const NetworkException(this.message);
  final String message;
}
