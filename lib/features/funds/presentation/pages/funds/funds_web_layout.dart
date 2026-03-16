import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/widgets/animated_empty_state.dart';
import 'package:btg_funds_manager/core/widgets/app_section_header.dart';
import 'package:btg_funds_manager/core/widgets/error_boundary.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_bloc.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_event.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_state.dart';
import 'package:btg_funds_manager/features/funds/presentation/helpers/funds_helpers.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/animated_fund_item.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/category_filter.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/fund_card.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/fund_card_skeleton.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FundsWebLayout extends StatelessWidget {
  const FundsWebLayout({
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSubscribe,
    required this.onCancel,
    required this.onListener,
    super.key,
  });

  final FundCategory? selectedCategory;
  final void Function(FundCategory?) onCategoryChanged;
  final void Function(Fund) onSubscribe;
  final void Function(Fund) onCancel;
  final void Function(BuildContext, FundsState) onListener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<FundsBloc, FundsState>(
        listener: onListener,
        builder: (context, state) {
          final isInitialLoading = state.maybeMap(
            initial: (_) => true,
            loading: (_) => true,
            orElse: () => false,
          );

          final funds = extractFunds(state);
          final failureMessage = state.maybeMap(
            failure: (f) => f.message,
            orElse: () => null,
          );
          final filteredFunds = selectedCategory == null
              ? funds
              : funds
                    .where((f) => f.category == selectedCategory)
                    .toList(growable: false);
          final processingFundId = state.maybeMap(
            subscribing: (s) => s.processingFundId,
            orElse: () => null,
          );

          return SingleChildScrollView(
            child: CenteredContent(
              maxWidth: context.contentMaxWidth,
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppSectionHeader(
                    title: 'Fondos disponibles',
                    subtitle: 'Gestiona tus inversiones BTG',
                  ),
                  if (!isInitialLoading && funds.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    CategoryFilter(
                      initialCategory: selectedCategory,
                      funds: funds,
                      onFilterChanged: onCategoryChanged,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.lg),
                  if (isInitialLoading)
                    const _WebFundsSkeleton()
                  else if (funds.isEmpty && failureMessage != null)
                    ErrorBoundary(
                      message: failureMessage,
                      onRetry: () => context.read<FundsBloc>().add(
                        const FundsEvent.started(),
                      ),
                    )
                  else if (filteredFunds.isEmpty)
                    AnimatedEmptyState(
                      key: ValueKey(selectedCategory),
                      title: 'Sin fondos en esta categoría',
                      subtitle: 'Prueba con un filtro diferente',
                      icon: Icons.filter_list_off,
                      actionLabel: 'Ver todos',
                      onAction: () => onCategoryChanged(null),
                    )
                  else
                    _FundsWebGrid(
                      filteredFunds: filteredFunds,
                      processingFundId: processingFundId,
                      onSubscribe: onSubscribe,
                      onCancel: onCancel,
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Widgets internos ───────────────────────────────────────────────────────

class _WebFundsSkeleton extends StatelessWidget {
  const _WebFundsSkeleton();

  @override
  Widget build(BuildContext context) {
    final columns = context.fundGridColumns;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: AppSpacing.md,
        mainAxisSpacing: AppSpacing.md,
        childAspectRatio: 1.8,
      ),
      itemCount: columns * 2,
      itemBuilder: (_, index) => const FundCardSkeleton(),
    );
  }
}

class _FundsWebGrid extends StatelessWidget {
  const _FundsWebGrid({
    required this.filteredFunds,
    required this.onSubscribe,
    required this.onCancel,
    this.processingFundId,
  });

  final List<Fund> filteredFunds;
  final String? processingFundId;
  final void Function(Fund) onSubscribe;
  final void Function(Fund) onCancel;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final columns = ctx.fundGridColumns;
        final childAspectRatio = columns >= 3
            ? 1.65
            : ctx.fundsGridAspectRatio(constraints.maxWidth);
        return BlocBuilder<UserBloc, UserState>(
          buildWhen: (prev, curr) => prev != curr,
          builder: (context, userState) {
            final balance = userState.maybeWhen(
              loaded: (user) => user.balance,
              orElse: () => double.infinity,
            );
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: filteredFunds.length,
              itemBuilder: (_, i) {
                final fund = filteredFunds[i];
                return AnimatedFundItem(
                  index: i,
                  child: BlocSelector<FundsBloc, FundsState, bool>(
                    selector: (state) => state.maybeMap(
                      subscribing: (s) => s.processingFundId == fund.id,
                      orElse: () => false,
                    ),
                    builder: (context, isLoading) => FundCard(
                      fund: fund,
                      userBalance: balance,
                      isLoading: isLoading,
                      onSubscribe: () => onSubscribe(fund),
                      onCancel: () => onCancel(fund),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
