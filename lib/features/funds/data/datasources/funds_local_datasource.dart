import 'dart:convert';

import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/logger/app_logger.dart';
import 'package:btg_funds_manager/features/funds/data/models/fund_model.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

abstract class FundsLocalDatasource {
  Future<List<FundModel>> getFunds();

  Future<FundModel> subscribeFund({
    required String fundId,
    required double amount,
  });

  Future<FundModel> cancelFund({required String fundId});
}

@LazySingleton(as: FundsLocalDatasource)
class FundsLocalDatasourceImpl implements FundsLocalDatasource {
  FundsLocalDatasourceImpl();

  // Simula latencia de red. En producción, reemplazar con llamadas HTTP reales.
  static const Duration _simulatedDelay = Duration(milliseconds: 600);

  List<FundModel> _funds = [];
  bool _initialized = false;

  @override
  Future<List<FundModel>> getFunds() async {
    await Future<void>.delayed(_simulatedDelay);
    if (!_initialized) await _loadFromAssets();
    return List<FundModel>.unmodifiable(_funds);
  }

  /// Valida que el fondo exista y retorna su modelo base.
  /// La verificación de suscripción duplicada es responsabilidad del repositorio.
  @override
  Future<FundModel> subscribeFund({
    required String fundId,
    required double amount,
  }) async {
    await Future<void>.delayed(_simulatedDelay);
    if (!_initialized) await _loadFromAssets();

    final fund = _findFund(fundId);
    AppLogger.info('Fondo validado para suscripción: ${fund.name}');
    return fund;
  }

  /// Valida que el fondo exista y retorna su modelo base.
  /// La verificación de "está suscrito" es responsabilidad del repositorio.
  @override
  Future<FundModel> cancelFund({required String fundId}) async {
    await Future<void>.delayed(_simulatedDelay);
    if (!_initialized) await _loadFromAssets();

    final fund = _findFund(fundId);
    AppLogger.info('Fondo validado para cancelación: ${fund.name}');
    return fund;
  }

  FundModel _findFund(String fundId) {
    final fund = _funds.firstWhere(
      (f) => f.id == fundId,
      orElse: () => throw BusinessException('Fondo $fundId no encontrado'),
    );
    return fund;
  }

  Future<void> _loadFromAssets() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/funds.json');
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      _funds = decoded
          .map((item) => FundModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: true);
      _initialized = true;
      AppLogger.debug('Fondos cargados desde assets: ${_funds.length}');
    } on Object catch (e, stackTrace) {
      AppLogger.error(
        'Error cargando fondos desde assets',
        error: e,
        stackTrace: stackTrace,
      );
      throw const CacheException('No fue posible cargar los fondos locales');
    }
  }
}
