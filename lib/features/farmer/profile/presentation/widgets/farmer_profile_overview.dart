import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_version_footer.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'package:agresell_app/features/farmer/verification/presentation/widgets/farmer_information_request_banner.dart';
import '../styles/farmer_profile_screen_styles.dart';
import 'farmer_profile_style.dart';
import 'farmer_stats_card.dart';
import 'farmer_profile_info_card.dart';
import 'farmer_history_card.dart';
import 'farmer_gcash_settings_sheet.dart';
import 'farmer_profile_account_tile.dart';

List<Widget> buildFarmerProfileOverview({
  required BuildContext context,
  required UserProfile profile,
  required FarmerVerificationDetails? verificationDetails,
  required VoidCallback onResubmitInformation,
  required VoidCallback onEditProfile,
  required VoidCallback onEditFarm,
  required VoidCallback onReviews,
  required VoidCallback onSafety,
  required VoidCallback onIncidentHistory,
  required VoidCallback onSupport,
  required VoidCallback onSwitchAccount,
  required VoidCallback onLogout,
}) {
  return [
    if (verificationDetails?.isNeedsInformation == true) ...[
      FarmerInformationRequestBanner(
        details: verificationDetails!,
        onTap: onResubmitInformation,
        margin: FarmerProfileScreenStyles.verificationMargin,
      ),
    ],
    const FarmerStatsCard(),
    const SizedBox(height: 18),
    _sectionHeader('Account & Farm'),
    const SizedBox(height: 8),
    FarmerProfileInfoCard(
      profile: profile,
      onEditProfile: onEditProfile,
      initiallyExpanded: false,
    ),
    const SizedBox(height: 10),
    FarmerProfileCard(
      child: Column(
        children: [
          FarmerProfileAccountTile(
            icon: Icons.agriculture_outlined,
            title: 'Edit Farm',
            onTap: onEditFarm,
          ),
          const Divider(height: 1, color: FarmerProfileScreenStyles.divider),
          FarmerProfileAccountTile(
            icon: Icons.account_balance_wallet_outlined,
            title: 'GCash Payment Details',
            onTap: () => showFarmerGcashSettingsSheet(context),
          ),
        ],
      ),
    ),
    const SizedBox(height: 18),
    _sectionHeader('Orders & Feedback'),
    const SizedBox(height: 8),
    const FarmerHistoryCard(),
    const SizedBox(height: 10),
    FarmerProfileCard(
      child: FarmerProfileAccountTile(
        icon: Icons.star_outline_rounded,
        title: 'Customer Reviews & Ratings',
        onTap: onReviews,
      ),
    ),
    const SizedBox(height: 18),
    _sectionHeader('Safety & Support'),
    const SizedBox(height: 8),
    FarmerProfileCard(
      child: Column(
        children: [
          FarmerProfileAccountTile(
            icon: Icons.shield_outlined,
            title: 'Safety & Emergency SOS',
            onTap: onSafety,
          ),
          const Divider(height: 1, color: FarmerProfileScreenStyles.divider),
          FarmerProfileAccountTile(
            icon: Icons.history_rounded,
            title: 'Incident History & Status',
            onTap: onIncidentHistory,
          ),
          const Divider(height: 1, color: FarmerProfileScreenStyles.divider),
          FarmerProfileAccountTile(
            icon: Icons.support_agent_rounded,
            title: 'Customer Support Tickets',
            onTap: onSupport,
          ),
        ],
      ),
    ),
    const SizedBox(height: 18),
    _sectionHeader('Session'),
    const SizedBox(height: 8),
    FarmerProfileCard(
      child: Column(
        children: [
          FarmerProfileAccountTile(
            icon: Icons.switch_account_outlined,
            title: 'Switch Account',
            onTap: onSwitchAccount,
          ),
          const Divider(
            height: 1,
            color: FarmerProfileScreenStyles.sessionDivider,
          ),
          FarmerProfileAccountTile(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            onTap: onLogout,
            destructive: true,
          ),
        ],
      ),
    ),
    const AppVersionFooter(),
  ];
}

Widget _sectionHeader(String title) => Padding(
  padding: FarmerProfileScreenStyles.sectionPadding,
  child: Text(title, style: FarmerProfileScreenStyles.sectionLabel),
);
