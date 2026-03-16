import 'dart:convert';

import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/logger/app_logger.dart';
import 'package:btg_funds_manager/core/storage/storage_service.dart';
import 'package:btg_funds_manager/features/transactions/data/models/transaction_model.dart';
import 'package:injectable/injectable.dart';

abstract class TransactionsLocalDatasource {
  Future<List<TransactionModel>> getTransactions();

  Future<TransactionModel> addTransaction(TransactionModel model);
}

@LazySingleton(as: TransactionsLocalDatasource)
class TransactionsLocalDatasourceImpl implements TransactionsLocalDatasource {
  TransactionsLocalDatasourceImpl(this._storageService);
  final StorageService _storageService;

  // Simula latencia de red. En producción, reemplazar con llamadas HTTP reales.
  static const Duration _getTransactionsDelay = Duration(milliseconds: 300);
  static const Duration _addTransactionDelay = Duration(milliseconds: 200);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    await Future<void>.delayed(_getTransactionsDelay);
    return _loadTransactionsFromStorage();
  }

  Future<List<TransactionModel>> _loadTransactionsFromStorage() async {
    try {
      final jsonString = await _storageService.read<String>(
        StorageKeys.transactions,
      );
      if (jsonString == null) {
        AppLogger.debug('Historial vacio - primera vez');
        return [];
      }

      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final models = jsonList
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      AppLogger.debug('Historial cargado: ${models.length} transacciones');
      return models;
    } catch (e, stack) {
      AppLogger.error(
        'TransactionsDatasource.getTransactions error',
        error: e,
        stackTrace: stack,
      );
      throw CacheException('Error al cargar historial: $e');
    }
  }

  @override
  Future<TransactionModel> addTransaction(TransactionModel model) async {
    await Future<void>.delayed(_addTransactionDelay);

    try {
      // Cargar lista existente.
      final existing = await _loadTransactionsFromStorage();
      // Agregar nueva al inicio (orden cronologico descendente).
      final updated = [model, ...existing];
      // Serializar y guardar.
      final jsonString = jsonEncode(updated.map((t) => t.toJson()).toList());
      await _storageService.write(
        StorageKeys.transactions,
        jsonString,
      );
      AppLogger.info(
        'Transacción guardada: ${model.type} - ${model.fundName} - COP ${model.amount}',
      );
      return model;
    } catch (e, stack) {
      AppLogger.error(
        'TransactionsDatasource.addTransaction error',
        error: e,
        stackTrace: stack,
      );
      throw CacheException('Error al guardar transacción: $e');
    }
  }
}
