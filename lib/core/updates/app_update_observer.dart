import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_update_dialog.dart';
import 'app_update_service.dart';

/// Checks after startup has replaced the splash route, never blocking startup.
class AppUpdateObserver extends NavigatorObserver {
  AppUpdateObserver({AppUpdateService? service})
    : _service = service ?? AppUpdateService();

  final AppUpdateService _service;
  DateTime? _lastCheck;
  bool _checking = false;
  bool _prompted = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _schedule(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) _schedule(newRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (previousRoute != null) _schedule(previousRoute);
  }

  void _schedule(Route<dynamic> route) {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android ||
        route is! PageRoute)
      return;
    unawaited(_check(route));
  }

  Future<void> _check(Route<dynamic> route) async {
    if (_checking || _prompted) return;
    final now = DateTime.now();
    if (_lastCheck != null &&
        now.difference(_lastCheck!) < const Duration(minutes: 5))
      return;
    _checking = true;
    try {
      // Let the destination finish its transition before showing the sheet.
      await Future<void>.delayed(const Duration(seconds: 1));
      final release = await _service.check();
      _lastCheck = DateTime.now();
      final state = navigator;
      if (release == null ||
          state == null ||
          !state.mounted ||
          !route.isCurrent)
        return;
      _prompted = true;
      await AppUpdateDialog.show(state.overlay!.context, release);
    } finally {
      _checking = false;
    }
  }
}
