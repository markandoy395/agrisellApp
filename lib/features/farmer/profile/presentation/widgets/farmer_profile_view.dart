import 'package:flutter/material.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/auth/data/auth_session_service.dart';
import '../controllers/farmer_profile_controller.dart';
import '../styles/farmer_profile_screen_styles.dart';
import 'farmer_profile_header.dart';
import 'farmer_profile_edit_card.dart';
import 'farmer_farm_edit_card.dart';
import 'farmer_profile_overview.dart';

class FarmerProfileView extends StatelessWidget {
  const FarmerProfileView({
    super.key,
    required this.controller,
    required this.showSettingsIcon,
    required this.onSave,
    required this.onCancelEdit,
    required this.onSettings,
    required this.onResubmitInformation,
    required this.onEditProfile,
    required this.onEditFarm,
    required this.onReviews,
    required this.onSafety,
    required this.onIncidentHistory,
    required this.onSupport,
    required this.onSwitchAccount,
    required this.onLogout,
  });
  final FarmerProfileController controller;
  final bool showSettingsIcon;
  final Future<void> Function(UserProfile) onSave;
  final VoidCallback onCancelEdit;
  final VoidCallback onSettings;
  final VoidCallback onResubmitInformation;
  final VoidCallback onEditProfile;
  final VoidCallback onEditFarm;
  final VoidCallback onReviews;
  final VoidCallback onSafety;
  final VoidCallback onIncidentHistory;
  final VoidCallback onSupport;
  final VoidCallback onSwitchAccount;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: FarmerProfileScreenStyles.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: FarmerProfileScreenStyles.contentPadding(context),
              sliver: SliverList.list(
                children: [
                  FarmerProfileHeader(
                    title: controller.mode == FarmerProfileMode.edit
                        ? 'Edit Profile'
                        : controller.mode == FarmerProfileMode.editFarm
                        ? 'Edit Farm'
                        : 'Account',
                    onBack:
                        controller.mode == FarmerProfileMode.edit ||
                            controller.mode == FarmerProfileMode.editFarm
                        ? onCancelEdit
                        : null,
                    profile: controller.profile,
                    followingCount: controller.followCounts.followingCount,
                    followerCount: controller.followCounts.followerCount,
                    isVerified:
                        AuthSessionService
                            .instance
                            .currentAccount
                            ?.isFarmerVerified ??
                        false,
                    onSettingsTap: showSettingsIcon ? onSettings : null,
                  ),
                  const SizedBox(height: 14),
                  if (controller.mode == FarmerProfileMode.edit)
                    FarmerProfileEditCard(
                      profile: controller.profile,
                      onCancel: onCancelEdit,
                      onSave: onSave,
                    )
                  else if (controller.mode == FarmerProfileMode.editFarm)
                    FarmerFarmEditCard(onCancel: onCancelEdit)
                  else
                    ...buildFarmerProfileOverview(
                      context: context,
                      profile: controller.profile,
                      verificationDetails: controller.verificationDetails,
                      onResubmitInformation: onResubmitInformation,
                      onEditProfile: onEditProfile,
                      onEditFarm: onEditFarm,
                      onReviews: onReviews,
                      onSafety: onSafety,
                      onIncidentHistory: onIncidentHistory,
                      onSupport: onSupport,
                      onSwitchAccount: onSwitchAccount,
                      onLogout: onLogout,
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
