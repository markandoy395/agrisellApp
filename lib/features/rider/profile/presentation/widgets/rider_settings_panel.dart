import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_version_footer.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import '../styles/rider_profile_design_styles.dart';
import 'rider_settings_action.dart';
import 'rider_profile_design_components.dart';

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
  Widget build(BuildContext context) => SafeArea(
    bottom: false,
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 18, 6),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Close settings',
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              Text('Settings', style: RiderProfileDesignStyles.heading),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
            children: [
              RiderSettingsAction(
                icon: Icons.edit_outlined,
                title: 'Edit rider profile',
                subtitle: 'Update your contact and address details',
                onTap: onEditProfile,
              ),
              RiderSettingsAction(
                icon: Icons.two_wheeler_outlined,
                title: 'Vehicle details',
                subtitle: 'Review your registered vehicle',
                color: AgrisellColors.statusBlueText,
                onTap: onVehicle,
              ),
              RiderSettingsAction(
                icon: Icons.folder_shared_outlined,
                title: 'Verification documents',
                subtitle: 'Review your submitted documents',
                onTap: onDocuments,
              ),
              RiderSettingsAction(
                icon: Icons.lock_outline_rounded,
                title: 'Change password',
                subtitle: 'Update your account password',
                color: AgrisellColors.statusOrangeText,
                onTap: onChangePassword,
              ),
              _heading('Safety'),
              RiderProfileCard(
                child: Column(
                  children: [
                    RiderSettingsAction(
                      icon: Icons.shield_outlined,
                      title: 'Safety & emergency SOS',
                      subtitle: 'Report a safety issue or emergency alert',
                      color: AgrisellColors.statusRedText,
                      onTap: onSafety,
                    ),
                    if (onIncidentHistory != null)
                      RiderSettingsAction(
                        icon: Icons.history_rounded,
                        title: 'Incident history & status',
                        subtitle: 'Track status of submitted safety reports',
                        color: AgrisellColors.statusOrangeText,
                        onTap: onIncidentHistory!,
                      ),
                  ],
                ),
              ),
              _heading('Support'),
              RiderProfileCard(
                child: RiderSettingsAction(
                  icon: Icons.support_agent_rounded,
                  title: 'Customer support tickets',
                  subtitle: 'Open and track helpdesk inquiries',
                  color: AgrisellColors.statusBlueText,
                  onTap:
                      onSupport ??
                      () => Navigator.of(context).push(
                        agrisellPageRoute<void>(
                          builder: (_) => const SupportCenterScreen(),
                        ),
                      ),
                ),
              ),
              _heading('Account'),
              RiderProfileCard(
                child: Column(
                  children: [
                    RiderSettingsAction(
                      icon: Icons.switch_account_outlined,
                      title: 'Switch account',
                      subtitle: 'Choose a saved account on this device',
                      onTap: onSwitchAccount,
                    ),
                    RiderSettingsAction(
                      icon: Icons.logout_rounded,
                      title: 'Logout',
                      subtitle: 'Sign out from this device',
                      color: AgrisellColors.statusRedText,
                      onTap: onLogout,
                    ),
                  ],
                ),
              ),
              const AppVersionFooter(),
            ],
          ),
        ),
      ],
    ),
  );
  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 12),
    child: Text(text, style: RiderProfileDesignStyles.title),
  );
}
