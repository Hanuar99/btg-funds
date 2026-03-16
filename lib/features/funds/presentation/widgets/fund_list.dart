import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_bloc.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_state.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/animated_fund_item.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/fund_card.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FundListSliver extends StatelessWidget {
  const FundListSliver({
    required this.funds,
    required this.onSubscribe,
    required this.onCancel,
    this.processingFundId,
    super.key,
  });

  final List<Fund> funds;
  final void Function(Fund) onSubscribe;
  final void Function(Fund) onCancel;
  final String? processingFundId;

  @override
  Widget build(BuildContext context) {
    final isWeb = context.isWeb;

    if (isWeb) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.8,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final fund = funds[index];
              return AnimatedFundItem(
                index: index,
                child: BlocSelector<FundsBloc, FundsState, bool>(
                  selector: (state) => state.maybeMap(
                    subscribing: (s) => s.processingFundId == fund.id,
                    orElse: () => false,
                  ),
                  builder: (context, isLoading) {
                    return BlocBuilder<UserBloc, UserState>(
                      buildWhen: (prev, curr) => prev != curr,
                      builder: (context, userState) {
                        final balance = userState.maybeWhen(
                          loaded: (user) => user.balance,
                          orElse: () => double.infinity,
                        );

                        return FundCard(
                          fund: fund,
                          userBalance: balance,
                          isLoading: isLoading,
                          onSubscribe: () => onSubscribe(fund),
                          onCancel: () => onCancel(fund),
                        );
                      },
                    );
                  },
                ),
              );
            },
            childCount: funds.length,
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final fund = funds[index];
            return AnimatedFundItem(
              index: index,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: BlocSelector<FundsBloc, FundsState, bool>(
                  selector: (state) => state.maybeMap(
                    subscribing: (s) => s.processingFundId == fund.id,
                    orElse: () => false,
                  ),
                  builder: (context, isLoading) {
                    return BlocBuilder<UserBloc, UserState>(
                      buildWhen: (prev, curr) => prev != curr,
                      builder: (context, userState) {
                        final balance = userState.maybeWhen(
                          loaded: (user) => user.balance,
                          orElse: () => double.infinity,
                        );

                        return FundCard(
                          fund: fund,
                          userBalance: balance,
                          isLoading: isLoading,
                          onSubscribe: () => onSubscribe(fund),
                          onCancel: () => onCancel(fund),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
          childCount: funds.length,
        ),
      ),
    );
  }
}
