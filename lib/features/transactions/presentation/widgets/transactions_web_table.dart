import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/widgets/app_card_surface.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/transactions/presentation/helpers/transactions_ui_helpers.dart';
import 'package:btg_funds_manager/features/transactions/presentation/utils/transaction_date_formatter.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/notification_method_chip.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/transaction_type_badge.dart';
import 'package:flutter/material.dart';

class TransactionsWebTable extends StatelessWidget {
  const TransactionsWebTable({
    required this.transactions,
    super.key,
  });

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return AppCardSurface(
      child: Column(
        children: [
          const _TableHeader(),
          const Divider(height: 1, color: AppColors.border),
          ...transactions.asMap().entries.map(
            (entry) => _TableRow(
              transaction: entry.value,
              isLast: entry.key == transactions.length - 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.grid,
      ),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.lg),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Fecha',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              'Fondo',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Tipo',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Notificación',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Monto',
              textAlign: TextAlign.right,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  const _TableRow({
    required this.transaction,
    required this.isLast,
  });

  final Transaction transaction;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isSubscription = transaction.type == TransactionType.subscription;
    final amountColor = isSubscription ? AppColors.error : AppColors.success;
    final barColor = isSubscription ? AppColors.primary : AppColors.success;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 3,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(AppRadius.lg),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.grid,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          TransactionDateFormatter.transactionDateTime(
                            transaction.date,
                          ),
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          transaction.fundName,
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TransactionTypeBadge(
                            isSubscription: isSubscription,
                            compact: true,
                          ),
                        ),
                      ),
                      Expanded(
                        child: _NotifCell(
                          method: transaction.notificationMethod,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          TransactionsUiHelpers.signedAmount(
                            isSubscription: isSubscription,
                            amount: transaction.amount,
                          ),
                          style: AppTypography.bodyMedium.copyWith(
                            color: amountColor,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, color: AppColors.border),
      ],
    );
  }
}

class _NotifCell extends StatelessWidget {
  const _NotifCell({this.method});

  final NotificationMethod? method;

  @override
  Widget build(BuildContext context) {
    if (method == null) {
      return Text(
        '—',
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: NotificationMethodChip(
        method: method!,
        compact: true,
      ),
    );
  }
}
