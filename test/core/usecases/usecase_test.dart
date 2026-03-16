import 'package:btg_funds_manager/core/usecases/usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NoParams', () {
    // ─── Contrato Equatable ────────────────────────────────────────────────

    test('es una instancia de Equatable', () {
      expect(const NoParams(), isA<Equatable>());
    });

    test('props retorna una lista vacía', () {
      const noParams = NoParams();

      expect(noParams.props, isEmpty);
      expect(noParams.props, <Object?>[]);
    });

    // ─── Igualdad ──────────────────────────────────────────────────────────

    test('dos instancias son iguales entre sí', () {
      const a = NoParams();
      const b = NoParams();

      expect(a, equals(b));
    });

    test('el operador == retorna true para dos instancias', () {
      // ignore: unrelated_type_equality_checks
      expect(const NoParams() == const NoParams(), isTrue);
    });

    // ─── HashCode ──────────────────────────────────────────────────────────

    test('dos instancias tienen el mismo hashCode', () {
      const a = NoParams();
      const b = NoParams();

      expect(a.hashCode, equals(b.hashCode));
    });

    // ─── toString ─────────────────────────────────────────────────────────

    test('toString contiene el nombre de la clase', () {
      expect(const NoParams().toString(), contains('NoParams'));
    });

    // ─── Uso en colecciones ───────────────────────────────────────────────

    test('puede usarse como clave en un Set sin duplicados', () {
      // ignore: equal_elements_in_set
      final set = {const NoParams(), const NoParams()};

      expect(set.length, 1);
    });

    test('puede usarse como clave en un Map', () {
      final map = <NoParams, String>{const NoParams(): 'valor'};

      expect(map[const NoParams()], 'valor');
    });
  });
}
