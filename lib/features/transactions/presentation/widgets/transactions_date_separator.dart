import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/features/transactions/presentation/utils/transaction_date_formatter.dart';
import 'package:flutter/material.dart';

class TransactionsDateSeparator extends StatelessWidget {
  const TransactionsDateSeparator({
    required this.date,
    super.key,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final label = TransactionDateFormatter.dateGroupLabel(date);
    final sidePadding = context.isWeb ? AppSpacing.sm : AppSpacing.md;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: sidePadding,
      ),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.grid),
            child: Text(
              label,
              style: AppTypography.sectionOverline,
            ),
          ),
          const Expanded(child: Divider(color: AppColors.border, height: 1)),
        ],
      ),
    );
  }
}
