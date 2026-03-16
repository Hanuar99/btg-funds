import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_animations.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/widgets/animated_empty_state.dart';
import 'package:btg_funds_manager/core/widgets/error_boundary.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_bloc.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_event.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_state.dart';
import 'package:btg_funds_manager/features/funds/presentation/helpers/funds_helpers.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/balance_header.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/category_filter.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/fund_card_skeleton.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/fund_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FundsMobileLayout extends StatelessWidget {
  const FundsMobileLayout({
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
          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: AppColors.backgroundCard,
            onRefresh: () async {
              context.read<FundsBloc>().add(const FundsEvent.started());
              await context.read<FundsBloc>().stream.firstWhere(
                (s) => s.maybeMap(loading: (_) => false, orElse: () => true),
              );
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverAppBar(
                  expandedHeight: context.mobileHeaderExpandedHeight,
                  pinned: true,
                  backgroundColor: AppColors.primary,
                  flexibleSpace: FlexibleSpaceBar(
                    centerTitle: false,
                    titlePadding: const EdgeInsets.only(
                      left: AppSpacing.md,
                      bottom: AppSpacing.xs,
                    ),
                    title: Text(
                      'BTG Fondos',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                    background: const BalanceHeader(),
                  ),
                ),
                _FundsMobileContent(
                  state: state,
                  selectedCategory: selectedCategory,
                  onCategoryChanged: onCategoryChanged,
                  onSubscribe: onSubscribe,
                  onCancel: onCancel,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Contenido interno ───────────────────────────────────────────────────────

class _FundsMobileContent extends StatelessWidget {
  const _FundsMobileContent({
    required this.state,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSubscribe,
    required this.onCancel,
  });

  final FundsState state;
  final FundCategory? selectedCategory;
  final void Function(FundCategory?) onCategoryChanged;
  final void Function(Fund) onSubscribe;
  final void Function(Fund) onCancel;

  @override
  Widget build(BuildContext context) {
    final isInitialLoading = state.maybeMap(
      initial: (_) => true,
      loading: (_) => true,
      orElse: () => false,
    );

    if (isInitialLoading) {
      return const FundListSkeleton();
    }

    final funds = extractFunds(state);
    final failureMessage = state.maybeMap(
      failure: (f) => f.message,
      orElse: () => null,
    );

    if (funds.isEmpty && failureMessage != null) {
      return SliverFillRemaining(
        child: ErrorBoundary(
          message: failureMessage,
          onRetry: () =>
              context.read<FundsBloc>().add(const FundsEvent.started()),
        ),
      );
    }

    final filteredFunds = selectedCategory == null
        ? funds
        : funds
              .where((f) => f.category == selectedCategory)
              .toList(growable: false);

    final processingFundId = state.maybeMap(
      subscribing: (s) => s.processingFundId,
      orElse: () => null,
    );

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: CategoryFilter(
              initialCategory: selectedCategory,
              funds: funds,
              onFilterChanged: onCategoryChanged,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: Text('Fondos disponibles', style: AppTypography.titleLarge),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),
        if (filteredFunds.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: AnimatedSwitcher(
              duration: AppAnimations.normal,
              child: AnimatedEmptyState(
                key: ValueKey(selectedCategory),
                title: 'Sin fondos en esta categoría',
                subtitle: 'Prueba con un filtro diferente',
                icon: Icons.filter_list_off,
                actionLabel: 'Ver todos',
                onAction: () => onCategoryChanged(null),
              ),
            ),
          )
        else
          FundListSliver(
            key: ValueKey('${selectedCategory}_${filteredFunds.length}'),
            funds: filteredFunds,
            processingFundId: processingFundId,
            onSubscribe: onSubscribe,
            onCancel: onCancel,
          ),
      ],
    );
  }
}
