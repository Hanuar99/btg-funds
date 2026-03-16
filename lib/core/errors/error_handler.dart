import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/core/logger/app_logger.dart';

/// Este es el punto central donde todas las excepciones se convierten en Failures.
class ErrorHandler {
  ErrorHandler._();

  static Failure handle(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.error(
      'ErrorHandler capturo: $error',
      error: error,
      stackTrace: stackTrace,
    );

    if (error is CacheException) {
      return CacheFailure(error.message);
    }

    if (error is NetworkException) {
      return NetworkFailure(error.message);
    }

    if (error is BusinessException) {
      return UnexpectedFailure(error.message);
    }

    return UnexpectedFailure('Error inesperado: $error');
  }
}
