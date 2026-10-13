import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/presentation/screens/account_switcher_screen.dart';
import 'package:agresell_app/features/auth/presentation/screens/login_screen.dart';

abstract final class AccountSessionNavigation {
  static Future<void> openSwitcher(BuildContext context) async {
    await AuthSessionService.instance.preserveCurrentAccountForSwitch();
    if (!context.mounted) return;
    await Navigator.of(context).push(
      agrisellPageRoute<void>(builder: (_) => const AccountSwitcherScreen()),
    );
  }

  static Future<void> logout(BuildContext context) async {
    final identifier = AuthSessionService.instance.currentAccount?.email;
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      agrisellPageRoute<void>(
        settings: const RouteSettings(name: 'auth.login'),
        builder: (_) => LoginScreen(
          initialIdentifier: identifier ?? '',
          signOutOnOpen: true,
        ),
      ),
      (route) => false,
    );
  }
}
