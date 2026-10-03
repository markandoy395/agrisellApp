import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/features/buyer/profile/presentation/styles/profile_screen_styles.dart';
import 'package:agresell_app/features/buyer/profile/presentation/widgets/buyer_settings_panel.dart';

/// Opens the modal bottom sheet displaying the buyer settings panel.
Future<void> showBuyerSettingsSheet({
  required BuildContext context,
  required UserProfile profile,
  required VoidCallback onEditProfile,
  required VoidCallback onSafety,
  required VoidCallback onIncidentHistory,
  required VoidCallback onSupport,
  required VoidCallback onSwitchAccount,
  required VoidCallback onLogout,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: ProfileScreenStyles.sheetBarrierColor,
    builder: (sheetContext) => DraggableScrollableSheet(
      initialChildSize: ProfileScreenStyles.sheetInitialChildSize,
      minChildSize: ProfileScreenStyles.sheetMinChildSize,
      maxChildSize: ProfileScreenStyles.sheetMaxChildSize,
      expand: false,
      builder: (context, scrollController) => BuyerSettingsPanel(
        profile: profile,
        scrollController: scrollController,
        onBack: () => Navigator.of(sheetContext).pop(),
        onEditProfile: () {
          Navigator.of(sheetContext).pop();
          onEditProfile();
        },
        onSafety: () {
          Navigator.of(sheetContext).pop();
          onSafety();
        },
        onIncidentHistory: () {
          Navigator.of(sheetContext).pop();
          onIncidentHistory();
        },
        onSupport: () {
          Navigator.of(sheetContext).pop();
          onSupport();
        },
        onSwitchAccount: () {
          Navigator.of(sheetContext).pop();
          onSwitchAccount();
        },
        onLogout: () {
          Navigator.of(sheetContext).pop();
          onLogout();
        },
      ),
    ),
  );
}
