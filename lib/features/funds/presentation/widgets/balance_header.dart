import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_animations.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/utils/currency_formatter.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_bloc.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_state.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BalanceHeader extends StatefulWidget {
  const BalanceHeader({this.compact = false, super.key});

  final bool compact;

  @override
  State<BalanceHeader> createState() => _BalanceHeaderState();
}

class _BalanceHeaderState extends State<BalanceHeader> {
  double _balance = 0;
  bool _hasInitialized = false;
  bool _isBalanceHidden = false;

  void _toggleBalanceVisibility() {
    setState(() => _isBalanceHidden = !_isBalanceHidden);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final newBalance = state.maybeWhen(
          loaded: (user) => user.balance,
          orElse: () => 0.0,
        );
        final activeFunds = state.maybeWhen(
          loaded: (user) => user.subscribedFundIds.length,
          orElse: () => 0,
        );
        _syncBalance(newBalance);

        final isMobile = context.isMobile;
        final topPadding = isMobile
            ? AppSpacing.md + MediaQuery.of(context).padding.top
            : AppSpacing.md;

        return BlocBuilder<FundsBloc, FundsState>(
          builder: (context, fundsState) {
            final funds = _extractFunds(fundsState);
            final totalInvested = _sumSubscribedAmount(funds);
            final availableFunds = funds.where((f) => !f.isSubscribed).length;

            return Hero(
              tag: 'balance-header',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    widget.compact ? AppSpacing.md : AppSpacing.lg,
                    topPadding,
                    widget.compact ? AppSpacing.md : AppSpacing.lg,
                    isMobile ? AppSpacing.md : AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: isMobile
                        ? BorderRadius.zero
                        : AppRadius.xlRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SALDO DISPONIBLE',
                            style: AppTypography.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _toggleBalanceVisibility,
                            child: Tooltip(
                              message: _isBalanceHidden
                                  ? 'Mostrar saldo'
                                  : 'Ocultar saldo',
                              child: AnimatedSwitcher(
                                duration: AppAnimations.fast,
                                child: Icon(
                                  _isBalanceHidden
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  key: ValueKey(_isBalanceHidden),
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      AnimatedCrossFade(
                        duration: AppAnimations.normal,
                        crossFadeState: _isBalanceHidden
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild: TweenAnimationBuilder<double>(
                          key: ValueKey(_balance),
                          tween: Tween<double>(
                            begin: _balance * 0.85,
                            end: _balance,
                          ),
                          duration: AppAnimations.slow,
                          curve: Curves.easeOut,
                          builder: (_, value, _) => Text(
                            _formatCOPShort(value),
                            style: AppTypography.currencyLarge.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        secondChild: Text(
                          '\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                          style: AppTypography.currencyLarge.copyWith(
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: isMobile ? AppSpacing.sm : AppSpacing.md,
                      ),
                      Divider(
                        color: Colors.white.withValues(alpha: 0.2),
                        height: AppSpacing.borderThin,
                      ),
                      SizedBox(
                        height: isMobile
                            ? AppSpacing.xs
                            : AppSpacing.md - AppSpacing.xs,
                      ),
                      if (widget.compact)
                        _CompactMetrics(
                          totalInvested: totalInvested,
                          activeFunds: activeFunds,
                          availableFunds: availableFunds,
                          formatValue: _formatCOPShort,
                        )
                      else
                        Row(
                          children: [
                            _MetricItem(
                              label: 'Invertido',
                              value: _formatCOPShort(totalInvested),
                              icon: Icons.trending_up,
                            ),
                            const _VerticalDivider(),
                            _MetricItem(
                              label: 'Activos',
                              value: activeFunds.toString(),
                              icon: Icons.account_balance_wallet_outlined,
                            ),
                            const _VerticalDivider(),
                            _MetricItem(
                              label: 'Disponibles',
                              value: availableFunds.toString(),
                              icon: Icons.add_circle_outline,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _syncBalance(double newBalance) {
    if (!_hasInitialized) {
      _balance = newBalance;
      _hasInitialized = true;
      return;
    }

    if (newBalance == _balance) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _balance = newBalance;
      });
    });
  }

  List<Fund> _extractFunds(FundsState state) {
    return state.maybeMap(
      loaded: (loadedState) => loadedState.funds,
      subscribing: (subscribingState) => subscribingState.funds,
      subscribeSuccess: (successState) => successState.funds,
      cancelSuccess: (successState) => successState.funds,
      failure: (failureState) => failureState.funds,
      orElse: () => const <Fund>[],
    );
  }

  double _sumSubscribedAmount(List<Fund> funds) {
    return funds
        .where((fund) => fund.isSubscribed)
        .fold(0, (sum, fund) => sum + fund.subscribedAmount);
  }

  String _formatCOPShort(double amount) {
    return CurrencyFormatter.cop(amount);
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: AppSpacing.controlHeight,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: Colors.white.withValues(alpha: 0.2),
    );
  }
}

/// Layout de métricas en columna para el modo compacto del sidebar.
class _CompactMetrics extends StatelessWidget {
  const _CompactMetrics({
    required this.totalInvested,
    required this.activeFunds,
    required this.availableFunds,
    required this.formatValue,
  });

  final double totalInvested;
  final int activeFunds;
  final int availableFunds;
  final String Function(double) formatValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _CompactMetricRow(
          icon: Icons.trending_up,
          label: 'Invertido',
          value: formatValue(totalInvested),
        ),
        const SizedBox(height: AppSpacing.xs),
        _CompactMetricRow(
          icon: Icons.account_balance_wallet_outlined,
          label: 'Fondos activos',
          value: activeFunds.toString(),
        ),
        const SizedBox(height: AppSpacing.xs),
        _CompactMetricRow(
          icon: Icons.add_circle_outline,
          label: 'Disponibles',
          value: availableFunds.toString(),
        ),
      ],
    );
  }
}

/// Fila de métrica individual para el layout compacto del sidebar.
class _CompactMetricRow extends StatelessWidget {
  const _CompactMetricRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.65)),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: AppTypography.labelXSmall.copyWith(
              color: Colors.white.withValues(alpha: 0.65),
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
