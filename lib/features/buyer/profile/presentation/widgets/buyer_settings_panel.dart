import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_version_footer.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import '../styles/buyer_settings_panel_styles.dart';
import 'buyer_settings_action_tile.dart';
import 'buyer_settings_group.dart';
import 'buyer_settings_header.dart';
import 'buyer_settings_identity_card.dart';

class BuyerSettingsPanel extends StatelessWidget {
  const BuyerSettingsPanel({
    required this.profile,
    required this.onEditProfile,
    required this.onSwitchAccount,
    required this.onLogout,
    required this.onBack,
    this.onSafety,
    this.onIncidentHistory,
    this.onSupport,
    this.scrollController,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onEditProfile;
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;
  final VoidCallback onBack;
  final VoidCallback? onSafety;
  final VoidCallback? onIncidentHistory;
  final VoidCallback? onSupport;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) => Material(
    color: BuyerSettingsPanelStyles.panelBackground,
    borderRadius: BuyerSettingsPanelStyles.panelBorderRadius,
    clipBehavior: Clip.antiAlias,
    child: SafeArea(
      top: false,
      child: Column(
        children: [
          BuyerSettingsHeader(onBack: onBack),
          BuyerSettingsIdentityCard(profile: profile),
          BuyerSettingsPanelStyles.spacingIdentityToList,
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: BuyerSettingsPanelStyles.listPadding,
              children: [
                BuyerSettingsGroup(
                  title: 'Account',
                  children: [
                    BuyerSettingsActionTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit buyer profile',
                      onTap: onEditProfile,
                    ),
                  ],
                ),
                BuyerSettingsGroup(
                  title: 'Safety',
                  children: [
                    if (onSafety != null)
                      BuyerSettingsActionTile(
                        icon: Icons.shield_outlined,
                        title: 'Safety & emergency SOS',
                        onTap: onSafety!,
                      ),
                    if (onIncidentHistory != null)
                      BuyerSettingsActionTile(
                        icon: Icons.history_rounded,
                        title: 'Incident history & status',
                        onTap: onIncidentHistory!,
                      ),
                  ],
                ),
                BuyerSettingsGroup(
                  title: 'Support',
                  children: [
                    BuyerSettingsActionTile(
                      icon: Icons.support_agent_rounded,
                      title: 'Customer support tickets',
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
                BuyerSettingsGroup(
                  title: 'Session',
                  children: [
                    BuyerSettingsActionTile(
                      icon: Icons.switch_account_outlined,
                      title: 'Switch account',
                      onTap: onSwitchAccount,
                    ),
                    BuyerSettingsActionTile(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
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
