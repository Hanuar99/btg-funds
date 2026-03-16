import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/core/widgets/animated_empty_state.dart';
import 'package:btg_funds_manager/core/widgets/app_section_header.dart';
import 'package:btg_funds_manager/core/widgets/error_boundary.dart';
import 'package:btg_funds_manager/features/transactions/domain/entities/transaction.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_state.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/transactions_loading_view.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/transactions_summary_card.dart';
import 'package:btg_funds_manager/features/transactions/presentation/widgets/transactions_web_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionsWebLayout extends StatelessWidget {
  const TransactionsWebLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsBloc, TransactionsState>(
      builder: (context, state) {
        return state.when(
          initial: () => const _WebLoadingScaffold(),
          loading: () => const _WebLoadingScaffold(),
          loaded: (transactions) => _WebTransactionsContent(
            transactions: transactions,
          ),
          failure: (message) => Scaffold(
            body: Center(
              child: ErrorBoundary(
                message: message,
                onRetry: () => context.read<TransactionsBloc>().add(
                  const TransactionsEvent.refreshRequested(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _WebLoadingScaffold extends StatelessWidget {
  const _WebLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: TransactionsLoadingView(),
    );
  }
}

class _WebTransactionsContent extends StatelessWidget {
  const _WebTransactionsContent({required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: CenteredContent(
          maxWidth: context.contentMaxWidth,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionHeader(
                title: 'Historial de transacciones',
                subtitle: 'Registro de todas tus operaciones BTG',
              ),
              if (transactions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                const TransactionsSummaryCard(margin: EdgeInsets.zero),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (transactions.isEmpty)
                const AnimatedEmptyState(
                  title: 'Sin transacciones aún',
                  subtitle:
                      'Suscríbete a tu primer fondo\npara ver el historial aquí',
                  icon: Icons.receipt_long_outlined,
                )
              else
                TransactionsWebTable(transactions: transactions),
            ],
          ),
        ),
      ),
    );
  }
}
