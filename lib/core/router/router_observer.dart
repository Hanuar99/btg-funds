import 'package:btg_funds_manager/core/logger/app_logger.dart';
import 'package:btg_funds_manager/core/router/route_title_sync.dart';
import 'package:flutter/widgets.dart';

class RouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    AppLogger.debug('Router: push -> ${route.settings.name}');
    syncPageTitle(_routeNameOf(route));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    AppLogger.debug('Router: pop <- ${route.settings.name}');
    syncPageTitle(_routeNameOf(previousRoute));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    AppLogger.debug('Router: replace -> ${newRoute?.settings.name}');
    syncPageTitle(_routeNameOf(newRoute));
  }

  String? _routeNameOf(Route<dynamic>? route) {
    final name = route?.settings.name;
    return name is String ? name : null;
  }
}
