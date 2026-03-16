import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_radius.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_spacing.dart';
import 'package:btg_funds_manager/features/funds/domain/entities/fund.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_bloc.dart';
import 'package:btg_funds_manager/features/funds/presentation/widgets/subscribe_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Muestra la interfaz de suscripción a un fondo.
Future<void> showSubscribeFundSheet(BuildContext context, Fund fund) {
  final bloc = context.read<FundsBloc>();

  if (context.isWeb) {
    return showDialog<void>(
      context: context,
      builder: (_) => Dialog(
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.horizontalPadding,
          vertical: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xlRadius),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: context.webDialogWidth,
            maxHeight: context.screenHeight * 0.88,
          ),
          child: BlocProvider.value(
            value: bloc,
            child: SubscribeBottomSheet(fund: fund),
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => BlocProvider.value(
      value: bloc,
      child: SubscribeBottomSheet(fund: fund),
    ),
  );
}
