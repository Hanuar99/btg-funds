import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/utils/currency_formatter.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/transactions/presentation/utils/transaction_date_formatter.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/notification_method_chip.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/transaction_type_badge.dart';
import 'package:flutter/material.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({required this.transaction, super.key});
  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final isSubscription = transaction.type == TransactionType.subscription;
    final amountColor = isSubscription ? AppColors.error : AppColors.success;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3,
              height: double.infinity,
              decoration: BoxDecoration(
                color: isSubscription ? AppColors.primary : AppColors.success,
                borderRadius: AppRadius.fullRadius,
              ),
            ),
            const SizedBox(width: AppSpacing.grid),
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.buttonVertical,
              ),
              child: _TransactionIcon(isSubscription: isSubscription),
            ),
            const SizedBox(width: AppSpacing.grid),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.buttonVertical,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.fundName,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        TransactionTypeBadge(isSubscription: isSubscription),
                        if (transaction.notificationMethod != null) ...[
                          const SizedBox(width: AppSpacing.compact),
                          NotificationMethodChip(
                            method: transaction.notificationMethod!,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      TransactionDateFormatter.transactionDateTime(
                        transaction.date,
                      ),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.grid,
                AppSpacing.buttonVertical,
                AppSpacing.md,
                AppSpacing.buttonVertical,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isSubscription ? '-' : '+'}${_formatCOP(transaction.amount)}',
                    style: AppTypography.bodyMedium.copyWith(
                      color: amountColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'COP',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCOP(double amount) {
    return CurrencyFormatter.cop(amount);
  }
}

class _TransactionIcon extends StatelessWidget {
  const _TransactionIcon({required this.isSubscription});

  final bool isSubscription;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isSubscription ? AppColors.primaryLight : AppColors.successLight,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSubscription ? Icons.trending_up : Icons.trending_down,
        color: isSubscription ? AppColors.primary : AppColors.success,
        size: 20,
      ),
    );
  }
}
