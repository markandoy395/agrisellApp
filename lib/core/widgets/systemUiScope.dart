import 'dart:async';

import 'package:flutter/widgets.dart';

import 'package:agresell_app/core/services/systemUiService.dart';

class SystemUiScope extends StatefulWidget {
  const SystemUiScope({required this.child, super.key});

  final Widget child;

  @override
  State<SystemUiScope> createState() => _SystemUiScopeState();
}

class _SystemUiScopeState extends State<SystemUiScope>
    with WidgetsBindingObserver {
  Timer? _restoreTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _applySystemUi());
  }

  @override
  void dispose() {
    _restoreTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _applySystemUi();
    }
  }

  @override
  void didChangeMetrics() {
    _restoreTimer?.cancel();
    _restoreTimer = Timer(const Duration(milliseconds: 1200), _applySystemUi);
  }

  @override
  void didChangePlatformBrightness() {
    _applySystemUi();
  }

  Future<void> _applySystemUi() {
    final platformBrightness =
        MediaQuery.maybeOf(context)?.platformBrightness ??
        WidgetsBinding.instance.platformDispatcher.platformBrightness;

    return AgrisellSystemUi.applyAppSystemUi(
      platformBrightness: platformBrightness,
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
