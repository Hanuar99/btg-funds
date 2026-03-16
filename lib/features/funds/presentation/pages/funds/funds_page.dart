import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/router/route_names.dart';
import 'package:btg_funds_manager/core/widgets/app_toast.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_state.dart';
import 'package:btg_funds_manager/features/funds/presentation/dialogs/cancel_fund_dialog.dart';
import 'package:btg_funds_manager/features/funds/presentation/helpers/funds_helpers.dart';
import 'package:btg_funds_manager/features/funds/presentation/pages/funds/funds_mobile_layout.dart';
import 'package:btg_funds_manager/features/funds/presentation/pages/funds/funds_web_layout.dart';
import 'package:btg_funds_manager/features/funds/presentation/sheets/subscribe_fund_sheet.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FundsPage extends StatefulWidget {
  const FundsPage({super.key});

  @override
  State<FundsPage> createState() => _FundsPageState();
}

class _FundsPageState extends State<FundsPage> {
  FundCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    if (context.isWeb) {
      return FundsWebLayout(
        selectedCategory: _selectedCategory,
        onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
        onSubscribe: (fund) => showSubscribeFundSheet(context, fund),
        onCancel: (fund) => showCancelFundDialog(context, fund),
        onListener: _handleBlocState,
      );
    }
    return FundsMobileLayout(
      selectedCategory: _selectedCategory,
      onCategoryChanged: (cat) => setState(() => _selectedCategory = cat),
      onSubscribe: (fund) => showSubscribeFundSheet(context, fund),
      onCancel: (fund) => showCancelFundDialog(context, fund),
      onListener: _handleBlocState,
    );
  }

  void _handleBlocState(BuildContext context, FundsState state) {
    state.maybeWhen(
      subscribeSuccess: (funds, subscribedFund) {
        AppToast.show(
          context,
          message: '✅ Te vinculaste al fondo ${subscribedFund.name}',
          type: ToastType.success,
        );
      },
      cancelSuccess: (funds, cancelledFund) {
        AppToast.show(
          context,
          message:
              '↩️ Cancelaste tu participación en ${cancelledFund.name}. Se reintegró ${formatCOP(cancelledFund.subscribedAmount)}.',
          type: ToastType.warning,
          duration: const Duration(seconds: 5),
          actionLabel: 'Ver historial',
          onAction: () => context.go(RouteNames.transactions),
        );
      },
      failure: (funds, message) {
        AppToast.show(
          context,
          message: message,
          type: ToastType.error,
          duration: const Duration(seconds: 5),
          actionLabel: 'OK',
        );
      },
      orElse: () {},
    );
  }
}
