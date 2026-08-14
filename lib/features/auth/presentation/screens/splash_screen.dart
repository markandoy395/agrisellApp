import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/widgets/auth_background.dart';
import 'package:agresell_app/features/auth/presentation/widgets/logo_header.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({this.supabaseInitialization, super.key});

  final Future<bool>? supabaseInitialization;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  var _didStartTransition = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didStartTransition) {
      return;
    }

    _didStartTransition = true;
    unawaited(_resolveLaunchDestination());
  }

  Future<void> _resolveLaunchDestination() async {
    unawaited(AuthBackground.precache(context));
    final supabaseInitialization = widget.supabaseInitialization;
    if (supabaseInitialization != null) await supabaseInitialization;
    if (!mounted) return;
    final session = await AuthSessionService.instance.restore().timeout(
      const Duration(seconds: 8),
      onTimeout: AuthSessionRestoreResult.noSession,
    );
    final account = session.account;
    if (!mounted) return;
    if (account != null && account.assignedRole == null) {
      await AuthSessionService.instance.clear();
    }
    if (!mounted) return;
    final destination = account == null
        ? LoginScreen(
            initialMessage: session.wasExpired
                ? 'Your session has expired. Please log in again.'
                : null,
          )
        : AuthDashboardRouter.destinationFor(account);

    await Navigator.of(context).pushReplacement(
      agrisellPageRoute<void>(
        builder: (_) => destination,
        beginOffset: Offset.zero,
        duration: const Duration(milliseconds: 350),
        reverseDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgrisellColors.forestSoft,
      body: const Center(
        child: LogoHeader(
          style: LogoHeaderStyle.stacked,
          widthMin: 196,
          widthMax: 228,
        ),
      ),
    );
  }
}
