import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('Transaction', () {
    // ─── Constructor ────────────────────────────────────────────────────────

    group('constructor - creación con valores dados', () {
      test('asigna correctamente todos los campos requeridos', () {
        // Arrange & Act
        final transaction = TestFixtures.tTransactionSubscription;

        // Assert
        expect(transaction.id, 'txn-001');
        expect(transaction.fundId, '1');
        expect(transaction.fundName, 'FPV_BTG_PACTUAL_RECAUDADORA');
        expect(transaction.type, TransactionType.subscription);
        expect(transaction.amount, 75000.0);
        expect(transaction.date, DateTime(2024, 1, 15, 10, 30));
        expect(transaction.notificationMethod, NotificationMethod.email);
      });

      test('notificationMethod es null cuando no se proporciona', () {
        // Arrange & Act
        final transaction = TestFixtures.tTransactionCancellation;

        // Assert
        expect(transaction.notificationMethod, isNull);
      });

      test('acepta TransactionType.cancellation correctamente', () {
        // Arrange & Act
        final transaction = TestFixtures.tTransactionCancellation;

        // Assert
        expect(transaction.type, TransactionType.cancellation);
      });

      test('acepta NotificationMethod.sms correctamente', () {
        // Arrange
        final date = DateTime(2024, 3, 1);

        // Act
        final transaction = Transaction(
          id: 'txn-sms',
          fundId: '2',
          fundName: 'FPV_BTG_PACTUAL_ECOPETROL',
          type: TransactionType.subscription,
          amount: 125000,
          date: date,
          notificationMethod: NotificationMethod.sms,
        );

        // Assert
        expect(transaction.notificationMethod, NotificationMethod.sms);
      });
    });

    // ─── Equatable ───────────────────────────────────────────────────────────

    group('Equatable - igualdad', () {
      test(
        'dos transacciones con exactamente los mismos valores son iguales',
        () {
          // Arrange
          final date = DateTime(2024, 1, 15, 10, 30);
          final t1 = Transaction(
            id: 'txn-001',
            fundId: '1',
            fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
            type: TransactionType.subscription,
            amount: 75000,
            date: date,
            notificationMethod: NotificationMethod.email,
          );
          final t2 = Transaction(
            id: 'txn-001',
            fundId: '1',
            fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
            type: TransactionType.subscription,
            amount: 75000,
            date: date,
            notificationMethod: NotificationMethod.email,
          );

          // Assert
          expect(t1, equals(t2));
        },
      );

      test('transacciones con distinto id no son iguales', () {
        // Arrange
        final t1 = TestFixtures.tTransactionSubscription;
        final t2 = TestFixtures.tTransactionCancellation;

        // Assert
        expect(t1, isNot(equals(t2)));
      });

      test('transacción con notificationMethod y sin él no son iguales', () {
        // Arrange
        final date = DateTime(2024, 1, 15, 10, 30);
        final conNotificacion = Transaction(
          id: 'txn-001',
          fundId: '1',
          fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
          type: TransactionType.subscription,
          amount: 75000,
          date: date,
          notificationMethod: NotificationMethod.email,
        );
        final sinNotificacion = Transaction(
          id: 'txn-001',
          fundId: '1',
          fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
          type: TransactionType.subscription,
          amount: 75000,
          date: date,
        );

        // Assert
        expect(conNotificacion, isNot(equals(sinNotificacion)));
      });

      test(
        'transacción de suscripción y cancelación con mismo id no son iguales',
        () {
          // Arrange
          final date = DateTime(2024, 1, 15, 10, 30);
          final subscription = Transaction(
            id: 'txn-X',
            fundId: '1',
            fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
            type: TransactionType.subscription,
            amount: 75000,
            date: date,
          );
          final cancellation = Transaction(
            id: 'txn-X',
            fundId: '1',
            fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
            type: TransactionType.cancellation,
            amount: 75000,
            date: date,
          );

          // Assert
          expect(subscription, isNot(equals(cancellation)));
        },
      );

      test('transacciones con distinta fecha no son iguales', () {
        // Arrange
        final t1 = Transaction(
          id: 'txn-001',
          fundId: '1',
          fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
          type: TransactionType.subscription,
          amount: 75000,
          date: DateTime(2024, 1, 15),
        );
        final t2 = Transaction(
          id: 'txn-001',
          fundId: '1',
          fundName: 'FPV_BTG_PACTUAL_RECAUDADORA',
          type: TransactionType.subscription,
          amount: 75000,
          date: DateTime(2024, 1, 20),
        );

        // Assert
        expect(t1, isNot(equals(t2)));
      });
    });

    // ─── props ───────────────────────────────────────────────────────────────

    group('props - campos de Equatable', () {
      test('props contiene los 7 campos en el orden exacto del código', () {
        // Arrange
        final transaction = TestFixtures.tTransactionSubscription;

        // Assert
        expect(transaction.props, [
          transaction.id,
          transaction.fundId,
          transaction.fundName,
          transaction.type,
          transaction.amount,
          transaction.date,
          transaction.notificationMethod,
        ]);
      });

      test(
        'props incluye null en posición 6 cuando no hay notificationMethod',
        () {
          // Arrange
          final transaction = TestFixtures.tTransactionCancellation;

          // Assert
          expect(transaction.props[6], isNull);
        },
      );
    });
  });
}
