import 'package:btg_funds_manager/app.dart';
import 'package:btg_funds_manager/core/di/injection.dart';
import 'package:btg_funds_manager/core/logger/app_logger.dart';
import 'package:btg_funds_manager/core/storage/storage_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. Inicializar datos de fechas para locale es
  await initializeDateFormatting('es');

  // 1. Inicializar Hive
  await Hive.initFlutter();

  // 2. Registrar dependencias con GetIt
  await configureDependencies();

  // 3. Inicializar el StorageService .
  await getIt<StorageService>().init();

  // 4. Registrar el observer de BLoC para logs
  Bloc.observer = AppBlocObserver();

  AppLogger.info('App BTG Fondos iniciado correctamente');

  runApp(const BtgFondosApp());
}
