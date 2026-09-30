import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import 'package:agresell_app/features/shared/widgets/profile/font_size_settings_control.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_card_shell.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_settings_action_row.dart';
import 'package:agresell_app/features/shared/widgets/profile/profile_settings_layout.dart';

class RiderSettingsPanel extends StatelessWidget {
  const RiderSettingsPanel({
    required this.profile,
    required this.onEditProfile,
    required this.onVehicle,
    required this.onDocuments,
    required this.onChangePassword,
    required this.onSafety,
    required this.onSwitchAccount,
    required this.onLogout,
    required this.onBack,
    this.onIncidentHistory,
    this.onSupport,
    super.key,
  });

  final RiderProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onVehicle;
  final VoidCallback onDocuments;
  final VoidCallback onChangePassword;
  final VoidCallback onSafety;
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;
  final VoidCallback onBack;
  final VoidCallback? onIncidentHistory;
  final VoidCallback? onSupport;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 156),
      children: [
        ProfileCardShell(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileSettingsHeader(onClose: onBack),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 11, 14, 16),
                child: Column(
                  children: [
                    ProfileSettingsAccountSummary(
                      name: profile.fullName,
                      email: profile.email,
                    ),
                    const SizedBox(height: 16),
                    ProfileSettingsGroup(
                      title: 'Account',
                      children: [
                        ProfileSettingsActionRow(
                          icon: Icons.edit_outlined,
                          title: 'Edit rider profile',
                          subtitle: 'Update your contact and address details',
                          onTap: onEditProfile,
                        ),
                        ProfileSettingsActionRow(
                          icon: Icons.two_wheeler_outlined,
                          title: 'Vehicle details',
                          subtitle: 'Review your registered vehicle',
                          onTap: onVehicle,
                        ),
                        ProfileSettingsActionRow(
                          icon: Icons.folder_shared_outlined,
                          title: 'Verification documents',
                          subtitle: 'Review your submitted documents',
                          onTap: onDocuments,
                        ),
                        ProfileSettingsActionRow(
                          icon: Icons.lock_outline_rounded,
                          title: 'Change password',
                          subtitle: 'Update your account password',
                          onTap: onChangePassword,
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
                      title: 'Safety',
                      children: [
                        ProfileSettingsActionRow(
                          icon: Icons.shield_outlined,
                          title: 'Safety & emergency SOS',
                          subtitle: 'Report a safety issue or emergency alert',
                          onTap: onSafety,
                        ),
                        if (onIncidentHistory != null)
                          ProfileSettingsActionRow(
                            icon: Icons.history_rounded,
                            title: 'Incident history & status',
                            subtitle: 'Track status of submitted safety reports',
                            onTap: onIncidentHistory!,
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ProfileSettingsGroup(
                      title: 'Support',
                      children: [
                        ProfileSettingsActionRow(
                          icon: Icons.support_agent_rounded,
                          title: 'Customer support tickets',
                          subtitle: 'Open and track helpdesk inquiries',
                          onTap: onSupport ??
                              () {
                                Navigator.of(context).push(
                                  agrisellPageRoute<void>(
                                    builder: (_) => const SupportCenterScreen(),
                                  ),
                                );
                              },
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
        ),
      ],
    );
  }
}
