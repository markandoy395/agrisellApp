import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/profile_birth_date.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_card_style.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_personal_info_entries_view.dart';
import 'package:agresell_app/features/shared/widgets/profile/account_personal_info_styles.dart';

class AccountPersonalInfoCard extends StatefulWidget {
  const AccountPersonalInfoCard({
    required this.profile,
    this.onEditProfile,
    this.initiallyExpanded = true,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback? onEditProfile;
  final bool initiallyExpanded;

  @override
  State<AccountPersonalInfoCard> createState() =>
      _AccountPersonalInfoCardState();
}

class _AccountPersonalInfoCardState extends State<AccountPersonalInfoCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant AccountPersonalInfoCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _isExpanded = widget.initiallyExpanded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final birthDate =
        ProfileBirthDate.parse(widget.profile.dateOfBirth).formatted;
    final entries = [
      ('First name', widget.profile.firstName),
      ('Last name', widget.profile.lastName),
      ('Name extension', widget.profile.extensionName),
      ('Phone number', widget.profile.phoneNumber),
      (
        'Date of birth',
        birthDate.isEmpty ? widget.profile.dateOfBirth : birthDate,
      ),
      ('Email', widget.profile.email),
    ];

    return AccountProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: AccountPersonalInfoStyles.headerPadding,
              child: Row(
                children: [
                  Container(
                    width: AccountPersonalInfoStyles.iconContainerSize,
                    height: AccountPersonalInfoStyles.iconContainerSize,
                    decoration: AccountPersonalInfoStyles.headerIconDecoration,
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: AccountProfileStyle.green,
                      size: AccountPersonalInfoStyles.iconSize,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Personal information',
                      style: AccountPersonalInfoStyles.headerTitleStyle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: () => setState(() => _isExpanded = !_isExpanded),
                    style: AccountPersonalInfoStyles.toggleButtonStyle(
                      _isExpanded,
                    ),
                    icon: Icon(
                      _isExpanded
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 16,
                    ),
                    label: Text(
                      _isExpanded ? 'Hide' : 'Display',
                      style: AccountPersonalInfoStyles.toggleButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded) ...[
            const Divider(
              height: 1,
              color: AccountPersonalInfoStyles.dividerLight,
            ),
            AccountPersonalInfoEntriesView(
              entries: entries,
              onEditProfile: widget.onEditProfile,
            ),
          ],
        ],
      ),
    );
  }
}
