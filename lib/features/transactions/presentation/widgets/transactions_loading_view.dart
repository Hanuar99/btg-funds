import 'package:btg_funds_manager/core/theme/tokens/app_colors.dart';
import 'package:flutter/material.dart';

class TransactionsLoadingView extends StatelessWidget {
  const TransactionsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}
