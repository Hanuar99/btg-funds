import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('User', () {
    // ─── Constructor ────────────────────────────────────────────────────────

    group('constructor - creación con valores dados', () {
      test('asigna correctamente id y balance', () {
        // Arrange & Act
        const user = TestFixtures.tUser;

        // Assert
        expect(user.id, 'user-001');
        expect(user.balance, 500000.0);
      });

      test('subscribedFunds es mapa vacío por defecto cuando no se pasa', () {
        // Arrange & Act
        const user = TestFixtures.tUser;

        // Assert
        expect(user.subscribedFunds, isEmpty);
      });

      test('acepta subscribedFunds con valores cuando se especifica', () {
        // Arrange & Act
        const user = TestFixtures.tUserAfterSubscription;

        // Assert
        expect(user.subscribedFunds, {'1': 75000.0});
      });

      test('initialBalance es 500000', () {
        // Assert
        expect(User.initialBalance, 500000.0);
      });
    });

    // ─── Getter subscribedFundIds ────────────────────────────────────────────

    group('subscribedFundIds - getter', () {
      test('retorna lista vacía cuando subscribedFunds está vacío', () {
        // Arrange
        const user = TestFixtures.tUser;

        // Act
        final ids = user.subscribedFundIds;

        // Assert
        expect(ids, isEmpty);
      });

      test('retorna los IDs de los fondos suscritos', () {
        // Arrange
        const user = TestFixtures.tUserAfterSubscription;

        // Act
        final ids = user.subscribedFundIds;

        // Assert
        expect(ids, contains('1'));
        expect(ids, hasLength(1));
      });

      test('retorna tantos IDs como entradas tiene subscribedFunds', () {
        // Arrange
        const user = User(
          id: 'user-001',
          balance: 250000,
          subscribedFunds: {'1': 75000.0, '3': 50000.0},
        );

        // Act
        final ids = user.subscribedFundIds;

        // Assert
        expect(ids, hasLength(2));
        expect(ids, contains('1'));
        expect(ids, contains('3'));
      });
    });

    // ─── copyWith ────────────────────────────────────────────────────────────

    group('copyWith', () {
      test('actualiza balance sin alterar id ni subscribedFunds', () {
        // Arrange
        const user = TestFixtures.tUser;

        // Act
        final updated = user.copyWith(balance: 425000.0);

        // Assert
        expect(updated.balance, 425000.0);
        expect(updated.id, user.id);
        expect(updated.subscribedFunds, user.subscribedFunds);
      });

      test('actualiza subscribedFunds sin alterar id ni balance', () {
        // Arrange
        const user = TestFixtures.tUser;

        // Act
        final updated = user.copyWith(subscribedFunds: {'1': 75000.0});

        // Assert
        expect(updated.subscribedFunds, {'1': 75000.0});
        expect(updated.id, user.id);
        expect(updated.balance, user.balance);
      });

      test('actualiza id sin alterar los demás campos', () {
        // Arrange
        const user = TestFixtures.tUser;

        // Act
        final updated = user.copyWith(id: 'user-002');

        // Assert
        expect(updated.id, 'user-002');
        expect(updated.balance, user.balance);
        expect(updated.subscribedFunds, user.subscribedFunds);
      });

      test('retorna objeto distinto cuando cambia el balance', () {
        // Arrange
        const user = TestFixtures.tUser;

        // Act
        final updated = user.copyWith(balance: 0);

        // Assert
        expect(updated, isNot(equals(user)));
      });

      test('retorna objeto igual cuando no se cambia ningún campo', () {
        // Arrange
        const user = TestFixtures.tUser;

        // Act
        final copy = user.copyWith();

        // Assert
        expect(copy, equals(user));
      });
    });

    // ─── Equatable ───────────────────────────────────────────────────────────

    group('Equatable - igualdad', () {
      test('dos usuarios con exactamente los mismos valores son iguales', () {
        // Arrange
        const u1 = User(id: 'user-001', balance: 500000);
        const u2 = User(id: 'user-001', balance: 500000);

        // Assert
        expect(u1, equals(u2));
      });

      test('usuarios con distinto balance no son iguales', () {
        // Arrange
        const u1 = TestFixtures.tUser;
        const u2 = TestFixtures.tUserLowBalance;

        // Assert
        expect(u1, isNot(equals(u2)));
      });

      test('usuarios con distinto id no son iguales', () {
        // Arrange
        const u1 = User(id: 'user-001', balance: 500000);
        const u2 = User(id: 'user-002', balance: 500000);

        // Assert
        expect(u1, isNot(equals(u2)));
      });

      test(
        'usuario sin fondos y usuario con fondos suscritos no son iguales',
        () {
          // Arrange
          const u1 = TestFixtures.tUser;
          const u2 = TestFixtures.tUserAfterSubscription;

          // Assert
          expect(u1, isNot(equals(u2)));
        },
      );

      test(
        'usuarios con mismos fondos pero distinto monto invertido no son iguales',
        () {
          // Arrange
          const u1 = User(
            id: 'user-001',
            balance: 500000,
            subscribedFunds: {'1': 75000.0},
          );
          const u2 = User(
            id: 'user-001',
            balance: 500000,
            subscribedFunds: {'1': 50000.0},
          );

          // Assert
          expect(u1, isNot(equals(u2)));
        },
      );
    });

    // ─── props ───────────────────────────────────────────────────────────────

    group('props - campos de Equatable', () {
      test('props contiene los 3 campos en el orden exacto del código', () {
        // Arrange
        const user = TestFixtures.tUser;

        // Assert
        expect(user.props, [user.id, user.balance, user.subscribedFunds]);
      });

      test(
        'props refleja el mapa subscribedFunds cuando hay fondos suscritos',
        () {
          // Arrange
          const user = TestFixtures.tUserAfterSubscription;

          // Assert
          expect(user.props[2], {'1': 75000.0});
        },
      );
    });
  });
}
