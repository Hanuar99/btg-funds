import 'package:btg_funds_manager/features/transactions/data/models/transaction_model.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('TransactionModel', () {
    // ─── Fixtures JSON con las keys reales del @JsonKey ──────────────────────

    final tJsonSuscripcionEmail = <String, dynamic>{
      'id': 'txn-001',
      'fund_id': '1',
      'fund_name': 'FPV_BTG_PACTUAL_RECAUDADORA',
      'type': 'subscription',
      'amount': 75000.0,
      'date': '2024-01-15T10:30:00.000',
      'notification_method': 'email',
    };

    final tJsonCancelacionSinNotificacion = <String, dynamic>{
      'id': 'txn-002',
      'fund_id': '1',
      'fund_name': 'FPV_BTG_PACTUAL_RECAUDADORA',
      'type': 'cancellation',
      'amount': 75000.0,
      'date': '2024-01-20T14:00:00.000',
      'notification_method': null,
    };

    final tJsonSuscripcionSms = <String, dynamic>{
      'id': 'txn-003',
      'fund_id': '2',
      'fund_name': 'FPV_BTG_PACTUAL_ECOPETROL',
      'type': 'subscription',
      'amount': 125000.0,
      'date': '2024-02-01T09:00:00.000',
      'notification_method': 'sms',
    };

    // ─── fromJson ────────────────────────────────────────────────────────────

    group('fromJson', () {
      test(
        'parsea id, fundId, fundName, type, amount y date correctamente',
        () {
          // Arrange & Act
          final model = TransactionModel.fromJson(tJsonSuscripcionEmail);

          // Assert
          expect(model.id, 'txn-001');
          expect(model.fundId, '1');
          expect(model.fundName, 'FPV_BTG_PACTUAL_RECAUDADORA');
          expect(model.type, 'subscription');
          expect(model.amount, 75000.0);
          expect(model.date, '2024-01-15T10:30:00.000');
        },
      );

      test('parsea fund_id con @JsonKey correctamente en fundId', () {
        // Arrange & Act
        final model = TransactionModel.fromJson(tJsonSuscripcionEmail);

        // Assert — field en Dart es fundId, key en JSON es fund_id
        expect(model.fundId, '1');
      });

      test('parsea notification_method email correctamente', () {
        // Arrange & Act
        final model = TransactionModel.fromJson(tJsonSuscripcionEmail);

        // Assert
        expect(model.notificationMethod, 'email');
      });

      test('parsea notification_method sms correctamente', () {
        // Arrange & Act
        final model = TransactionModel.fromJson(tJsonSuscripcionSms);

        // Assert
        expect(model.notificationMethod, 'sms');
      });

      test(
        'notificationMethod es null cuando la key viene como null en el JSON',
        () {
          // Arrange & Act
          final model = TransactionModel.fromJson(
            tJsonCancelacionSinNotificacion,
          );

          // Assert
          expect(model.notificationMethod, isNull);
        },
      );

      test('parsea type cancellation correctamente', () {
        // Arrange & Act
        final model = TransactionModel.fromJson(
          tJsonCancelacionSinNotificacion,
        );

        // Assert
        expect(model.type, 'cancellation');
      });
    });

    // ─── toEntity ────────────────────────────────────────────────────────────

    group('toEntity', () {
      test('mapea id, fundId, fundName y amount sin transformación', () {
        // Arrange
        final model = TransactionModel.fromJson(tJsonSuscripcionEmail);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, model.id);
        expect(entity.fundId, model.fundId);
        expect(entity.fundName, model.fundName);
        expect(entity.amount, model.amount);
      });

      test(
        'convierte type subscription al enum TransactionType.subscription',
        () {
          // Arrange
          final model = TransactionModel.fromJson(tJsonSuscripcionEmail);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity.type, TransactionType.subscription);
        },
      );

      test(
        'convierte type cancellation al enum TransactionType.cancellation',
        () {
          // Arrange
          final model = TransactionModel.fromJson(
            tJsonCancelacionSinNotificacion,
          );

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity.type, TransactionType.cancellation);
        },
      );

      test('convierte el string de date a DateTime con DateTime.parse', () {
        // Arrange
        final model = TransactionModel.fromJson(tJsonSuscripcionEmail);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.date, isA<DateTime>());
        expect(entity.date, DateTime.parse('2024-01-15T10:30:00.000'));
      });

      test(
        'convierte notification_method email al enum NotificationMethod.email',
        () {
          // Arrange
          final model = TransactionModel.fromJson(tJsonSuscripcionEmail);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity.notificationMethod, NotificationMethod.email);
        },
      );

      test(
        'convierte notification_method sms al enum NotificationMethod.sms',
        () {
          // Arrange
          final model = TransactionModel.fromJson(tJsonSuscripcionSms);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity.notificationMethod, NotificationMethod.sms);
        },
      );

      test(
        'notificationMethod de la entidad es null cuando el model tiene null',
        () {
          // Arrange
          final model = TransactionModel.fromJson(
            tJsonCancelacionSinNotificacion,
          );

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity.notificationMethod, isNull);
        },
      );

      test('produce la entidad igual al fixture tTransactionSubscription', () {
        // Arrange
        final model = TransactionModel.fromJson(tJsonSuscripcionEmail);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, equals(TestFixtures.tTransactionSubscription));
      });
    });

    // ─── toModel (extensión TransactionX on Transaction) ─────────────────────

    group('toModel', () {
      test('mapea id, fundId, fundName y amount sin transformación', () {
        // Arrange
        final entity = TestFixtures.tTransactionSubscription;

        // Act
        final model = entity.toModel();

        // Assert
        expect(model.id, entity.id);
        expect(model.fundId, entity.fundId);
        expect(model.fundName, entity.fundName);
        expect(model.amount, entity.amount);
      });

      test('convierte TransactionType.subscription al string subscription', () {
        // Arrange
        final entity = TestFixtures.tTransactionSubscription;

        // Act
        final model = entity.toModel();

        // Assert
        expect(model.type, 'subscription');
      });

      test('convierte TransactionType.cancellation al string cancellation', () {
        // Arrange
        final entity = TestFixtures.tTransactionCancellation;

        // Act
        final model = entity.toModel();

        // Assert
        expect(model.type, 'cancellation');
      });

      test('convierte DateTime a string ISO 8601 con toIso8601String()', () {
        // Arrange
        final entity = TestFixtures.tTransactionSubscription;

        // Act
        final model = entity.toModel();

        // Assert
        expect(model.date, isA<String>());
        expect(model.date, entity.date.toIso8601String());
      });

      test(
        'el string de date del model puede ser re-parseado al DateTime original',
        () {
          // Arrange
          final entity = TestFixtures.tTransactionSubscription;

          // Act
          final model = entity.toModel();

          // Assert
          expect(DateTime.parse(model.date), entity.date);
        },
      );

      test(
        'convierte NotificationMethod.email al string email usando .name',
        () {
          // Arrange
          final entity = TestFixtures.tTransactionSubscription;

          // Act
          final model = entity.toModel();

          // Assert
          expect(model.notificationMethod, 'email');
        },
      );

      test(
        'notificationMethod del model es null cuando la entidad no tiene notificación',
        () {
          // Arrange
          final entity = TestFixtures.tTransactionCancellation;

          // Act
          final model = entity.toModel();

          // Assert
          expect(model.notificationMethod, isNull);
        },
      );

      test('round-trip: toModel().toEntity() produce la entidad original', () {
        // Arrange
        final entity = TestFixtures.tTransactionSubscription;

        // Act
        final roundTrip = entity.toModel().toEntity();

        // Assert
        expect(roundTrip, equals(entity));
      });
    });
  });
}
