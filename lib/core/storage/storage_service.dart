abstract class StorageService {
  Future<void> init();

  Future<void> write(String key, dynamic value);

  Future<T?> read<T>(String key);

  Future<void> delete(String key);

  Future<void> clear();

  Future<bool> containsKey(String key);
}

/// Centralizar aqui TODAS las keys de almacenamiento evita typos.
abstract class StorageKeys {
  static const String userBalance = 'user.balance';
  static const String subscribedFunds = 'user.subscribed_funds';
  static const String transactions = 'transactions.history';
  static const String userId = 'user.id';
}
