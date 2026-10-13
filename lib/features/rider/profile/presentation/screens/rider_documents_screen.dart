import 'package:agresell_app/features/rider/presentation/widgets/rider_safe_scaffold.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/data/rider_registration_service.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';

class RiderDocumentsScreen extends StatelessWidget {
  const RiderDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = RiderRegistrationService.instance.currentProfile;
    return RiderSafeScaffold(
      appBar: AppBar(title: const Text('Rider credentials')),
      backgroundColor: AgrisellColors.homeBackground,
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          const Text(
            'Your private credentials are available only to you and authorized '
            'Agrisell verification staff.',
            style: SharedPresentationStyles.mutedCaption,
          ),
          const SizedBox(height: 12),
          ListTile(
            tileColor: AgrisellColors.surface,
            leading: const Icon(Icons.badge_outlined),
            title: const Text('License number'),
            subtitle: Text(
              profile?.licenseNumber.isNotEmpty == true
                  ? profile!.licenseNumber
                  : 'Not provided',
            ),
          ),
          const SizedBox(height: 10),
          ListTile(
            tileColor: AgrisellColors.surface,
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Profile photo'),
            subtitle: Text(
              profile?.profilePhotoUrl != null
                  ? 'Profile photo saved'
                  : 'No profile photo',
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Verification documents',
            style: SharedPresentationStyles.subtitleBold,
          ),
          const SizedBox(height: 8),
          if (RiderRegistrationService.instance.currentDocuments.isEmpty)
            const ListTile(
              tileColor: AgrisellColors.surface,
              leading: Icon(Icons.info_outline_rounded),
              title: Text('No verification documents'),
              subtitle: Text('Upload documents from your Rider application.'),
            )
          else
            for (final document
                in RiderRegistrationService.instance.currentDocuments) ...[
              _DocumentTile(document: document),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document});

  final RiderDocument document;

  @override
  Widget build(BuildContext context) => ListTile(
    tileColor: AgrisellColors.surface,
    leading: Icon(
      document.verificationStatus == RiderDocumentVerificationStatus.verified
          ? Icons.verified_rounded
          : document.verificationStatus ==
                RiderDocumentVerificationStatus.rejected
          ? Icons.error_outline_rounded
          : Icons.schedule_rounded,
      color:
          document.verificationStatus ==
              RiderDocumentVerificationStatus.verified
          ? AgrisellColors.statusGreenText
          : document.verificationStatus ==
                RiderDocumentVerificationStatus.rejected
          ? AgrisellColors.statusRedText
          : AgrisellColors.authGreen,
    ),
    title: Text(_label(document.documentType)),
    subtitle: Text(
      document.rejectionReason ?? 'Status: ${document.verificationStatus.name}',
    ),
  );
}

String _label(RiderDocumentType type) => switch (type) {
  RiderDocumentType.driversLicense => 'Driver’s license',
  RiderDocumentType.validId => 'Valid government ID',
  RiderDocumentType.profileSelfie => 'Profile selfie',
  RiderDocumentType.vehicleOr => 'Vehicle official receipt',
  RiderDocumentType.vehicleCr => 'Vehicle registration certificate',
  RiderDocumentType.vehiclePhoto => 'Vehicle photo',
};
