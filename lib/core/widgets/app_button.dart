import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:flutter/material.dart';

/// Variantes visuales.
enum AppButtonVariant {
  /// Botón primario con fondo de color primario.
  primary,

  /// Botón de acción destructiva con fondo de color error.
  danger,

  /// Botón contorneado con borde y texto en color primario.
  outlinePrimary,

  /// Botón contorneado con borde y texto en color error.
  outlineDanger,
}

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoading();

    final shape = RoundedRectangleBorder(borderRadius: AppRadius.mdRadius);
    const size = Size(double.infinity, AppSpacing.buttonHeight);

    return switch (variant) {
      AppButtonVariant.primary => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(shape: shape, minimumSize: size),
          child: Text(label),
        ),
      ),
      AppButtonVariant.danger => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: AppColors.textOnPrimary,
            shape: shape,
            minimumSize: size,
          ),
          child: Text(label),
        ),
      ),
      AppButtonVariant.outlinePrimary => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            shape: shape,
            minimumSize: size,
          ),
          child: Text(label),
        ),
      ),
      AppButtonVariant.outlineDanger => SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            side: const BorderSide(color: AppColors.error),
            shape: shape,
            minimumSize: size,
          ),
          child: Text(label),
        ),
      ),
    };
  }

  Widget _buildLoading() {
    final shape = RoundedRectangleBorder(borderRadius: AppRadius.mdRadius);
    const size = Size(double.infinity, AppSpacing.buttonHeight);
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          disabledBackgroundColor: AppColors.primaryLight,
          shape: shape,
          minimumSize: size,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Procesando...',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
