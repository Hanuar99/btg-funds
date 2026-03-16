import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_typography.dart';
import 'package:btg_funds_manager/core/widgets/animated_empty_state.dart';
import 'package:btg_funds_manager/core/widgets/error_boundary.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:btg_funds_manager/features/transactions/presentation/helpers/transactions_ui_helpers.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/transaction_tile.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/transactions_date_separator.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/transactions_loading_view.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/transactions_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsMobileLayout extends StatelessWidget {
  const TransactionsMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.backgroundCard,
        onRefresh: () async {
          context.read<TransactionsBloc>().add(
            const TransactionsEvent.refreshRequested(),
          );
          await context.read<TransactionsBloc>().stream.firstWhere(
            (state) => state.maybeMap(
              loading: (_) => false,
              orElse: () => true,
            ),
          );
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            const _MobileTransactionsAppBar(),
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.sm),
            ),
            const SliverToBoxAdapter(child: TransactionsSummaryCard()),
            BlocBuilder<TransactionsBloc, TransactionsState>(
              builder: (context, state) {
                return state.when(
                  initial: () => const SliverFillRemaining(
                    child: TransactionsLoadingView(),
                  ),
                  loading: () => const SliverFillRemaining(
                    child: TransactionsLoadingView(),
                  ),
                  loaded: (transactions) {
                    if (transactions.isEmpty) {
                      return const SliverFillRemaining(
                        hasScrollBody: false,
                        child: AnimatedEmptyState(
                          title: 'Sin transacciones aún',
                          subtitle:
                              'Suscríbete a tu primer fondo\npara ver el historial aquí',
                          icon: Icons.receipt_long_outlined,
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final tx = transactions[index];
                          final showDateHeader =
                              index == 0 ||
                              !TransactionsUiHelpers.isSameDay(
                                transactions[index - 1].date,
                                tx.date,
                              );
                          final isLastInGroup =
                              index == transactions.length - 1 ||
                              !TransactionsUiHelpers.isSameDay(
                                tx.date,
                                transactions[index + 1].date,
                              );

                          final radius = BorderRadius.only(
                            topLeft: showDateHeader
                                ? const Radius.circular(AppRadius.lg)
                                : Radius.zero,
                            topRight: showDateHeader
                                ? const Radius.circular(AppRadius.lg)
                                : Radius.zero,
                            bottomLeft: isLastInGroup
                                ? const Radius.circular(AppRadius.lg)
                                : Radius.zero,
                            bottomRight: isLastInGroup
                                ? const Radius.circular(AppRadius.lg)
                                : Radius.zero,
                          );

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (showDateHeader)
                                TransactionsDateSeparator(date: tx.date),
                              ClipRRect(
                                borderRadius: radius,
                                child: TransactionTile(transaction: tx),
                              ),
                            ],
                          );
                        }, childCount: transactions.length),
                      ),
                    );
                  },
                  failure: (message) => SliverFillRemaining(
                    child: ErrorBoundary(
                      message: message,
                      onRetry: () {
                        context.read<TransactionsBloc>().add(
                          const TransactionsEvent.refreshRequested(),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileTransactionsAppBar extends StatelessWidget {
  const _MobileTransactionsAppBar();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: context.mobileSecondaryHeaderExpandedHeight,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Historial',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textOnPrimary,
          ),
        ),
        centerTitle: false,
        titlePadding: const EdgeInsetsDirectional.only(
          start: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
      ),
    );
  }
}
