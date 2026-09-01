import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/shared/widgets/profile/font_size_settings_control.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_settings_action_row.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_settings_layout.dart';
import 'package:agresell_app/features/farmer/profile/presentation/widgets/farmer_gcash_settings_sheet.dart';

class FarmerSettingsPanel extends StatelessWidget {
  const FarmerSettingsPanel({
    required this.profile,
    required this.onEditProfile,
    required this.onEditFarm,
    required this.onSwitchAccount,
    required this.onLogout,
    required this.onBack,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onEditFarm;
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return ProfileCardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileSettingsHeader(onClose: onBack),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 11, 14, 16),
            child: Column(
              children: [
                ProfileSettingsAccountSummary(
                  name: profile.name,
                  email: profile.email,
                ),
                const SizedBox(height: 16),
                ProfileSettingsGroup(
                  title: 'Account',
                  children: [
                    ProfileSettingsActionRow(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit farmer profile',
                      subtitle: 'Update your contact information',
                      onTap: onEditProfile,
                    ),
                    ProfileSettingsActionRow(
                      icon: Icons.agriculture_outlined,
                      title: 'Edit farm',
                      subtitle: 'Update your farm and crop details',
                      onTap: onEditFarm,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const ProfileSettingsGroup(
                  title: 'Display',
                  children: [FontSizeSettingsControl()],
                ),
                const SizedBox(height: 12),
                ProfileSettingsGroup(
                  title: 'Payments',
                  children: [
                    ProfileSettingsActionRow(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'GCash payment details',
                      subtitle: 'Manage the account buyers can pay',
                      onTap: () => showFarmerGcashSettingsSheet(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ProfileSettingsGroup(
                  title: 'Session',
                  children: [
                    ProfileSettingsActionRow(
                      icon: Icons.switch_account_outlined,
                      title: 'Switch account',
                      subtitle: 'Choose a saved account on this device',
                      onTap: onSwitchAccount,
                    ),
                    ProfileSettingsActionRow(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out from this device',
                      onTap: onLogout,
                      isDestructive: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
