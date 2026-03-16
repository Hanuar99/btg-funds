import 'package:btg_funds_manager/core/di/injection.dart';
import 'package:btg_funds_manager/core/router/app_router.dart';
import 'package:btg_funds_manager/core/theme/app_theme.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_bloc.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_event.dart';
import 'package:btg_funds_manager/features/funds/presentation/bloc/funds_state.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:btg_funds_manager/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_bloc.dart';
import 'package:btg_funds_manager/features/user/presentation/bloc/user_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BtgFondosApp extends StatelessWidget {
  const BtgFondosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserBloc>(
          create: (_) => getIt<UserBloc>()..add(const UserEvent.started()),
        ),
        BlocProvider<FundsBloc>(
          create: (_) => getIt<FundsBloc>()..add(const FundsEvent.started()),
        ),
        BlocProvider<TransactionsBloc>(
          create: (_) =>
              getIt<TransactionsBloc>()..add(const TransactionsEvent.started()),
        ),
      ],
      child: const _AppView(),
    );
  }
}

class _AppView extends StatelessWidget {
  const _AppView();

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<FundsBloc, FundsState>(
          listener: (context, state) {
            state.maybeWhen(
              subscribeSuccess: (funds, subscribedFund) {
                // Refrescar saldo y historial tras suscripcion exitosa.
                context.read<UserBloc>().add(
                  const UserEvent.refreshRequested(),
                );
                context.read<TransactionsBloc>().add(
                  const TransactionsEvent.refreshRequested(),
                );
              },
              cancelSuccess: (funds, cancelledFund) {
                // Refrescar saldo y historial tras cancelacion exitosa.
                context.read<UserBloc>().add(
                  const UserEvent.refreshRequested(),
                );
                context.read<TransactionsBloc>().add(
                  const TransactionsEvent.refreshRequested(),
                );
              },
              orElse: () {},
            );
          },
        ),
      ],
      child: MaterialApp.router(
        title: 'BTG Fondos',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: getIt<AppRouter>().router,
      ),
    );
  }
}
