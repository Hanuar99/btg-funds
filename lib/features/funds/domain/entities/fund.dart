import 'package:equatable/equatable.dart';

/// Categoria de fondo de inversion.
enum FundCategory { fpv, fic }

/// Entidad inmutable que representa un fondo disponible para el usuario.
class Fund extends Equatable {
  const Fund({
    required this.id,
    required this.name,
    required this.minimumAmount,
    required this.category,
    this.isSubscribed = false,
    this.subscribedAmount = 0.0,
  });

  /// Identificador unico del fondo.
  final String id;

  /// Nombre comercial del fondo.
  final String name;

  /// Monto minimo en COP para suscribirse.
  final double minimumAmount;

  /// Categoria a la que pertenece el fondo (FPV o FIC).
  final FundCategory category;

  /// Si el usuario actual esta suscrito.
  final bool isSubscribed;

  /// Monto invertido en COP.
  final double subscribedAmount;

  Fund copyWith({
    String? id,
    String? name,
    double? minimumAmount,
    FundCategory? category,
    bool? isSubscribed,
    double? subscribedAmount,
  }) {
    return Fund(
      id: id ?? this.id,
      name: name ?? this.name,
      minimumAmount: minimumAmount ?? this.minimumAmount,
      category: category ?? this.category,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      subscribedAmount: subscribedAmount ?? this.subscribedAmount,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    minimumAmount,
    category,
    isSubscribed,
    subscribedAmount,
  ];
}
