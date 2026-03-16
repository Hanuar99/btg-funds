import 'package:btg_funds_manager/core/errors/failures.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

/// Interfaz base para todos los casos de uso del proyecto.
abstract class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

/// Usar cuando el caso de uso no necesita parametros.
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
