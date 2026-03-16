import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/features/transactions/presentation/pages/transactions/transactions_mobile_layout.dart';
import 'package:btg_funds_manager/features/transactions/presentation/pages/transactions/transactions_web_layout.dart';
import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.isWeb) {
      return const TransactionsWebLayout();
    }
    return const TransactionsMobileLayout();
  }
}
