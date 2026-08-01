import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({required this.entries, this.onEditProfile, super.key});

  final List<ProfileInfoEntry> entries;
  final VoidCallback? onEditProfile;

  @override
  Widget build(BuildContext context) {
    final isEditable = onEditProfile != null;
    final minCardHeight = MediaQuery.sizeOf(context).width < 380
        ? (isEditable ? 386.0 : 346.0)
        : (isEditable ? 408.0 : 368.0);

    return ProfileCardShell(
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minCardHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileSectionLabel(text: 'My Profile'),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Manage and protect your account',
                      style: ProfileTextStyles.profileDescription(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AgrisellColors.dividerLine,
                  ),
                  const SizedBox(height: 10),
                  for (final entry in entries) ProfileInfoRow(entry: entry),
                  if (isEditable) ...[
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 118,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: onEditProfile,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AgrisellColors.authGreen,
                            side: const BorderSide(
                              color: AgrisellColors.authGreen,
                              width: 1.4,
                            ),
                            shape: const StadiumBorder(),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Edit Profile',
                            style: ProfileTextStyles.editButton(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  const ProfileInfoRow({required this.entry, super.key});

  final ProfileInfoEntry entry;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final labelWidth = width < 380 ? 90.0 : 108.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: labelWidth,
            child: Text(
              entry.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: ProfileTextStyles.infoLabel(context),
            ),
          ),
          const SizedBox(width: 12),
          Text(':', style: ProfileTextStyles.infoLabel(context)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              entry.value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ProfileTextStyles.infoValue(context),
            ),
          ),
        ],
      ),
    );
  }
}
