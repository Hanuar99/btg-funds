import 'package:btg_funds_manager/features/funds/data/models/fund_model.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('FundModel', () {
    // ─── Fixtures JSON con las keys reales del @JsonKey ──────────────────────

    const tJsonFpvCompleto = <String, dynamic>{
      'id': '1',
      'name': 'FPV_BTG_PACTUAL_RECAUDADORA',
      'minimum_amount': 75000,
      'category': 'FPV',
      'is_subscribed': false,
      'subscribed_amount': 0.0,
    };

    const tJsonFicCompleto = <String, dynamic>{
      'id': '3',
      'name': 'DEUDAPRIVADA',
      'minimum_amount': 50000,
      'category': 'FIC',
      'is_subscribed': false,
      'subscribed_amount': 0.0,
    };

    const tJsonSinDefaults = <String, dynamic>{
      'id': '1',
      'name': 'FPV_BTG_PACTUAL_RECAUDADORA',
      'minimum_amount': 75000,
      'category': 'FPV',
      // is_subscribed y subscribed_amount ausentes → deben usar @Default
    };

    const tJsonSuscrito = <String, dynamic>{
      'id': '1',
      'name': 'FPV_BTG_PACTUAL_RECAUDADORA',
      'minimum_amount': 75000,
      'category': 'FPV',
      'is_subscribed': true,
      'subscribed_amount': 75000.0,
    };

    // ─── fromJson ────────────────────────────────────────────────────────────

    group('fromJson', () {
      test('parsea id, name, minimumAmount y category correctamente', () {
        // Arrange & Act
        final model = FundModel.fromJson(tJsonFpvCompleto);

        // Assert
        expect(model.id, '1');
        expect(model.name, 'FPV_BTG_PACTUAL_RECAUDADORA');
        expect(model.minimumAmount, 75000.0);
        expect(model.category, 'FPV');
      });

      test('parsea is_subscribed correctamente cuando viene en el JSON', () {
        // Arrange & Act
        final model = FundModel.fromJson(tJsonFpvCompleto);

        // Assert
        expect(model.isSubscribed, isFalse);
      });

      test(
        'parsea subscribed_amount correctamente cuando viene en el JSON',
        () {
          // Arrange & Act
          final model = FundModel.fromJson(tJsonFpvCompleto);

          // Assert
          expect(model.subscribedAmount, 0.0);
        },
      );

      test(
        'usa @Default false para isSubscribed cuando la key está ausente',
        () {
          // Arrange & Act
          final model = FundModel.fromJson(tJsonSinDefaults);

          // Assert
          expect(model.isSubscribed, isFalse);
        },
      );

      test(
        'usa @Default 0.0 para subscribedAmount cuando la key está ausente',
        () {
          // Arrange & Act
          final model = FundModel.fromJson(tJsonSinDefaults);

          // Assert
          expect(model.subscribedAmount, 0.0);
        },
      );

      test(
        'parsea is_subscribed=true y subscribed_amount cuando el fondo está suscrito',
        () {
          // Arrange & Act
          final model = FundModel.fromJson(tJsonSuscrito);

          // Assert
          expect(model.isSubscribed, isTrue);
          expect(model.subscribedAmount, 75000.0);
        },
      );

      test(
        'parsea minimum_amount como entero desde JSON y lo convierte a double',
        () {
          // Arrange — el JSON real de assets usa int (75000, no 75000.0)
          const jsonConInt = <String, dynamic>{
            'id': '1',
            'name': 'FPV_BTG_PACTUAL_RECAUDADORA',
            'minimum_amount': 75000, // int en JSON
            'category': 'FPV',
          };

          // Act
          final model = FundModel.fromJson(jsonConInt);

          // Assert
          expect(model.minimumAmount, isA<double>());
          expect(model.minimumAmount, 75000.0);
        },
      );

      test('parsea category FIC correctamente', () {
        // Arrange & Act
        final model = FundModel.fromJson(tJsonFicCompleto);

        // Assert
        expect(model.category, 'FIC');
      });
    });

    // ─── toEntity ────────────────────────────────────────────────────────────

    group('toEntity', () {
      test('mapea id, name y minimumAmount sin transformación', () {
        // Arrange
        final model = FundModel.fromJson(tJsonFpvCompleto);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.id, model.id);
        expect(entity.name, model.name);
        expect(entity.minimumAmount, model.minimumAmount);
      });

      test('convierte category FPV al enum FundCategory.fpv', () {
        // Arrange
        final model = FundModel.fromJson(tJsonFpvCompleto);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.category, FundCategory.fpv);
      });

      test('convierte category FIC al enum FundCategory.fic', () {
        // Arrange
        final model = FundModel.fromJson(tJsonFicCompleto);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.category, FundCategory.fic);
      });

      test('mapea isSubscribed y subscribedAmount correctamente', () {
        // Arrange
        final model = FundModel.fromJson(tJsonSuscrito);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.isSubscribed, isTrue);
        expect(entity.subscribedAmount, 75000.0);
      });

      test(
        'produce una entidad Fund igual al fixture tFund1 para el JSON de RECAUDADORA',
        () {
          // Arrange
          final model = FundModel.fromJson(tJsonFpvCompleto);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity, equals(TestFixtures.tFund1));
        },
      );

      test(
        'produce una entidad Fund igual al fixture tFund3 para el JSON de DEUDAPRIVADA',
        () {
          // Arrange
          final model = FundModel.fromJson(tJsonFicCompleto);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity, equals(TestFixtures.tFund3));
        },
      );

      test(
        'la entidad resultante tiene isSubscribed=false y subscribedAmount=0 por defecto',
        () {
          // Arrange
          final model = FundModel.fromJson(tJsonSinDefaults);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity.isSubscribed, isFalse);
          expect(entity.subscribedAmount, 0.0);
        },
      );
    });
  });
}
