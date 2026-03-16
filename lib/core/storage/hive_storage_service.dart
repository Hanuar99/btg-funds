import 'package:btg_funds_manager/core/errors/exceptions.dart';
import 'package:btg_funds_manager/core/logger/app_logger.dart';
import 'package:btg_funds_manager/core/storage/storage_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: StorageService)
class HiveStorageService implements StorageService {
  static const String _boxName = 'btg_box';

  Box<dynamic>? _box;

  @override
  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
    AppLogger.info('HiveStorageService inicializado');
  }

  // Helper privado que garantiza que el box este abierto.
  Box<dynamic> get _openBox {
    if (_box == null || !_box!.isOpen) {
      throw const CacheException(
        'Hive box no inicializado - llama init() primero',
      );
    }
    return _box!;
  }

  @override
  Future<void> clear() async {
    await _openBox.clear();
  }

  @override
  Future<bool> containsKey(String key) async {
    return _openBox.containsKey(key);
  }

  @override
  Future<void> delete(String key) async {
    await _openBox.delete(key);
  }

  @override
  Future<T?> read<T>(String key) async {
    AppLogger.debug('Storage read: $key');
    final value = _openBox.get(key);
    return value as T?;
  }

  @override
  Future<void> write(String key, dynamic value) async {
    await _openBox.put(key, value);
    AppLogger.debug('Storage.write: $key');
  }
}
