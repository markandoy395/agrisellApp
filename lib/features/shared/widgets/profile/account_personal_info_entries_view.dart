import 'package:flutter/material.dart';

import 'package:agresell_app/features/shared/widgets/profile/account_personal_info_styles.dart';

class AccountPersonalInfoEntriesView extends StatelessWidget {
  const AccountPersonalInfoEntriesView({
    required this.entries,
    this.onEditProfile,
    super.key,
  });

  final List<(String, String)> entries;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AccountPersonalInfoStyles.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Account details',
                  style: AccountPersonalInfoStyles.sectionTitleStyle,
                ),
              ),
              if (onEditProfile != null)
                TextButton.icon(
                  onPressed: onEditProfile,
                  style: AccountPersonalInfoStyles.editButtonStyle,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: AccountPersonalInfoStyles.editIconSize,
                  ),
                  label: const Text(
                    'Edit',
                    style: AccountPersonalInfoStyles.editButtonTextStyle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Divider(
            height: 1,
            color: AccountPersonalInfoStyles.dividerMedium,
          ),
          for (var index = 0; index < entries.length; index++) ...[
            Padding(
              padding: AccountPersonalInfoStyles.entryPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(
                      entries[index].$1,
                      style: AccountPersonalInfoStyles.entryLabelStyle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 5,
                    child: Text(
                      entries[index].$2.trim().isEmpty
                          ? '—'
                          : entries[index].$2,
                      style: AccountPersonalInfoStyles.entryValueStyle,
                    ),
                  ),
                ],
              ),
            ),
            if (index < entries.length - 1)
              const Divider(
                height: 1,
                color: AccountPersonalInfoStyles.dividerItem,
              ),
          ],
        ],
      ),
    );
  }
}
