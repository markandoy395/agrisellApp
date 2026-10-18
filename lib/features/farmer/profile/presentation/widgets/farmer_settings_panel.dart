import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_version_footer.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import '../styles/farmer_settings_panel_styles.dart';
import 'farmer_gcash_settings_sheet.dart';
import 'farmer_settings_action_tile.dart';
import 'farmer_settings_group.dart';
import 'farmer_settings_header.dart';
import 'farmer_settings_identity_card.dart';

class FarmerSettingsPanel extends StatelessWidget {
  const FarmerSettingsPanel({
    required this.profile,
    required this.onEditProfile,
    required this.onEditFarm,
    required this.onSwitchAccount,
    required this.onLogout,
    required this.onBack,
    this.onReviews,
    this.onSafety,
    this.onIncidentHistory,
    this.onSupport,
    this.scrollController,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onEditFarm;
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;
  final VoidCallback onBack;
  final VoidCallback? onReviews;
  final VoidCallback? onSafety;
  final VoidCallback? onIncidentHistory;
  final VoidCallback? onSupport;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => Material(
    color: FarmerSettingsPanelStyles.panelBackground,
    borderRadius: FarmerSettingsPanelStyles.panelBorderRadius,
    clipBehavior: Clip.antiAlias,
    child: SafeArea(
      top: false,
      child: Column(
        children: [
          FarmerSettingsHeader(onBack: onBack),
          FarmerSettingsIdentityCard(profile: profile),
          FarmerSettingsPanelStyles.spacingIdentityToList,
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: FarmerSettingsPanelStyles.listPadding,
              children: [
                FarmerSettingsGroup(
                  title: 'Account',
                  children: [
                    FarmerSettingsActionTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit farmer profile',
                      subtitle: 'Update your contact information',
                      onTap: onEditProfile,
                    ),
                    FarmerSettingsActionTile(
                      icon: Icons.agriculture_outlined,
                      title: 'Edit farm',
                      subtitle: 'Update your farm and crop details',
                      onTap: onEditFarm,
                    ),
                  ],
                ),
                FarmerSettingsGroup(
                  title: 'Reviews & Feedback',
                  children: [
                    if (onReviews != null)
                      FarmerSettingsActionTile(
                        icon: Icons.star_outline_rounded,
                        title: 'Customer reviews & ratings',
                        subtitle: 'View ratings breakdown and buyer feedback',
                        onTap: onReviews!,
                      ),
                  ],
                ),
                FarmerSettingsGroup(
                  title: 'Safety',
                  children: [
                    if (onSafety != null)
                      FarmerSettingsActionTile(
                        icon: Icons.shield_outlined,
                        title: 'Safety & emergency SOS',
                        subtitle: 'Report a safety issue or emergency alert',
                        onTap: onSafety!,
                      ),
                    if (onIncidentHistory != null)
                      FarmerSettingsActionTile(
                        icon: Icons.history_rounded,
                        title: 'Incident history & status',
                        subtitle: 'Track status of submitted safety reports',
                        onTap: onIncidentHistory!,
                      ),
                  ],
                ),
                FarmerSettingsGroup(
                  title: 'Payments',
                  children: [
                    FarmerSettingsActionTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: 'GCash payment details',
                      subtitle: 'Manage where buyers send payments',
                      onTap: () => showFarmerGcashSettingsSheet(context),
                    ),
                  ],
                ),
                FarmerSettingsGroup(
                  title: 'Help & Support',
                  children: [
                    FarmerSettingsActionTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Customer support tickets',
                      subtitle:
                          'Open and track helpdesk inquiries with Agrisell',
                      onTap:
                          onSupport ??
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
                FarmerSettingsGroup(
                  title: 'Session',
                  children: [
                    FarmerSettingsActionTile(
                      icon: Icons.switch_account_outlined,
                      title: 'Switch account',
                      subtitle: 'Choose a saved account on this device',
                      onTap: onSwitchAccount,
                    ),
                    FarmerSettingsActionTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out of this device',
                      onTap: onLogout,
                      destructive: true,
                    ),
                  ],
                ),
                const AppVersionFooter(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
