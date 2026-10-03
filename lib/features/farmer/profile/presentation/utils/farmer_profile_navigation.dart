import 'package:flutter/material.dart';
import 'package:agresell_app/core/models/user_profile.dart';
import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/auth/presentation/account_session_navigation.dart';
import 'package:agresell_app/features/shared/safety/presentation/screens/incident_tracking_screen.dart';
import 'package:agresell_app/features/shared/safety/presentation/widgets/app_safety_sheet.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/screens/farmer_reviews_screen.dart';
import 'package:agresell_app/features/shared/support/presentation/screens/support_center_screen.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'package:agresell_app/features/farmer/verification/presentation/screens/farmer_information_request_screen.dart';

class FarmerProfileNavigation {
  const FarmerProfileNavigation(this.context, this.profile);
  final BuildContext context;
  final UserProfile profile;

  Future<bool?> resubmitInformation(
    FarmerVerificationDetails details,
    FarmerVerificationRepository repository,
  ) => Navigator.of(context).push<bool>(
    agrisellPageRoute<bool>(
      builder: (_) => FarmerInformationRequestScreen(
        details: details,
        repository: repository,
      ),
    ),
  );

  Future<void> openSwitchAccount() =>
      AccountSessionNavigation.openSwitcher(context);

  Future<void> openLogin() => AccountSessionNavigation.logout(context);

  void openSafety() {
    showAppSafetySheet(
      context: context,
      role: 'farmer',
      userName: profile.headerName,
      userContact: profile.phoneNumber,
      userEmail: profile.email,
    );
  }

  void openIncidentHistory() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(
        builder: (_) => IncidentTrackingScreen(
          role: 'farmer',
          userName: profile.headerName,
          userContact: profile.phoneNumber,
          userEmail: profile.email,
        ),
      ),
    );
  }

  void openReviews() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(builder: (_) => const FarmerReviewsScreen()),
    );
  }

  void openSupport() {
    Navigator.of(context).push(
      agrisellPageRoute<void>(builder: (_) => const SupportCenterScreen()),
    );
  }
}
