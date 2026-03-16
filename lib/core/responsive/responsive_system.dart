import 'package:flutter/material.dart';

/// Breakpoints de la app BTG
abstract class Breakpoints {
  static const double mobile = 0;
  static const double tablet = 600;
  static const double web = 900;
  static const double wide = 1200;
}

/// Tipo de dispositivo actual.
enum DeviceType { mobile, tablet, web }

/// Extension en BuildContext para acceso rapido.
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;

  double get screenHeight => MediaQuery.of(this).size.height;

  DeviceType get device {
    final w = screenWidth;
    if (w >= Breakpoints.web) {
      return DeviceType.web;
    }
    if (w >= Breakpoints.tablet) {
      return DeviceType.tablet;
    }
    return DeviceType.mobile;
  }

  bool get isMobile => device == DeviceType.mobile;

  bool get isTablet => device == DeviceType.tablet;

  bool get isWeb => device == DeviceType.web;

  /// Numero de columnas para el grid de fondos.
  int get fundGridColumns {
    if (screenWidth >= Breakpoints.wide) {
      return 3;
    }
    if (isWeb) {
      return 2;
    }
    if (isTablet) {
      return 2;
    }
    return 1;
  }

  /// Padding horizontal del contenido.
  double get horizontalPadding {
    if (isWeb) {
      return 32;
    }
    if (isTablet) {
      return 24;
    }
    return 16;
  }

  /// Max width del contenido principal en web.
  double get contentMaxWidth => 1100;

  /// Altura expandida del app bar principal en mobile.
  double get mobileHeaderExpandedHeight => 200;

  /// Altura expandida para app bars secundarios en mobile.
  double get mobileSecondaryHeaderExpandedHeight => 100;

  /// Ancho recomendado para dialogs de detalle en web.
  double get webDialogWidth => 480;

  /// Relación de aspecto recomendada para grids de fondos en web.
  double fundsGridAspectRatio(double maxWidth) {
    if (maxWidth > 1200) {
      return 2;
    }
    if (maxWidth > 1000) {
      return 1.85;
    }
    return 1.7;
  }
}

/// Contenedor con max-width centrado para web.
class CenteredContent extends StatelessWidget {
  const CenteredContent({
    required this.child,
    this.maxWidth,
    this.padding,
    super.key,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? context.contentMaxWidth,
        ),
        child: Padding(
          padding:
              padding ??
              EdgeInsets.symmetric(
                horizontal: context.horizontalPadding,
              ),
          child: child,
        ),
      ),
    );
  }
}
