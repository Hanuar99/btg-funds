import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/widgets/app_button.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_bloc.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_event.dart';
import 'package:btg_funds_manager/features/funds/presentation/helpers/funds_helpers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Muestra el diálogo de confirmación para cancelar la participación en un fondo.
Future<void> showCancelFundDialog(BuildContext context, Fund fund) {
  final bloc = context.read<FundsBloc>();
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => BlocProvider.value(
      value: bloc,
      child: CancelFundDialog(fund: fund),
    ),
  );
}

/// Widget del diálogo de cancelación de participación en un fondo.
class CancelFundDialog extends StatelessWidget {
  const CancelFundDialog({required this.fund, super.key});

  final Fund fund;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      surfaceTintColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgRadius),
      title: const _DialogHeader(),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Deseas cancelar tu participación en este fondo?',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.backgroundSecondary,
              borderRadius: AppRadius.mdRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Text(fund.name, style: AppTypography.titleMedium),
          ),
          const SizedBox(height: AppSpacing.md),
          _ReintegroInfo(amount: fund.subscribedAmount),
          const SizedBox(height: AppSpacing.sm),
          const _WarningInfo(),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Mantener',
                  onPressed: () => Navigator.of(context).pop(),
                  variant: AppButtonVariant.outlinePrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: AppButton(
                  label: 'Sí, cancelar',
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<FundsBloc>().add(
                      FundsEvent.cancelRequested(fund: fund),
                    );
                  },
                  variant: AppButtonVariant.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Widgets internos ────────────────────────────────────────────────────────

class _ReintegroInfo extends StatelessWidget {
  const _ReintegroInfo({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: AppColors.success),
      ),
      child: Row(
        children: [
          const Icon(Icons.account_balance_wallet, color: AppColors.success),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Se reintegrará a tu saldo:',
                  style: AppTypography.bodySmall,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  formatCOP(amount),
                  style: AppTypography.currencyMedium.copyWith(
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: AppColors.errorLight,
            borderRadius: AppRadius.fullRadius,
          ),
          child: const Icon(
            Icons.warning_rounded,
            color: AppColors.error,
            size: 20,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            'Cancelar participación',
            style: AppTypography.titleLarge.copyWith(color: AppColors.error),
          ),
        ),
      ],
    );
  }
}

class _WarningInfo extends StatelessWidget {
  const _WarningInfo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: AppRadius.mdRadius,
      ),
      child: Text(
        'La cancelación se procesará de inmediato y liberará este monto en tu saldo.',
        style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
      ),
    );
  }
}
