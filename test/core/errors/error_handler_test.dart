import 'package:btg_funds_manager/core/errors/error_handler.dart';
import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:flutter_test/flutter_test.dart';

// Nota: ErrorHandler.handle siempre invoca AppLogger.error antes de retornar.
// AppLogger expone métodos estáticos, por lo que no es mockeable con mocktail.
// Los tests verifican únicamente el Failure retornado por cada rama de mapeo.

void main() {
  group('ErrorHandler.handle', () {
    // ─── CacheException ────────────────────────────────────────────────────

    group('CacheException → CacheFailure', () {
      test('retorna CacheFailure con el mensaje de la excepción', () {
        const exception = CacheException('Error de caché');

        final result = ErrorHandler.handle(exception);

        expect(result, const CacheFailure('Error de caché'));
      });

      test('preserva el mensaje exacto de CacheException', () {
        const exception = CacheException('Hive box no disponible');

        final result = ErrorHandler.handle(exception);

        expect(result, isA<CacheFailure>());
        expect(result.message, 'Hive box no disponible');
      });
    });

    // ─── NetworkException ──────────────────────────────────────────────────

    group('NetworkException → NetworkFailure', () {
      test('retorna NetworkFailure con el mensaje de la excepción', () {
        const exception = NetworkException('Sin conexión a internet');

        final result = ErrorHandler.handle(exception);

        expect(result, const NetworkFailure('Sin conexión a internet'));
      });

      test('preserva el mensaje exacto de NetworkException', () {
        const exception = NetworkException('Tiempo de espera agotado');

        final result = ErrorHandler.handle(exception);

        expect(result, isA<NetworkFailure>());
        expect(result.message, 'Tiempo de espera agotado');
      });
    });

    // ─── BusinessException ─────────────────────────────────────────────────

    group('BusinessException → UnexpectedFailure', () {
      test('retorna UnexpectedFailure con el mensaje de la excepción', () {
        const exception = BusinessException('Validación de negocio fallida');

        final result = ErrorHandler.handle(exception);

        expect(
          result,
          const UnexpectedFailure('Validación de negocio fallida'),
        );
      });

      test('preserva el mensaje exacto de BusinessException', () {
        const exception = BusinessException('Operación no permitida');

        final result = ErrorHandler.handle(exception);

        expect(result, isA<UnexpectedFailure>());
        expect(result.message, 'Operación no permitida');
      });
    });

    // ─── Excepciones no reconocidas ────────────────────────────────────────
    //
    // UnexpectedException NO tiene una rama propia en ErrorHandler.handle,
    // por lo que cae al caso genérico junto con cualquier otro error.

    group('Excepción no reconocida → UnexpectedFailure genérico', () {
      test(
        'UnexpectedException cae al caso genérico con formato "Error inesperado: ..."',
        () {
          const exception = UnexpectedException('Error del sistema');

          final result = ErrorHandler.handle(exception);

          expect(result, isA<UnexpectedFailure>());
          expect(result.message, 'Error inesperado: $exception');
        },
      );

      test(
        'Exception estándar retorna UnexpectedFailure con formato correcto',
        () {
          final exception = Exception('error genérico');

          final result = ErrorHandler.handle(exception);

          expect(result, isA<UnexpectedFailure>());
          expect(result.message, 'Error inesperado: $exception');
        },
      );

      test(
        'String arbitrario retorna UnexpectedFailure con el string embebido',
        () {
          const error = 'texto de error inesperado';

          final result = ErrorHandler.handle(error);

          expect(result, isA<UnexpectedFailure>());
          expect(result.message, 'Error inesperado: $error');
        },
      );

      test('objeto desconocido (int) retorna UnexpectedFailure', () {
        final result = ErrorHandler.handle(42);

        expect(result, isA<UnexpectedFailure>());
        expect(result.message, 'Error inesperado: 42');
      });

      test('null retorna UnexpectedFailure', () {
        final result = ErrorHandler.handle(null);

        expect(result, isA<UnexpectedFailure>());
        expect(result.message, 'Error inesperado: null');
      });
    });

    // ─── Parámetro stackTrace opcional ────────────────────────────────────

    group('Parámetro stackTrace', () {
      test('acepta StackTrace sin lanzar excepción', () {
        const exception = CacheException('fallo con stack');

        expect(
          () => ErrorHandler.handle(exception, StackTrace.current),
          returnsNormally,
        );
      });

      test('retorna el mismo Failure con o sin StackTrace', () {
        const exception = NetworkException('timeout');

        final conStack = ErrorHandler.handle(exception, StackTrace.current);
        final sinStack = ErrorHandler.handle(exception);

        expect(conStack, sinStack);
      });
    });

    // ─── Igualdad entre Failures retornados ───────────────────────────────

    group('Igualdad Equatable de los Failures retornados', () {
      test(
        'dos llamadas con la misma CacheException retornan Failures iguales',
        () {
          const e1 = CacheException('mismo mensaje');
          const e2 = CacheException('mismo mensaje');

          expect(ErrorHandler.handle(e1), ErrorHandler.handle(e2));
        },
      );

      test(
        'CacheFailure y NetworkFailure con el mismo mensaje NO son iguales',
        () {
          final cache = ErrorHandler.handle(const CacheException('msg'));
          final network = ErrorHandler.handle(const NetworkException('msg'));

          expect(cache, isNot(equals(network)));
        },
      );

      test('CacheFailure y UnexpectedFailure NO son iguales', () {
        final cache = ErrorHandler.handle(const CacheException('msg'));
        final unexpected = ErrorHandler.handle(const BusinessException('msg'));

        expect(cache, isNot(equals(unexpected)));
      });
    });
  });
}
