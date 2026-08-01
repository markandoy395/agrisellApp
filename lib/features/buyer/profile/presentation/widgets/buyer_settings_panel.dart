import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/shared/widgets/profile/farmer_settings_row.dart';
import 'package:agresell_app/features/shared/widgets/profile/font_size_settings_control.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_section_label.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_text_styles.dart';

class BuyerSettingsPanel extends StatelessWidget {
  const BuyerSettingsPanel({
    required this.profile,
    required this.onEditProfile,
    required this.onSwitchAccount,
    required this.onLogout,
    required this.onBack,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ProfileCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const ProfileSectionLabel(text: 'Settings'),
              const Spacer(),
              IconButton(
                tooltip: 'Close settings',
                constraints: const BoxConstraints.tightFor(
                  width: 38,
                  height: 38,
                ),
                padding: EdgeInsets.zero,
                onPressed: onBack,
                icon: const Icon(Icons.close_rounded, size: 22),
              ),
              const SizedBox(width: 7),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 16),
            child: Column(
              children: [
                _BuyerSettingsSummary(profile: profile),
                const SizedBox(height: 10),
                const Divider(height: 1),
                const SizedBox(height: 5),
                const FontSizeSettingsControl(),
                const Divider(height: 1),
                FarmerSettingsActionRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Edit buyer profile',
                  subtitle: 'Update your contact details',
                  onTap: onEditProfile,
                ),
                FarmerSettingsActionRow(
                  icon: Icons.switch_account_outlined,
                  title: 'Switch account',
                  subtitle: 'Choose a saved account on this device',
                  onTap: onSwitchAccount,
                ),
                FarmerSettingsActionRow(
                  icon: Icons.logout_rounded,
                  title: 'Logout',
                  subtitle: 'Sign out from this device',
                  onTap: onLogout,
                  isDestructive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuyerSettingsSummary extends StatelessWidget {
  const _BuyerSettingsSummary({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AgrisellColors.limeSoft,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AgrisellColors.borderLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                color: AgrisellColors.authGreen,
                shape: BoxShape.circle,
              ),
              child: SizedBox.square(
                dimension: 34,
                child: Icon(
                  Icons.manage_accounts_rounded,
                  color: AgrisellColors.surface,
                  size: 19,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ProfileTextStyles.infoLabel(
                      context,
                    ).copyWith(fontWeight: FontWeight.w700, height: 1.1),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    profile.email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: ProfileTextStyles.profileDescription(
                      context,
                    ).copyWith(fontSize: 12, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
