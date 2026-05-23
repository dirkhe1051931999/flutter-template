import 'package:flutter/widgets.dart';
import 'package:oolaf_flutted/tools/developer_tools_center.dart';

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  void _record({
    required String event,
    required Route<dynamic>? route,
    required Route<dynamic>? previousRoute,
  }) {
    DeveloperToolsCenter.instance.recordRoute(
      event: event,
      routeName: route?.settings.name ?? route.runtimeType.toString(),
      previousRouteName:
          previousRoute?.settings.name ?? previousRoute.runtimeType.toString(),
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _record(event: 'push', route: route, previousRoute: previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _record(event: 'pop', route: route, previousRoute: previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _record(event: 'remove', route: route, previousRoute: previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _record(event: 'replace', route: newRoute, previousRoute: oldRoute);
  }
}

final AppRouteObserver appRouteObserver = AppRouteObserver();
