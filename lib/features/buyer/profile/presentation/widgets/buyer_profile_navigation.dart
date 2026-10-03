import 'package:flutter/material.dart';

import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';

/// Navigation routes and modal sheets for buyer profile options.
abstract final class BuyerProfileNavigation {
  static void openSafety(BuildContext context, UserProfile profile) {
    showAppSafetySheet(
      context: context,
      role: 'buyer',
      userName: profile.headerName,
      userContact: profile.phoneNumber,
      userEmail: profile.email,
    );
  }

  static void openIncidentHistory(BuildContext context, UserProfile profile) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => IncidentTrackingScreen(
          role: 'buyer',
          userName: profile.headerName,
          userContact: profile.phoneNumber,
          userEmail: profile.email,
        ),
      ),
    );
  }

  static void openSupport(BuildContext context) {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => const SupportCenterScreen(),
      ),
    );
  }
}
