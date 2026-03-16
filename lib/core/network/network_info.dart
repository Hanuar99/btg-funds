import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Contrato para consultar el estado de conectividad con internet.
abstract class NetworkInfo {
  /// Retorna `true` si el dispositivo tiene transporte de red y salida a internet.
  Future<bool> get hasInternetConnection;
}

@LazySingleton(as: NetworkInfo)
class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl(this._connectivity, this._connectionChecker);

  final Connectivity _connectivity;
  final InternetConnection _connectionChecker;

  @override
  Future<bool> get hasInternetConnection async {
    final results = await _connectivity.checkConnectivity();

    final hasTransport = results.any(
      (result) => result != ConnectivityResult.none,
    );

    if (!hasTransport) {
      return false;
    }

    return _connectionChecker.hasInternetAccess;
  }
}
