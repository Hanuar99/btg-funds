import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/features/funds/data/models/fund_model.dart';
import 'package:btg_funds_manager/features/funds/data/repositories/funds_repository_impl.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/user/data/models/user_model.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks/mock_classes.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late FundsRepositoryImpl sut;
  late MockFundsLocalDatasource mockFundsDs;
  late MockUserLocalDatasource mockUserDs;
  late MockNetworkInfo mockNetworkInfo;

  // ─── Models equivalentes a los fixtures de entidades ─────────────────────

  const tFundModel1 = FundModel(
    id: '1',
    name: 'FPV_BTG_PACTUAL_RECAUDADORA',
    minimumAmount: 75000,
    category: 'FPV',
  );

  const tFundModel3 = FundModel(
    id: '3',
    name: 'DEUDAPRIVADA',
    minimumAmount: 50000,
    category: 'FIC',
  );

  const tFundModelSubscribed = FundModel(
    id: '1',
    name: 'FPV_BTG_PACTUAL_RECAUDADORA',
    minimumAmount: 75000,
    category: 'FPV',
    isSubscribed: true,
    subscribedAmount: 75000,
  );

  // Usuario sin fondos suscritos
  const tUserModel = UserModel(id: 'user-001', balance: 500000);
  // Usuario con fondo 1 suscrito
  const tUserModelSuscrito = UserModel(
    id: 'user-001',
    balance: 425000,
    subscribedFunds: {'1': 75000.0},
  );

  /// Stub de red disponible (caso normal).
  void stubOnline() {
    when(
      () => mockNetworkInfo.hasInternetConnection,
    ).thenAnswer((_) async => true);
  }

  /// Stub de red no disponible.
  void stubOffline() {
    when(
      () => mockNetworkInfo.hasInternetConnection,
    ).thenAnswer((_) async => false);
  }

  setUp(() {
    mockFundsDs = MockFundsLocalDatasource();
    mockUserDs = MockUserLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    sut = FundsRepositoryImpl(mockFundsDs, mockUserDs, mockNetworkInfo);
  });

  group('FundsRepositoryImpl', () {
    // ─── getFunds ──────────────────────────────────────────────────────────

    group('getFunds', () {
      test('retorna NetworkFailure cuando no hay conexión', () async {
        // Arrange
        stubOffline();

        // Act
        final result = await sut.getFunds();

        // Assert
        expect(result, const Left<Failure, dynamic>(NetworkFailure()));
        verifyNever(() => mockFundsDs.getFunds());
      });

      test('retorna Right con entities mapeadas desde los models', () async {
        // Arrange
        stubOnline();
        when(
          () => mockFundsDs.getFunds(),
        ).thenAnswer((_) async => [tFundModel1, tFundModel3]);
        when(() => mockUserDs.getUser()).thenAnswer((_) async => tUserModel);

        // Act
        final result = await sut.getFunds();

        // Assert
        result.fold(
          (_) => fail('Debería ser Right'),
          (funds) {
            expect(funds, hasLength(2));
            expect(funds[0], equals(TestFixtures.tFund1));
            expect(funds[1], equals(TestFixtures.tFund3));
          },
        );
      });

      test(
        'marca un fondo como suscrito con el amount del usuario cuando coincide el id',
        () async {
          // Arrange — el usuario tiene el fondo '1' suscrito por 75000
          stubOnline();
          when(
            () => mockFundsDs.getFunds(),
          ).thenAnswer((_) async => [tFundModel1]);
          when(
            () => mockUserDs.getUser(),
          ).thenAnswer((_) async => tUserModelSuscrito);

          // Act
          final result = await sut.getFunds();

          // Assert
          result.fold(
            (_) => fail('Debería ser Right'),
            (funds) {
              final fund = funds.first;
              expect(fund.isSubscribed, isTrue);
              expect(fund.subscribedAmount, 75000.0);
            },
          );
        },
      );

      test(
        'fondos cuyo id NO aparece en subscribedFunds no se marcan como suscritos',
        () async {
          // Arrange — usuario sin fondos; datasource devuelve el fondo 3
          stubOnline();
          when(
            () => mockFundsDs.getFunds(),
          ).thenAnswer((_) async => [tFundModel3]);
          when(() => mockUserDs.getUser()).thenAnswer((_) async => tUserModel);

          // Act
          final result = await sut.getFunds();

          // Assert
          result.fold(
            (_) => fail('Debería ser Right'),
            (funds) {
              expect(funds.first.isSubscribed, isFalse);
              expect(funds.first.subscribedAmount, 0.0);
            },
          );
        },
      );

      test('lista vacía de datasource retorna Right con lista vacía', () async {
        // Arrange
        stubOnline();
        when(() => mockFundsDs.getFunds()).thenAnswer((_) async => []);
        when(() => mockUserDs.getUser()).thenAnswer((_) async => tUserModel);

        // Act
        final result = await sut.getFunds();

        // Assert
        expect(result.isRight(), isTrue);
        result.fold(
          (_) => fail('Debería ser Right'),
          (funds) => expect(funds, isEmpty),
        );
      });

      test(
        'CacheException del datasource se convierte en CacheFailure',
        () async {
          // Arrange
          stubOnline();
          when(
            () => mockFundsDs.getFunds(),
          ).thenThrow(const CacheException('Error de lectura'));
          when(() => mockUserDs.getUser()).thenAnswer((_) async => tUserModel);

          // Act
          final result = await sut.getFunds();

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<CacheFailure>()),
            (_) => fail('Debería ser Left'),
          );
        },
      );
    });

    // ─── subscribeFund ─────────────────────────────────────────────────────

    group('subscribeFund', () {
      test('retorna NetworkFailure cuando no hay conexión', () async {
        // Arrange
        stubOffline();

        // Act
        final result = await sut.subscribeFund(fundId: '1', amount: 75000);

        // Assert
        expect(result, const Left<Failure, dynamic>(NetworkFailure()));
      });

      test(
        'retorna Right con la entity del fondo suscrito en happy path',
        () async {
          // Arrange
          stubOnline();
          when(
            () => mockFundsDs.subscribeFund(
              fundId: any(named: 'fundId'),
              amount: any(named: 'amount'),
            ),
          ).thenAnswer((_) async => tFundModelSubscribed);

          // Act
          final result = await sut.subscribeFund(fundId: '1', amount: 75000);

          // Assert
          expect(result, Right<Failure, Fund>(TestFixtures.tFundSubscribed));
        },
      );

      test(
        'BusinessException con "Ya está suscrito" → AlreadySubscribedFailure',
        () async {
          // Arrange — string EXACTO del código fuente
          stubOnline();
          when(
            () => mockFundsDs.subscribeFund(
              fundId: any(named: 'fundId'),
              amount: any(named: 'amount'),
            ),
          ).thenThrow(
            const BusinessException(
              'Ya está suscrito al fondo FPV_BTG_PACTUAL_RECAUDADORA',
            ),
          );

          // Act
          final result = await sut.subscribeFund(fundId: '1', amount: 75000);

          // Assert
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<AlreadySubscribedFailure>()),
            (_) => fail('Debería ser Left'),
          );
        },
      );

      test(
        'BusinessException con "no encontrado" → FundNotFoundFailure',
        () async {
          // Arrange — string EXACTO del código fuente
          stubOnline();
          when(
            () => mockFundsDs.subscribeFund(
              fundId: any(named: 'fundId'),
              amount: any(named: 'amount'),
            ),
          ).thenThrow(const BusinessException('Fondo 99 no encontrado'));

          // Act
          final result = await sut.subscribeFund(fundId: '99', amount: 75000);

          // Assert
          result.fold(
            (failure) => expect(failure, isA<FundNotFoundFailure>()),
            (_) => fail('Debería ser Left'),
          );
        },
      );

      test(
        'BusinessException sin substring conocido → UnexpectedFailure',
        () async {
          // Arrange
          stubOnline();
          when(
            () => mockFundsDs.subscribeFund(
              fundId: any(named: 'fundId'),
              amount: any(named: 'amount'),
            ),
          ).thenThrow(const BusinessException('Error desconocido'));

          // Act
          final result = await sut.subscribeFund(fundId: '1', amount: 75000);

          // Assert
          result.fold(
            (failure) => expect(failure, isA<UnexpectedFailure>()),
            (_) => fail('Debería ser Left'),
          );
        },
      );

      test(
        'el mensaje del failure conserva el mensaje original de la excepción',
        () async {
          // Arrange
          const tMsg = 'Ya está suscrito al fondo RECAUDADORA';
          stubOnline();
          when(
            () => mockFundsDs.subscribeFund(
              fundId: any(named: 'fundId'),
              amount: any(named: 'amount'),
            ),
          ).thenThrow(const BusinessException(tMsg));

          // Act
          final result = await sut.subscribeFund(fundId: '1', amount: 75000);

          // Assert
          result.fold(
            (failure) => expect(failure.message, tMsg),
            (_) => fail('Debería ser Left'),
          );
        },
      );
    });

    // ─── cancelFund ────────────────────────────────────────────────────────

    group('cancelFund', () {
      test('retorna NetworkFailure cuando no hay conexión', () async {
        // Arrange
        stubOffline();

        // Act
        final result = await sut.cancelFund(fundId: '1');

        // Assert
        expect(result, const Left<Failure, dynamic>(NetworkFailure()));
      });

      test(
        'retorna Right con la entity del fondo cancelado en happy path',
        () async {
          // Arrange — la cancelación devuelve el fondo con isSubscribed=false
          stubOnline();
          when(
            () => mockFundsDs.cancelFund(fundId: any(named: 'fundId')),
          ).thenAnswer((_) async => tFundModel1);

          // Act
          final result = await sut.cancelFund(fundId: '1');

          // Assert
          expect(result, Right<Failure, Fund>(TestFixtures.tFund1));
        },
      );

      test(
        'BusinessException con "No está suscrito" → NotSubscribedFailure',
        () async {
          // Arrange — string EXACTO del código fuente
          stubOnline();
          when(
            () => mockFundsDs.cancelFund(fundId: any(named: 'fundId')),
          ).thenThrow(
            const BusinessException('No está suscrito al fondo 1'),
          );

          // Act
          final result = await sut.cancelFund(fundId: '1');

          // Assert
          result.fold(
            (failure) => expect(failure, isA<NotSubscribedFailure>()),
            (_) => fail('Debería ser Left'),
          );
        },
      );

      test(
        'BusinessException con "no encontrado" → FundNotFoundFailure',
        () async {
          // Arrange
          stubOnline();
          when(
            () => mockFundsDs.cancelFund(fundId: any(named: 'fundId')),
          ).thenThrow(const BusinessException('Fondo 99 no encontrado'));

          // Act
          final result = await sut.cancelFund(fundId: '99');

          // Assert
          result.fold(
            (failure) => expect(failure, isA<FundNotFoundFailure>()),
            (_) => fail('Debería ser Left'),
          );
        },
      );

      test(
        'el mensaje del failure conserva el mensaje original de la excepción',
        () async {
          // Arrange
          const tMsg = 'No está suscrito al fondo RECAUDADORA';
          stubOnline();
          when(
            () => mockFundsDs.cancelFund(fundId: any(named: 'fundId')),
          ).thenThrow(const BusinessException(tMsg));

          // Act
          final result = await sut.cancelFund(fundId: '1');

          // Assert
          result.fold(
            (failure) => expect(failure.message, tMsg),
            (_) => fail('Debería ser Left'),
          );
        },
      );
    });
  });
}
