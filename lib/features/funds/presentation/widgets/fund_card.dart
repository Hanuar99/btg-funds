import 'package:btg_funds_manager/core/theme/tokens/app_animations.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/utils/currency_formatter.dart';
import 'package:btg_funds_manager/core/widgets/app_button.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:flutter/material.dart';

class FundCard extends StatefulWidget {
  const FundCard({
    required this.fund,
    this.userBalance = double.infinity,
    this.onSubscribe,
    this.onCancel,
    this.isLoading = false,
    super.key,
  });
  final Fund fund;
  final double userBalance;
  final VoidCallback? onSubscribe;
  final VoidCallback? onCancel;
  final bool isLoading;

  @override
  State<FundCard> createState() => _FundCardState();
}

class _FundCardState extends State<FundCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.97,
      value: 1,
      duration: AppAnimations.fast,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.fund.isSubscribed
        ? AppColors.success
        : AppColors.border;
    final borderWidth = widget.fund.isSubscribed ? 2.0 : AppSpacing.borderThin;

    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) => _controller.forward(),
      onTapCancel: _controller.forward,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _controller.value,
            child: child,
          );
        },
        child: IntrinsicHeight(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: AppRadius.lgRadius,
              border: Border.all(color: borderColor, width: borderWidth),
            ),
            clipBehavior: Clip.antiAlias,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _CategoryRail(fund: widget.fund),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.grid),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.fund.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            _CategoryBadge(category: widget.fund.category),
                            if (widget.fund.isSubscribed) ...[
                              const SizedBox(width: AppSpacing.xs),
                              const _StatusBadge(),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpacing.compact),
                        _ProgressSection(
                          fund: widget.fund,
                          userBalance: widget.userBalance,
                        ),
                        const SizedBox(height: AppSpacing.compact),
                        Text(
                          'Min: ${CurrencyFormatter.cop(widget.fund.minimumAmount)}',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        _buildActionButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    final isSubscribed = widget.fund.isSubscribed;
    final canSubscribe = widget.userBalance >= widget.fund.minimumAmount;
    final shortage = widget.fund.minimumAmount - widget.userBalance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppButton(
          label: isSubscribed ? 'Cancelar participación' : 'Suscribirse',
          onPressed: isSubscribed
              ? widget.onCancel
              : (canSubscribe ? widget.onSubscribe : null),
          variant: isSubscribed
              ? AppButtonVariant.outlineDanger
              : AppButtonVariant.primary,
          isLoading: widget.isLoading,
        ),
        if (!isSubscribed && !canSubscribe) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Faltan ${CurrencyFormatter.cop(shortage)} para el mínimo',
            style: AppTypography.labelSmall.copyWith(color: AppColors.error),
          ),
        ],
      ],
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail({required this.fund});

  final Fund fund;

  @override
  Widget build(BuildContext context) {
    final color = fund.category == FundCategory.fpv
        ? AppColors.fpvCategory
        : AppColors.ficCategory;

    return Container(width: 4, color: color);
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection({required this.fund, required this.userBalance});

  final Fund fund;
  final double userBalance;

  @override
  Widget build(BuildContext context) {
    final minimum = fund.minimumAmount;
    final availableRatio = (userBalance / minimum).clamp(0.0, 1.0);
    final subscribedRatio = (fund.subscribedAmount / minimum).clamp(0.0, 1.0);
    final hasEnough = userBalance >= minimum;
    final shortage = (minimum - userBalance).clamp(0.0, minimum);
    Color fillColor;
    double progressValue;
    String label;
    Color labelColor;

    if (fund.isSubscribed) {
      fillColor = AppColors.success;
      progressValue = subscribedRatio;
      label = 'Invertido ${CurrencyFormatter.cop(fund.subscribedAmount)}';
      labelColor = AppColors.success;
    } else if (!hasEnough) {
      fillColor = AppColors.error;
      progressValue = availableRatio;
      label = 'Faltan ${CurrencyFormatter.cop(shortage)}';
      labelColor = AppColors.error;
    } else {
      fillColor = AppColors.primary;
      progressValue = availableRatio;
      if (availableRatio >= 1) {
        label = 'Tienes saldo suficiente ✓';
        labelColor = AppColors.success;
      } else {
        label =
            'Tienes ${(availableRatio * 100).toStringAsFixed(0)}% del mínimo';
        labelColor = AppColors.textSecondary;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: AppRadius.fullRadius,
          child: SizedBox(
            height: 4,
            child: Stack(
              children: [
                Container(color: AppColors.backgroundSecondary),
                FractionallySizedBox(
                  widthFactor: progressValue,
                  child: Container(color: fillColor),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: labelColor,
            fontWeight: fund.isSubscribed ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});
  final FundCategory category;

  @override
  Widget build(BuildContext context) {
    final isFpv = category == FundCategory.fpv;
    final backgroundColor = isFpv
        ? AppColors.fpvCategoryBg
        : AppColors.ficCategoryBg;
    final foregroundColor = isFpv
        ? AppColors.fpvCategory
        : AppColors.ficCategory;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        isFpv ? 'FPV' : 'FIC',
        style: AppTypography.labelSmall.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: AppRadius.fullRadius,
      ),
      child: Text(
        '✓ Suscrito',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
