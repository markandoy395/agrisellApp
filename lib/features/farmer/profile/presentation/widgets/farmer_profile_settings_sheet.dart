import 'package:flutter/material.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import '../styles/farmer_profile_screen_styles.dart';
import 'farmer_settings_panel.dart';

enum FarmerSettingsAction {
  editProfile,
  editFarm,
  reviews,
  safety,
  incidentHistory,
  support,
  switchAccount,
  logout,
}

Future<FarmerSettingsAction?> showFarmerProfileSettingsSheet(
  BuildContext context,
  UserProfile profile,
) {
  return showModalBottomSheet<FarmerSettingsAction>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: FarmerProfileScreenStyles.transparent,
    barrierColor: FarmerProfileScreenStyles.settingsBarrier,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: FarmerProfileScreenStyles.initialSettingsSize,
      minChildSize: FarmerProfileScreenStyles.minSettingsSize,
      maxChildSize: FarmerProfileScreenStyles.maxSettingsSize,
      expand: false,
      builder: (context, scrollController) => FarmerSettingsPanel(
        profile: profile,
        scrollController: scrollController,
        onBack: () => Navigator.of(sheetContext).pop(),
        onEditProfile: () =>
            Navigator.of(sheetContext).pop(FarmerSettingsAction.editProfile),
        onEditFarm: () =>
            Navigator.of(sheetContext).pop(FarmerSettingsAction.editFarm),
        onReviews: () =>
            Navigator.of(sheetContext).pop(FarmerSettingsAction.reviews),
        onSafety: () =>
            Navigator.of(sheetContext).pop(FarmerSettingsAction.safety),
        onIncidentHistory: () => Navigator.of(
          sheetContext,
        ).pop(FarmerSettingsAction.incidentHistory),
        onSupport: () =>
            Navigator.of(sheetContext).pop(FarmerSettingsAction.support),
        onSwitchAccount: () =>
            Navigator.of(sheetContext).pop(FarmerSettingsAction.switchAccount),
        onLogout: () =>
            Navigator.of(sheetContext).pop(FarmerSettingsAction.logout),
      ),
    ),
  );
}
