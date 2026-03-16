import 'dart:convert';

import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/logger/app_logger.dart';
import 'package:btg_funds_manager/core/storage/storage_service.dart';
import 'package:btg_funds_manager/features/user/data/models/user_model.dart';
import 'package:btg_funds_manager/features/user/domain/entities/user.dart';
import 'package:injectable/injectable.dart';

abstract class UserLocalDatasource {
  Future<UserModel> getUser();

  Future<UserModel> updateUser(UserModel model);
}

@LazySingleton(as: UserLocalDatasource)
class UserLocalDatasourceImpl implements UserLocalDatasource {
  UserLocalDatasourceImpl(this._storageService);
  final StorageService _storageService;

  @override
  Future<UserModel> getUser() async {
    try {
      // Leer balance guardado, o usar el inicial si es la primera vez.
      final savedBalance = await _storageService.read<double>(
        StorageKeys.userBalance,
      );
      final balance = savedBalance ?? User.initialBalance;

      // Leer userId, o crear uno nuevo.
      var userId = await _storageService.read<String>(StorageKeys.userId);
      if (userId == null) {
        userId = 'user-001';
        await _storageService.write(StorageKeys.userId, userId);
      }

      // Leer fondos suscritos.
      // Formato nuevo: Map<String, double> (fundId → amount).
      // Formato legacy: List<String> — migración transparente en primera lectura.
      final fundsJson = await _storageService.read<String>(
        StorageKeys.subscribedFunds,
      );
      var subscribedFunds = <String, double>{};
      if (fundsJson != null) {
        final decoded = jsonDecode(fundsJson);
        if (decoded is Map) {
          subscribedFunds = decoded.map(
            (k, v) => MapEntry(k as String, (v as num).toDouble()),
          );
        } else if (decoded is List) {
          // Migración silenciosa: datos legacy solo tenían IDs; amount desconocido.
          subscribedFunds = {for (final id in decoded) id as String: 0.0};
          AppLogger.info(
            'UserDatasource: migrando subscribedFunds de List a Map',
          );
        }
      }

      AppLogger.debug(
        'Usuario cargado: saldo ${balance.toStringAsFixed(0)}, '
        'fondos suscriptos: ${subscribedFunds.length}',
      );

      return UserModel(
        id: userId,
        balance: balance,
        subscribedFunds: subscribedFunds,
      );
    } catch (e, stack) {
      AppLogger.error(
        'UserDatasource.getUser error',
        error: e,
        stackTrace: stack,
      );
      throw CacheException('Error al cargar usuario: $e');
    }
  }

  @override
  Future<UserModel> updateUser(UserModel model) async {
    try {
      await _storageService.write(
        StorageKeys.userBalance,
        model.balance,
      );
      await _storageService.write(
        StorageKeys.subscribedFunds,
        jsonEncode(model.subscribedFunds),
      );
      AppLogger.debug(
        'Usuario guardado: saldo ${model.balance.toStringAsFixed(0)}',
      );
      return model;
    } catch (e, stack) {
      AppLogger.error(
        'UserDatasource.updateUser error',
        error: e,
        stackTrace: stack,
      );
      throw CacheException('Error al guardar usuario: $e');
    }
  }
}
