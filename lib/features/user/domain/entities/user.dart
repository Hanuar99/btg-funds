import 'package:equatable/equatable.dart';

/// Entidad inmutable que representa al usuario de la aplicacion.
class User extends Equatable {
  const User({
    required this.id,
    required this.balance,
    this.subscribedFunds = const {},
  });

  static const double initialBalance = 500000;

  final String id;
  final double balance;

  /// Mapa de fondos suscritos: fundId → monto invertido por el usuario.
  final Map<String, double> subscribedFunds;

  /// Vista de solo los IDs de fondos suscritos.
  List<String> get subscribedFundIds => subscribedFunds.keys.toList();

  User copyWith({
    String? id,
    double? balance,
    Map<String, double>? subscribedFunds,
  }) {
    return User(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      subscribedFunds: subscribedFunds ?? this.subscribedFunds,
    );
  }

  @override
  List<Object?> get props => [id, balance, subscribedFunds];
}
