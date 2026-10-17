import 'package:flutter/material.dart';

import 'auth_page_gate.dart';

/// Tracks routes so session loss can remove private history without restarting
/// an already open public registration form.
class AuthNavigationObserver extends NavigatorObserver {
  final List<Route<dynamic>> _routes = [];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.add(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _routes.remove(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    final index = oldRoute == null ? -1 : _routes.indexOf(oldRoute);
    if (index < 0) return;
    if (newRoute == null) {
      _routes.removeAt(index);
    } else {
      _routes[index] = newRoute;
    }
  }

  bool retainPublicFlow(NavigatorState currentNavigator) {
    if (navigator != currentNavigator) return false;
    final pages = _routes.whereType<PageRoute<dynamic>>();
    if (pages.isEmpty || !AuthPageGate.isPublicRoute(pages.last)) return false;
    // Unknown routes and dialogs are private by default. Never preserve private
    // content merely because a public signup page is above it.
    for (final route in List.of(_routes).reversed) {
      if (route.isActive && !AuthPageGate.isPublicRoute(route)) {
        currentNavigator.removeRoute(route);
      }
    }
    return true;
  }
}
