import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_animations.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/utils/currency_formatter.dart';
import 'package:btg_funds_manager/core/widgets/app_button.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_bloc.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_event.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SubscribeBottomSheet extends StatefulWidget {
  const SubscribeBottomSheet({required this.fund, super.key});

  final Fund fund;

  @override
  State<SubscribeBottomSheet> createState() => _SubscribeBottomSheetState();
}

class _SubscribeBottomSheetState extends State<SubscribeBottomSheet> {
  NotificationMethod _selectedMethod = NotificationMethod.email;
  late final TextEditingController _amountController;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.fund.minimumAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double? get _parsedAmount {
    final raw = _amountController.text.replaceAll(RegExp('[^0-9.]'), '');
    return double.tryParse(raw);
  }

  bool _validateAmount() {
    final amount = _parsedAmount;
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Ingresa un monto válido');
      return false;
    }
    if (amount < widget.fund.minimumAmount) {
      setState(
        () => _amountError =
            'El mínimo es ${_formatCOP(widget.fund.minimumAmount)}',
      );
      return false;
    }
    setState(() => _amountError = null);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final isMobile = context.isMobile;
    final effectiveBottomInset = isMobile
        ? (bottomInset > 0 ? bottomInset : safeBottom)
        : bottomInset;
    const headerIconSize = AppSpacing.buttonHeight - AppSpacing.xs;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + effectiveBottomInset,
      ),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: isMobile
            ? const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.xl),
                topRight: Radius.circular(AppRadius.xl),
              )
            : AppRadius.xlRadius,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isMobile)
              Align(
                child: Container(
                  width: AppSpacing.xl + AppSpacing.sm,
                  height: AppSpacing.xs,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppRadius.fullRadius,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Container(
                  width: headerIconSize,
                  height: headerIconSize,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.monetization_on,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Suscribirse al fondo',
                        style: AppTypography.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        widget.fund.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            const Divider(
              height: AppSpacing.borderThin,
              color: AppColors.divider,
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _InfoChip(
                  icon: Icons.category_outlined,
                  value: widget.fund.category == FundCategory.fpv
                      ? 'FPV'
                      : 'FIC',
                ),
                _InfoChip(
                  icon: Icons.payments_outlined,
                  value: 'Mínimo: ${_formatCOP(widget.fund.minimumAmount)}',
                ),
                _BalanceInfoChip(),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: AppRadius.lgRadius,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: AppSpacing.sm),
                    child: Icon(Icons.trending_up, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monto a invertir (COP)',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: AppTypography.currencyMedium.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            hintText: widget.fund.minimumAmount.toStringAsFixed(
                              0,
                            ),
                            hintStyle: AppTypography.currencyMedium.copyWith(
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                            errorText: _amountError,
                            errorStyle: AppTypography.bodySmall.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                          onChanged: (_) {
                            if (_amountError != null) _validateAmount();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Text(
              '¿Cómo quieres recibir confirmación?',
              style: AppTypography.labelLarge,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _NotificationOption(
                    label: 'Email',
                    subtitle: 'Gratis',
                    icon: Icons.alternate_email,
                    isSelected: _selectedMethod == NotificationMethod.email,
                    onTap: () {
                      setState(() {
                        _selectedMethod = NotificationMethod.email;
                      });
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _NotificationOption(
                    label: 'SMS',
                    subtitle: 'Inmediato',
                    icon: Icons.sms_outlined,
                    isSelected: _selectedMethod == NotificationMethod.sms,
                    onTap: () {
                      setState(() {
                        _selectedMethod = NotificationMethod.sms;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppButton(
              label: 'Confirmar suscripción',
              onPressed: () {
                if (!_validateAmount()) return;
                final amount = _parsedAmount!;
                Navigator.of(context).pop();
                context.read<FundsBloc>().add(
                  FundsEvent.subscribeRequested(
                    fund: widget.fund,
                    amount: amount,
                    notificationMethod: _selectedMethod,
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  String _formatCOP(double amount) {
    return CurrencyFormatter.cop(amount);
  }
}

class _NotificationOption extends StatelessWidget {
  const _NotificationOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected
        ? AppColors.primaryLight
        : AppColors.backgroundSecondary;
    final borderColor = isSelected ? AppColors.primary : AppColors.border;
    final borderWidth = isSelected ? AppSpacing.xxs : AppSpacing.borderThin;
    final foregroundColor = isSelected
        ? AppColors.primary
        : AppColors.textSecondary;
    const optionIconSize = AppSpacing.buttonHeight - AppSpacing.sm;

    return AnimatedContainer(
      duration: AppAnimations.fast,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadius.mdRadius,
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.mdRadius,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                Container(
                  width: optionIconSize,
                  height: optionIconSize,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryLight
                        : AppColors.backgroundSecondary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: foregroundColor),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLarge.copyWith(
                    color: foregroundColor,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: AppRadius.fullRadius,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: AppSpacing.xs),
          Text(value, style: AppTypography.labelSmall),
        ],
      ),
    );
  }
}

class _BalanceInfoChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final balance = state.maybeWhen(
          loaded: (user) => user.balance,
          orElse: () => 0.0,
        );
        return _InfoChip(
          icon: Icons.account_balance_outlined,
          value: 'Tu saldo: ${CurrencyFormatter.cop(balance)}',
        );
      },
    );
  }
}
