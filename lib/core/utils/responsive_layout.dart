import 'package:flutter/material.dart';

/// Breakpoints del layout responsivo.
abstract class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 900;
  static const double web = 1200;
}

/// Widget que construye UI diferente según el ancho de pantalla.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.mobile,
    this.tablet,
    this.web,
    super.key,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget? web;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < Breakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.mobile &&
      MediaQuery.of(context).size.width < Breakpoints.tablet;

  static bool isWeb(BuildContext context) =>
      MediaQuery.of(context).size.width >= Breakpoints.tablet;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= Breakpoints.tablet && web != null) {
      return web!;
    }
    if (width >= Breakpoints.mobile && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

/// Contenedor centrado para web con max-width.
class WebContainer extends StatelessWidget {
  const WebContainer({
    required this.child,
    this.maxWidth = Breakpoints.web,
    super.key,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
