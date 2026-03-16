import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:flutter/material.dart';

class TransactionTypeBadge extends StatelessWidget {
  const TransactionTypeBadge({
    required this.isSubscription,
    this.compact = false,
    super.key,
  });

  final bool isSubscription;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: compact ? AppSpacing.micro : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: isSubscription ? AppColors.primaryLight : AppColors.successLight,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        isSubscription ? 'Suscripción' : 'Cancelación',
        style: (compact ? AppTypography.labelXSmall : AppTypography.labelSmall)
            .copyWith(
              color: isSubscription ? AppColors.primary : AppColors.success,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
