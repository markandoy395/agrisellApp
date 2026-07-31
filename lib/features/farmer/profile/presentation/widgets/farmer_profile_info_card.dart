import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_info_card.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class FarmerProfileInfoCard extends StatelessWidget {
  const FarmerProfileInfoCard({required this.profile, super.key});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final entries = profile.infoEntries;

    return ProfileCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileSectionLabel(text: 'My Profile'),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
            child: Column(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
