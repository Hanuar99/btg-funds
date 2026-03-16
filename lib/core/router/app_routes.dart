import 'package:btg_funds_manager/core/router/route_names.dart';
import 'package:btg_funds_manager/core/router/router_transitions.dart';
import 'package:btg_funds_manager/features/funds/presentation/pages/funds/funds_page.dart';
import 'package:btg_funds_manager/features/transactions/presentation/pages/transactions/transactions_page.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

List<RouteBase> buildAppRoutes({
  required Widget Function(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  )
  shellBuilder,
  required Widget Function(
    BuildContext context,
    StatefulNavigationShell navigationShell,
    List<Widget> children,
  )
  navigatorContainerBuilder,
}) {
  return <RouteBase>[
    StatefulShellRoute(
      builder: shellBuilder,
      navigatorContainerBuilder: navigatorContainerBuilder,
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.home,
              redirect: (_, _) => RouteNames.funds,
            ),
            GoRoute(
              path: RouteNames.funds,
              pageBuilder: (context, state) => buildRouterPage(
                context: context,
                state: state,
                routeName: RouteNames.funds,
                child: const FundsPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: RouteNames.transactions,
              pageBuilder: (context, state) => buildRouterPage(
                context: context,
                state: state,
                routeName: RouteNames.transactions,
                child: const TransactionsPage(),
              ),
            ),
          ],
        ),
      ],
    ),
  ];
}
