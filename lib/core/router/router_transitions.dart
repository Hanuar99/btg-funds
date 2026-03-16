import 'package:btg_funds_manager/core/responsive/responsive_system.dart';
import 'package:btg_funds_manager/core/router/route_title_sync.dart';
import 'package:btg_funds_manager/core/theme/tokens/app_animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

Page<void> buildRouterPage({
  required BuildContext context,
  required GoRouterState state,
  required String routeName,
  required Widget child,
}) {
  syncPageTitle(routeName);
  if (context.isMobile) {
    return CupertinoPage<void>(
      key: state.pageKey,
      name: routeName,
      child: child,
    );
  }

  return CustomTransitionPage<void>(
    key: state.pageKey,
    name: routeName,
    transitionDuration: AppAnimations.page,
    reverseTransitionDuration: AppAnimations.fast,
    child: child,
    transitionsBuilder: primaryTransition,
  );
}

Widget primaryTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(
    opacity: CurvedAnimation(
      parent: animation,
      curve: AppAnimations.enterCurve,
    ),
    child: SlideTransition(
      position:
          Tween<Offset>(
            begin: const Offset(0.02, 0),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(
              parent: animation,
              curve: AppAnimations.enterCurve,
            ),
          ),
      child: child,
    ),
  );
}
