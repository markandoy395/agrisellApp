import 'package:flutter/material.dart';

import 'package:agresell_app/core/utils/agrisell_page_route.dart';
import 'package:agresell_app/features/farmer/verification/data/farmer_verification_repository.dart';
import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';
import 'package:agresell_app/features/farmer/verification/presentation/screens/farmer_information_request_screen.dart';

abstract final class FarmerVerificationCoordinator {
  static Future<FarmerVerificationDetails?> loadVerificationDetails(
    FarmerVerificationRepository repository,
  ) => repository.loadVerificationDetails();

  static Future<FarmerVerificationDetails?> resubmitInformation({
    required BuildContext context,
    required FarmerVerificationRepository repository,
    required FarmerVerificationDetails? details,
  }) async {
    if (details == null) return null;
    final resubmitted = await Navigator.of(context).push<bool>(
      agrisellPageRoute<bool>(
        builder: (_) => FarmerInformationRequestScreen(
          details: details,
          repository: repository,
        ),
      ),
    );
    if (resubmitted == true) {
      return repository.loadVerificationDetails();
    }
    return null;
  }
}
