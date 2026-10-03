import 'package:flutter/widgets.dart';
import 'auth_page_gate.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/auth_route_guard.dart';
import 'package:agresell_app/features/auth/domain/sign_up_account_data.dart';
import 'package:agresell_app/features/auth/presentation/screens/account_access_status_screen.dart';

typedef AuthRedirectBuilder = Widget Function(RegisteredAccount account);

/// Blocks a dashboard when the active session lacks its required role.
class AuthRoleGate extends StatelessWidget {
  const AuthRoleGate({
    required this.requiredRole,
    required this.child,
    this.redirectFor,
    super.key,
  });

  final AuthRole requiredRole;
  final Widget child;
  final AuthRedirectBuilder? redirectFor;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: AuthSessionService.instance,
    builder: (context, _) => _buildAuthorized(context),
  );

  Widget _buildAuthorized(BuildContext context) {
    if (!AuthSessionService.instance.isAuthenticated) {
      return const SignedOutRedirect();
    }
    final account = AuthSessionService.instance.currentAccount;
    if (account != null && AuthRouteGuard.allowsRole(account, requiredRole)) {
      return child;
    }
    final redirectFor = this.redirectFor;
    if (account != null && redirectFor != null) {
      return _RoleRedirector(destination: redirectFor(account));
    }
    return const AccountAccessStatusScreen(
      message: 'You do not have permission to access this page.',
    );
  }
}

class _RoleRedirector extends StatefulWidget {
  const _RoleRedirector({required this.destination});

  final Widget destination;

  @override
  State<_RoleRedirector> createState() => _RoleRedirectorState();
}

class _RoleRedirectorState extends State<_RoleRedirector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        agrisellPageRoute<void>(builder: (_) => widget.destination),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) => const AccountAccessStatusScreen(
    message: 'You do not have permission to access this page.',
  );
}
