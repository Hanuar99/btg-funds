import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_helpers.dart';

void main() {
  group('Fund', () {
    // ─── Constructor ────────────────────────────────────────────────────────

    group('constructor - creación con valores dados', () {
      test('asigna correctamente id, name, minimumAmount y category', () {
        // Arrange & Act
        const fund = TestFixtures.tFund1;

        // Assert
        expect(fund.id, '1');
        expect(fund.name, 'FPV_BTG_PACTUAL_RECAUDADORA');
        expect(fund.minimumAmount, 75000.0);
        expect(fund.category, FundCategory.fpv);
      });

      test('isSubscribed es false por defecto cuando no se pasa', () {
        // Arrange & Act
        const fund = TestFixtures.tFund1;

        // Assert
        expect(fund.isSubscribed, isFalse);
      });

      test('subscribedAmount es 0.0 por defecto cuando no se pasa', () {
        // Arrange & Act
        const fund = TestFixtures.tFund1;

        // Assert
        expect(fund.subscribedAmount, 0.0);
      });

      test('acepta FundCategory.fic correctamente', () {
        // Arrange & Act
        const fund = TestFixtures.tFund3;

        // Assert
        expect(fund.category, FundCategory.fic);
      });

      test(
        'acepta isSubscribed true y subscribedAmount cuando se especifican',
        () {
          // Arrange & Act
          final fund = TestFixtures.tFundSubscribed;

          // Assert
          expect(fund.isSubscribed, isTrue);
          expect(fund.subscribedAmount, 75000.0);
        },
      );
    });

    // ─── copyWith ────────────────────────────────────────────────────────────

    group('copyWith', () {
      test(
        'cambia isSubscribed y subscribedAmount sin afectar los demás campos',
        () {
          // Arrange
          const fund = TestFixtures.tFund1;

          // Act
          final subscribed = fund.copyWith(
            isSubscribed: true,
            subscribedAmount: 75000.0,
          );

          // Assert
          expect(subscribed.isSubscribed, isTrue);
          expect(subscribed.subscribedAmount, 75000.0);
          expect(subscribed.id, fund.id);
          expect(subscribed.name, fund.name);
          expect(subscribed.minimumAmount, fund.minimumAmount);
          expect(subscribed.category, fund.category);
        },
      );

      test('cambia solo minimumAmount sin afectar los demás campos', () {
        // Arrange
        const fund = TestFixtures.tFund1;

        // Act
        final updated = fund.copyWith(minimumAmount: 100000.0);

        // Assert
        expect(updated.minimumAmount, 100000.0);
        expect(updated.id, fund.id);
        expect(updated.name, fund.name);
        expect(updated.category, fund.category);
        expect(updated.isSubscribed, fund.isSubscribed);
        expect(updated.subscribedAmount, fund.subscribedAmount);
      });

      test('retorna objeto distinto si se cambia algún campo', () {
        // Arrange
        const fund = TestFixtures.tFund1;

        // Act
        final copy = fund.copyWith(isSubscribed: true);

        // Assert
        expect(copy, isNot(equals(fund)));
      });

      test('retorna objeto igual si no se cambia ningún campo', () {
        // Arrange
        const fund = TestFixtures.tFund1;

        // Act
        final copy = fund.copyWith();

        // Assert
        expect(copy, equals(fund));
      });
    });

    // ─── Equatable ───────────────────────────────────────────────────────────

    group('Equatable - igualdad', () {
      test('dos fondos con exactamente los mismos valores son iguales', () {
        // Arrange
        const fund1 = Fund(
          id: '1',
          name: 'FPV_BTG_PACTUAL_RECAUDADORA',
          minimumAmount: 75000,
          category: FundCategory.fpv,
        );
        const fund2 = Fund(
          id: '1',
          name: 'FPV_BTG_PACTUAL_RECAUDADORA',
          minimumAmount: 75000,
          category: FundCategory.fpv,
        );

        // Assert
        expect(fund1, equals(fund2));
      });

      test('fondos con distinto id no son iguales', () {
        // Arrange
        const fund1 = TestFixtures.tFund1;
        const fund2 = TestFixtures.tFund2;

        // Assert
        expect(fund1, isNot(equals(fund2)));
      });

      test('fondo suscrito y el mismo fondo sin suscribir no son iguales', () {
        // Arrange
        const fund = TestFixtures.tFund1;
        final subscribed = TestFixtures.tFundSubscribed;

        // Assert
        expect(fund, isNot(equals(subscribed)));
      });

      test('fondo FPV y fondo FIC con mismo id no son iguales', () {
        // Arrange
        const fundFpv = Fund(
          id: '99',
          name: 'TEST',
          minimumAmount: 50000,
          category: FundCategory.fpv,
        );
        const fundFic = Fund(
          id: '99',
          name: 'TEST',
          minimumAmount: 50000,
          category: FundCategory.fic,
        );

        // Assert
        expect(fundFpv, isNot(equals(fundFic)));
      });
    });

    // ─── props ───────────────────────────────────────────────────────────────

    group('props - campos de Equatable', () {
      test('props contiene los 6 campos en el orden exacto del código', () {
        // Arrange
        const fund = TestFixtures.tFund1;

        // Assert
        expect(fund.props, [
          fund.id,
          fund.name,
          fund.minimumAmount,
          fund.category,
          fund.isSubscribed,
          fund.subscribedAmount,
        ]);
      });

      test(
        'props de fondo suscrito refleja isSubscribed=true y amount correcto',
        () {
          // Arrange
          final fund = TestFixtures.tFundSubscribed;

          // Assert
          expect(fund.props[4], isTrue); // isSubscribed
          expect(fund.props[5], 75000.0); // subscribedAmount
        },
      );
    });
  });
}
