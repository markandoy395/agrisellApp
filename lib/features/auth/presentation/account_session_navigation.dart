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
    await AuthSessionService.instance.clear();
    if (!context.mounted) return;
    final savedAccounts = await AuthSessionService.instance.availableAccounts();
    if (!context.mounted) return;
    final destination = savedAccounts.isEmpty
        ? const LoginScreen()
        : const AccountSwitcherScreen(allowBack: false);
    Navigator.of(context).pushAndRemoveUntil(
      agrisellPageRoute<void>(builder: (_) => destination),
      (route) => false,
    );
  }
}
