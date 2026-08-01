import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/auth/domain/saved_account.dart';

class AccountSwitcherContent extends StatelessWidget {
  const AccountSwitcherContent({
    required this.accounts,
    required this.currentAccountId,
    required this.switchingAccountId,
    required this.onSelect,
    required this.onRemove,
    required this.onAdd,
    super.key,
  });

  final List<SavedAccount> accounts;
  final String? currentAccountId;
  final String? switchingAccountId;
  final ValueChanged<SavedAccount> onSelect;
  final ValueChanged<SavedAccount> onRemove;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
      children: [
        Text(
          accounts.isEmpty
              ? 'No accounts are saved on this device.'
              : 'Choose an account saved on this device.',
          style: const TextStyle(color: AgrisellColors.mutedText, fontSize: 13),
        ),
        const SizedBox(height: 12),
        for (final account in accounts) ...[
          SavedAccountTile(
            account: account,
            isCurrent: account.id == currentAccountId,
            isSwitching: account.id == switchingAccountId,
            onTap: () => onSelect(account),
            onRemove: () => onRemove(account),
          ),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 4),
        Center(
          child: SizedBox(
            width: 280,
            height: 38,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
              label: const Text('Add another account'),
            ),
          ),
        ),
      ],
    );
  }
}

class SavedAccountTile extends StatelessWidget {
  const SavedAccountTile({
    required this.account,
    required this.isCurrent,
    required this.isSwitching,
    required this.onTap,
    required this.onRemove,
    super.key,
  });

  final SavedAccount account;
  final bool isCurrent;
  final bool isSwitching;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AgrisellColors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: isCurrent
              ? AgrisellColors.authGreen
              : AgrisellColors.borderLine,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AgrisellColors.forestSoft,
          foregroundColor: AgrisellColors.authGreen,
          child: Text(
            account.displayName.characters.first.toUpperCase(),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
        ),
        title: Text(
          account.displayName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${account.email} • ${account.assignedRole?.label ?? 'Account'}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12),
        ),
        trailing: isSwitching
            ? const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : isCurrent
            ? const Icon(
                Icons.check_circle_rounded,
                color: AgrisellColors.authGreen,
                semanticLabel: 'Current account',
              )
            : IconButton(
                tooltip: 'Remove ${account.email}',
                onPressed: onRemove,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
      ),
    );
  }
}
