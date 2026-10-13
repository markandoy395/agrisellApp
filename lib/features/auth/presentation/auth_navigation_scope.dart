import 'dart:async';
import 'package:flutter/material.dart';

import '../data/auth_session_service.dart';
import 'screens/login_screen.dart';

/// Clears private pages and open dialogs when authentication is lost.
class AuthNavigationScope extends StatefulWidget {
  const AuthNavigationScope({
    required this.navigatorKey,
    required this.child,
    super.key,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget child;

  @override
  State<AuthNavigationScope> createState() => _AuthNavigationScopeState();
}

class _AuthNavigationScopeState extends State<AuthNavigationScope> {
  final _session = AuthSessionService.instance;
  late bool _wasAuthenticated;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _wasAuthenticated = _session.isAuthenticated;
    _session.addListener(_checkSession);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _checkSession());
  }

  void _checkSession() {
    final authenticated = _session.isAuthenticated;
    final lostSession = _wasAuthenticated && !authenticated;
    _wasAuthenticated = authenticated;
    if (!lostSession) return;
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _session.isAuthenticated) return;
      final navigator = widget.navigatorKey.currentState;
      if (navigator == null) return;
      var showingLogin = false;
      navigator.popUntil((route) {
        showingLogin = route.settings.name == 'auth.login';
        return true;
      });
      // Account handoffs already remove private routes and show the selected
      // account's public login flow. Preserve that flow while its profile loads.
      if (showingLogin) return;
      navigator.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    });
    // A periodic expiry check can run without an otherwise scheduled frame.
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _session.removeListener(_checkSession);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
