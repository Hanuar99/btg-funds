import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:flutter/material.dart';

/// Superficie visual reutilizable para tarjetas con borde y radio consistentes.
class AppCardSurface extends StatelessWidget {
  const AppCardSurface({
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.backgroundCard,
        borderRadius: borderRadius ?? AppRadius.lgRadius,
        border: Border.all(color: borderColor ?? AppColors.border),
      ),
      child: child,
    );
  }
}
