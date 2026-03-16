import 'package:btg_funds_manager/features/user/data/models/user_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('UserModel', () {
    // ─── Fixtures JSON con las keys reales del @JsonKey ──────────────────────

    const tJsonConFondos = <String, dynamic>{
      'id': 'user-001',
      'balance': 425000.0,
      'subscribed_funds': {'1': 75000.0},
    };

    const tJsonSinFondos = <String, dynamic>{
      'id': 'user-001',
      'balance': 500000.0,
      // subscribed_funds ausente → debe usar @Default <String, double>{}
    };

    const tJsonFondosVaciosExplicito = <String, dynamic>{
      'id': 'user-001',
      'balance': 500000.0,
      'subscribed_funds': <String, double>{},
    };

    const tJsonMultiplesFondos = <String, dynamic>{
      'id': 'user-001',
      'balance': 250000.0,
      'subscribed_funds': {'1': 75000.0, '3': 50000.0},
    };

    // ─── fromJson ────────────────────────────────────────────────────────────

    group('fromJson', () {
      test('parsea id y balance correctamente', () {
        // Arrange & Act
        final model = UserModel.fromJson(tJsonConFondos);

        // Assert
        expect(model.id, 'user-001');
        expect(model.balance, 425000.0);
      });

      test(
        'parsea subscribed_funds con @JsonKey correctamente en subscribedFunds',
        () {
          // Arrange & Act
          final model = UserModel.fromJson(tJsonConFondos);

          // Assert — field en Dart es subscribedFunds, key en JSON es subscribed_funds
          expect(model.subscribedFunds, {'1': 75000.0});
        },
      );

      test(
        'usa @Default mapa vacío cuando subscribed_funds está ausente del JSON',
        () {
          // Arrange & Act
          final model = UserModel.fromJson(tJsonSinFondos);

          // Assert
          expect(model.subscribedFunds, isEmpty);
        },
      );

      test('parsea subscribed_funds vacío explícito como mapa vacío', () {
        // Arrange & Act
        final model = UserModel.fromJson(tJsonFondosVaciosExplicito);

        // Assert
        expect(model.subscribedFunds, isEmpty);
      });

      test('parsea múltiples entradas en subscribed_funds correctamente', () {
        // Arrange & Act
        final model = UserModel.fromJson(tJsonMultiplesFondos);

        // Assert
        expect(model.subscribedFunds, hasLength(2));
        expect(model.subscribedFunds['1'], 75000.0);
        expect(model.subscribedFunds['3'], 50000.0);
      });

      test('balance se parsea como double desde JSON', () {
        // Arrange
        const jsonConIntBalance = <String, dynamic>{
          'id': 'user-001',
          'balance': 500000, // int en JSON
        };

        // Act
        final model = UserModel.fromJson(jsonConIntBalance);

        // Assert
        expect(model.balance, isA<double>());
        expect(model.balance, 500000.0);
      });
    });

    // ─── toEntity ────────────────────────────────────────────────────────────

    group('toEntity', () {
      test('mapea id, balance y subscribedFunds sin transformación', () {
        // Arrange
        final model = UserModel.fromJson(tJsonConFondos);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, model.id);
        expect(entity.balance, model.balance);
        expect(entity.subscribedFunds, model.subscribedFunds);
      });

      test(
        'produce entidad User con subscribedFunds vacío cuando el model no tiene fondos',
        () {
          // Arrange
          final model = UserModel.fromJson(tJsonSinFondos);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity.subscribedFunds, isEmpty);
        },
      );

      test(
        'produce la entidad igual al fixture tUser para el JSON sin fondos',
        () {
          // Arrange
          final model = UserModel.fromJson(tJsonSinFondos);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity, equals(TestFixtures.tUser));
        },
      );

      test(
        'produce la entidad igual al fixture tUserAfterSubscription para el JSON con fondos',
        () {
          // Arrange
          final model = UserModel.fromJson(tJsonConFondos);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity, equals(TestFixtures.tUserAfterSubscription));
        },
      );

      test('la entidad conserva múltiples fondos suscritos', () {
        // Arrange
        final model = UserModel.fromJson(tJsonMultiplesFondos);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.subscribedFunds, hasLength(2));
        expect(entity.subscribedFunds.containsKey('1'), isTrue);
        expect(entity.subscribedFunds.containsKey('3'), isTrue);
      });
    });

    // ─── toModel (extensión UserX on User) ───────────────────────────────────

    group('toModel', () {
      test('mapea id, balance y subscribedFunds sin transformación', () {
        // Arrange
        const entity = TestFixtures.tUser;

        // Act
        final model = entity.toModel();

        // Assert
        expect(model.id, entity.id);
        expect(model.balance, entity.balance);
        expect(model.subscribedFunds, entity.subscribedFunds);
      });

      test(
        'modelo resultante tiene subscribedFunds vacío cuando el usuario no tiene fondos',
        () {
          // Arrange
          const entity = TestFixtures.tUser;

          // Act
          final model = entity.toModel();

          // Assert
          expect(model.subscribedFunds, isEmpty);
        },
      );

      test('modelo resultante refleja los fondos suscritos del usuario', () {
        // Arrange
        const entity = TestFixtures.tUserAfterSubscription;

        // Act
        final model = entity.toModel();

        // Assert
        expect(model.subscribedFunds, {'1': 75000.0});
      });

      test(
        'round-trip: toModel().toEntity() produce la entidad original sin fondos',
        () {
          // Arrange
          const entity = TestFixtures.tUser;

          // Act
          final roundTrip = entity.toModel().toEntity();

          // Assert
          expect(roundTrip, equals(entity));
        },
      );

      test(
        'round-trip: toModel().toEntity() produce la entidad original con fondos',
        () {
          // Arrange
          const entity = TestFixtures.tUserAfterSubscription;

          // Act
          final roundTrip = entity.toModel().toEntity();

          // Assert
          expect(roundTrip, equals(entity));
        },
      );
    });
  });
}
