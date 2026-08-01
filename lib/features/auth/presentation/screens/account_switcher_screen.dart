import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import 'package:agresell_app/features/auth/domain/saved_account.dart';
import 'package:agresell_app/features/auth/presentation/auth_dashboard_router.dart';
import 'package:agresell_app/features/auth/presentation/screens/loginScreen.dart';
import 'package:agresell_app/features/auth/presentation/widgets/account_switcher_content.dart';

class AccountSwitcherScreen extends StatefulWidget {
  const AccountSwitcherScreen({this.allowBack = true, super.key});

  final bool allowBack;

  @override
  State<AccountSwitcherScreen> createState() => _AccountSwitcherScreenState();
}

class _AccountSwitcherScreenState extends State<AccountSwitcherScreen> {
  late Future<List<SavedAccount>> _accounts;
  String? _switchingAccountId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _accounts = AuthSessionService.instance.availableAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(
        automaticallyImplyLeading: widget.allowBack,
        title: const Text(
          'Switch account',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        backgroundColor: AgrisellColors.surface,
        foregroundColor: AgrisellColors.headingGreen,
        surfaceTintColor: AgrisellColors.surface,
      ),
      body: SafeArea(
        child: FutureBuilder<List<SavedAccount>>(
          future: _accounts,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return AccountSwitcherContent(
              accounts: snapshot.data!,
              currentAccountId: AuthSessionService.instance.currentAccount?.id,
              switchingAccountId: _switchingAccountId,
              onSelect: _switchAccount,
              onRemove: _removeAccount,
              onAdd: _addAccount,
            );
          },
        ),
      ),
    );
  }

  Future<void> _switchAccount(SavedAccount selected) async {
    if (_switchingAccountId != null ||
        selected.id == AuthSessionService.instance.currentAccount?.id) {
      return;
    }
    setState(() => _switchingAccountId = selected.id);
    try {
      final account = await AuthSessionService.instance.switchTo(selected.id);
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        agrisellPageRoute<void>(
          builder: (_) => AuthDashboardRouter.destinationFor(account),
        ),
        (route) => false,
      );
    } on SavedAccountSessionException catch (error) {
      if (!mounted) return;
      setState(() => _switchingAccountId = null);
      await Navigator.of(context).push(
        agrisellPageRoute<void>(
          builder: (_) => LoginScreen(
            title: 'Sign in again',
            initialIdentifier: selected.email,
            initialMessage: error.message,
            rememberMeInitially: true,
          ),
        ),
      );
      if (mounted) {
        setState(() {
          _switchingAccountId = null;
          _reload();
        });
      }
    } on Object {
      if (!mounted) return;
      setState(() => _switchingAccountId = null);
      _message('Account switching failed. Check your connection and retry.');
    }
  }

  Future<void> _removeAccount(SavedAccount account) async {
    final remove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove saved account?'),
        content: Text(
          '${account.email} will need to sign in again on this device.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (remove != true) return;
    try {
      await AuthSessionService.instance.removeSavedAccount(account.id);
      if (!mounted) return;
      setState(_reload);
      _message('Saved account removed from this device.');
    } on Object {
      if (mounted) _message('The saved account could not be removed.');
    }
  }

  Future<void> _addAccount() async {
    await Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) =>
            const LoginScreen(title: 'Add account', rememberMeInitially: true),
      ),
    );
    if (mounted) setState(_reload);
  }

  void _message(String value) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(value)));
  }
}
