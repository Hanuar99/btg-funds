/// Escala principal de spacing en multiplos de 4px.
/// Se incluyen tokens micro para casos puntuales de densidad visual.
abstract class AppSpacing {
  static const double micro = 2;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  // Tokens de componente para evitar valores literales en temas/widgets.
  static const double borderThin = 1;
  static const double buttonVertical = 14;
  static const double compact = 6;
  static const double grid = 12;
  static const double controlHeight = 36;
  static const double buttonHeight = 48;
  static const double buttonHeightLarge = 52;
}
