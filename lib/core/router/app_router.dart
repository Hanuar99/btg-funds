import 'package:btg_funds_manager/core/router/app_routes.dart';
import 'package:btg_funds_manager/core/router/route_names.dart';
import 'package:btg_funds_manager/core/router/router_error_page.dart';
import 'package:btg_funds_manager/core/router/router_observer.dart';
import 'package:btg_funds_manager/core/router/shell/app_shell.dart';
import 'package:btg_funds_manager/core/router/shell/navigation_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

@singleton
class AppRouter {
  AppRouter();

  late final GoRouter router = GoRouter(
    initialLocation: RouteNames.home,
    observers: <NavigatorObserver>[RouterObserver()],
    routes: buildAppRoutes(
      shellBuilder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      navigatorContainerBuilder: (context, navigationShell, children) {
        return TabSwitcher(
          selectedIndex: navigationShell.currentIndex,
          children: children,
        );
      },
    ),
    errorBuilder: (context, state) => RouterErrorPage(error: state.error),
  );
}
