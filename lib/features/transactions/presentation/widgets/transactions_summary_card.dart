import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/widgets/app_card_surface.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsSummaryCard extends StatelessWidget {
  const TransactionsSummaryCard({this.margin, super.key});

  /// Margin aplicado al [AppCardSurface]. Si es null usa el valor por defecto
  /// horizontal para mobile: [AppSpacing.md].
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        final transactions = state.maybeWhen(
          loaded: (loadedTransactions) => loadedTransactions,
          orElse: () => <Transaction>[],
        );

        if (transactions.isEmpty) {
          return const SizedBox.shrink();
        }

        final totalSubscriptions = transactions
            .where(
              (transaction) => transaction.type == TransactionType.subscription,
            )
            .length;
        final totalCancellations = transactions
            .where(
              (transaction) => transaction.type == TransactionType.cancellation,
            )
            .length;

        return AppCardSurface(
          margin:
              margin ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _SummaryStatItem(
                  label: 'Total',
                  value: '${transactions.length}',
                  icon: Icons.receipt_long_outlined,
                  iconBg: AppColors.backgroundSecondary,
                ),
              ),
              const _SummaryDivider(),
              Expanded(
                child: _SummaryStatItem(
                  label: 'Suscrip.',
                  value: '$totalSubscriptions',
                  color: AppColors.primary,
                  icon: Icons.trending_up,
                  iconBg: AppColors.primaryLight,
                ),
              ),
              const _SummaryDivider(),
              Expanded(
                child: _SummaryStatItem(
                  label: 'Cancelac.',
                  value: '$totalCancellations',
                  color: AppColors.warning,
                  icon: Icons.trending_down,
                  iconBg: AppColors.warningLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryStatItem extends StatelessWidget {
  const _SummaryStatItem({
    required this.label,
    required this.value,
    this.color = AppColors.textPrimary,
    this.icon,
    this.iconBg,
  });

  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  final Color? iconBg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg ?? AppColors.backgroundSecondary,
              borderRadius: AppRadius.smRadius,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              value,
              style: AppTypography.titleMedium.copyWith(color: color),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  const _SummaryDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.borderThin,
      height: AppSpacing.xl,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: AppColors.divider,
    );
  }
}
