import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:flutter/material.dart';

class NotificationMethodChip extends StatelessWidget {
  const NotificationMethodChip({
    required this.method,
    this.compact = false,
    super.key,
  });

  final NotificationMethod method;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isEmail = method == NotificationMethod.email;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: compact ? AppSpacing.micro : AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.fullRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEmail ? Icons.email_outlined : Icons.sms_outlined,
            size: compact ? 10 : 12,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: compact ? AppSpacing.xs : AppSpacing.micro),
          Text(
            isEmail ? 'Email' : 'SMS',
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
