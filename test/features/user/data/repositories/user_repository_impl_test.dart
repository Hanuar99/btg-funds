import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:btg_funds_manager/features/user/data/models/user_model.dart';
import 'package:btg_funds_manager/features/user/data/repositories/user_repository_impl.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/mocks/mock_classes.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  late UserRepositoryImpl sut;
  late MockUserLocalDatasource mockDatasource;
  late MockNetworkInfo mockNetworkInfo;

  // ─── Models usados en los tests ───────────────────────────────────────────

  const tUserModel = UserModel(id: 'user-001', balance: 500000);
  const tUserModelUpdatedBalance = UserModel(id: 'user-001', balance: 300000);
  const tUserModelWithFund = UserModel(
    id: 'user-001',
    balance: 500000,
    subscribedFunds: {'1': 75000.0},
  );
  const tUserModelAfterRemove = UserModel(
    id: 'user-001',
    balance: 500000,
  );

  void stubOnline() {
    when(
      () => mockNetworkInfo.hasInternetConnection,
    ).thenAnswer((_) async => true);
  }

  void stubOffline() {
    when(
      () => mockNetworkInfo.hasInternetConnection,
    ).thenAnswer((_) async => false);
  }

  setUpAll(registerFallbackValues);

  setUp(() {
    mockDatasource = MockUserLocalDatasource();
    mockNetworkInfo = MockNetworkInfo();
    sut = UserRepositoryImpl(mockDatasource, mockNetworkInfo);
  });

  group('UserRepositoryImpl', () {
    // ─── getUser ───────────────────────────────────────────────────────────

    group('getUser', () {
      test('retorna NetworkFailure cuando no hay conexión', () async {
        // Arrange
        stubOffline();

        // Act
        final result = await sut.getUser();

        // Assert
        expect(result, const Left<Failure, dynamic>(NetworkFailure()));
        verifyNever(() => mockDatasource.getUser());
      });

      test('retorna Right con la entity del usuario en happy path', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenAnswer((_) async => tUserModel);

        // Act
        final result = await sut.getUser();

        // Assert
        result.fold(
          (_) => fail('Debería ser Right'),
          (user) {
            expect(user.id, tUserModel.id);
            expect(user.balance, tUserModel.balance);
          },
        );
      });

      test('CacheException se convierte en CacheFailure', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenThrow(const CacheException('Error al leer usuario'));

        // Act
        final result = await sut.getUser();

        // Assert
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Debería ser Left'),
        );
      });
    });

    // ─── updateBalance ─────────────────────────────────────────────────────

    group('updateBalance', () {
      test('retorna NetworkFailure cuando no hay conexión', () async {
        // Arrange
        stubOffline();

        // Act
        final result = await sut.updateBalance(300000);

        // Assert
        expect(result, const Left<Failure, dynamic>(NetworkFailure()));
        verifyNever(() => mockDatasource.getUser());
        verifyNever(() => mockDatasource.updateUser(any()));
      });

      test('lee el usuario actual antes de actualizar el balance', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenAnswer((_) async => tUserModel);
        when(
          () => mockDatasource.updateUser(any()),
        ).thenAnswer((_) async => tUserModelUpdatedBalance);

        // Act
        await sut.updateBalance(300000);

        // Assert
        verifyInOrder([
          () => mockDatasource.getUser(),
          () => mockDatasource.updateUser(any()),
        ]);
      });

      test('pasa al datasource el model con el nuevo balance', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenAnswer((_) async => tUserModel);
        when(
          () => mockDatasource.updateUser(any()),
        ).thenAnswer((_) async => tUserModelUpdatedBalance);

        // Act
        await sut.updateBalance(300000);

        // Assert
        final captured =
            verify(
                  () => mockDatasource.updateUser(captureAny()),
                ).captured.first
                as UserModel;

        expect(captured.balance, 300000);
        expect(captured.id, tUserModel.id);
      });

      test('retorna Right con la entity actualizada en happy path', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenAnswer((_) async => tUserModel);
        when(
          () => mockDatasource.updateUser(any()),
        ).thenAnswer((_) async => tUserModelUpdatedBalance);

        // Act
        final result = await sut.updateBalance(300000);

        // Assert
        result.fold(
          (_) => fail('Debería ser Right'),
          (user) => expect(user.balance, 300000),
        );
      });
    });

    // ─── addSubscribedFund ─────────────────────────────────────────────────

    group('addSubscribedFund', () {
      test('retorna NetworkFailure cuando no hay conexión', () async {
        // Arrange
        stubOffline();

        // Act
        final result = await sut.addSubscribedFund('1', 75000);

        // Assert
        expect(result, const Left<Failure, dynamic>(NetworkFailure()));
      });

      test(
        'añade el fondo al map subscribedFunds existente (upsert)',
        () async {
          // Arrange
          stubOnline();
          when(
            () => mockDatasource.getUser(),
          ).thenAnswer((_) async => tUserModel);
          when(
            () => mockDatasource.updateUser(any()),
          ).thenAnswer((_) async => tUserModelWithFund);

          // Act
          await sut.addSubscribedFund('1', 75000);

          // Assert
          final captured =
              verify(
                    () => mockDatasource.updateUser(captureAny()),
                  ).captured.first
                  as UserModel;

          expect(captured.subscribedFunds['1'], 75000.0);
        },
      );

      test('sobreescribe el valor si el fondo ya existía (upsert)', () async {
        // Arrange — usuario con fondo 1 ya suscrito; se actualiza el amount
        const tUserConFondo = UserModel(
          id: 'user-001',
          balance: 500000,
          subscribedFunds: {'1': 50000.0},
        );
        const tUserActualizado = UserModel(
          id: 'user-001',
          balance: 500000,
          subscribedFunds: {'1': 100000.0},
        );
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenAnswer((_) async => tUserConFondo);
        when(
          () => mockDatasource.updateUser(any()),
        ).thenAnswer((_) async => tUserActualizado);

        // Act
        await sut.addSubscribedFund('1', 100000);

        // Assert
        final captured =
            verify(
                  () => mockDatasource.updateUser(captureAny()),
                ).captured.first
                as UserModel;

        expect(captured.subscribedFunds['1'], 100000.0);
      });

      test('retorna Right con la entity actualizada en happy path', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenAnswer((_) async => tUserModel);
        when(
          () => mockDatasource.updateUser(any()),
        ).thenAnswer((_) async => tUserModelWithFund);

        // Act
        final result = await sut.addSubscribedFund('1', 75000);

        // Assert
        result.fold(
          (_) => fail('Debería ser Right'),
          (user) => expect(user.subscribedFunds['1'], 75000.0),
        );
      });
    });

    // ─── removeSubscribedFund ──────────────────────────────────────────────

    group('removeSubscribedFund', () {
      test('retorna NetworkFailure cuando no hay conexión', () async {
        // Arrange
        stubOffline();

        // Act
        final result = await sut.removeSubscribedFund('1');

        // Assert
        expect(result, const Left<Failure, dynamic>(NetworkFailure()));
      });

      test('remueve el fondo del map subscribedFunds', () async {
        // Arrange — usuario que tiene el fondo '1'
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenAnswer((_) async => tUserModelWithFund);
        when(
          () => mockDatasource.updateUser(any()),
        ).thenAnswer((_) async => tUserModelAfterRemove);

        // Act
        await sut.removeSubscribedFund('1');

        // Assert
        final captured =
            verify(
                  () => mockDatasource.updateUser(captureAny()),
                ).captured.first
                as UserModel;

        expect(captured.subscribedFunds.containsKey('1'), isFalse);
      });

      test('retorna Right con la entity actualizada en happy path', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenAnswer((_) async => tUserModelWithFund);
        when(
          () => mockDatasource.updateUser(any()),
        ).thenAnswer((_) async => tUserModelAfterRemove);

        // Act
        final result = await sut.removeSubscribedFund('1');

        // Assert
        result.fold(
          (_) => fail('Debería ser Right'),
          (user) => expect(user.subscribedFunds.containsKey('1'), isFalse),
        );
      });

      test('CacheException al leer se convierte en CacheFailure', () async {
        // Arrange
        stubOnline();
        when(
          () => mockDatasource.getUser(),
        ).thenThrow(const CacheException('Error al leer'));

        // Act
        final result = await sut.removeSubscribedFund('1');

        // Assert
        result.fold(
          (failure) => expect(failure, isA<CacheFailure>()),
          (_) => fail('Debería ser Left'),
        );
      });
    });
  });
}
