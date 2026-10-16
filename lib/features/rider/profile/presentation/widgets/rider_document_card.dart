import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/rider_document.dart';
import '../styles/rider_profile_design_styles.dart';

String riderDocumentLabel(RiderDocumentType type) => switch (type) {
  RiderDocumentType.driversLicense => "Driver's license",
  RiderDocumentType.validId => 'Valid government ID',
  RiderDocumentType.profileSelfie => 'Profile selfie',
  RiderDocumentType.vehicleOr => 'Vehicle official receipt',
  RiderDocumentType.vehicleCr => 'Vehicle registration certificate',
  RiderDocumentType.vehiclePhoto => 'Vehicle photo',
};

IconData riderDocumentIcon(RiderDocumentType type) => switch (type) {
  RiderDocumentType.driversLicense => Icons.badge_outlined,
  RiderDocumentType.validId => Icons.perm_identity_rounded,
  RiderDocumentType.profileSelfie => Icons.account_circle_outlined,
  RiderDocumentType.vehicleOr => Icons.receipt_long_outlined,
  RiderDocumentType.vehicleCr => Icons.description_outlined,
  RiderDocumentType.vehiclePhoto => Icons.two_wheeler_outlined,
};

class RiderDocumentCard extends StatelessWidget {
  const RiderDocumentCard({required this.document, this.onTap, super.key});
  final RiderDocument document;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    final status = document.verificationStatus;
    final color = switch (status) {
      RiderDocumentVerificationStatus.verified => AgrisellColors.authGreen,
      RiderDocumentVerificationStatus.pending =>
        AgrisellColors.statusOrangeText,
      RiderDocumentVerificationStatus.rejected => AgrisellColors.statusRedText,
    };
    return Container(
      decoration: RiderProfileDesignStyles.card,
      child: Material(
        type: MaterialType.transparency,
        child: ListTile(
          contentPadding: const EdgeInsets.all(14),
          onTap: onTap,
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: RiderProfileDesignStyles.badge(color),
            child: Icon(
              riderDocumentIcon(document.documentType),
              color: color,
              size: 28,
            ),
          ),
          title: Text(
            riderDocumentLabel(document.documentType),
            style: RiderProfileDesignStyles.body,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 5),
              Row(
                children: [
                  Icon(
                    switch (status) {
                      RiderDocumentVerificationStatus.verified =>
                        Icons.check_circle_rounded,
                      RiderDocumentVerificationStatus.pending =>
                        Icons.schedule_rounded,
                      RiderDocumentVerificationStatus.rejected =>
                        Icons.error_outline_rounded,
                    },
                    color: color,
                    size: 16,
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      '${status.name[0].toUpperCase()}${status.name.substring(1)}',
                      style: RiderProfileDesignStyles.body,
                    ),
                  ),
                ],
              ),
              if (document.createdAt case final date?) ...[
                const SizedBox(height: 4),
                Text(
                  'Uploaded on ${MaterialLocalizations.of(context).formatMediumDate(date.toLocal())}',
                  style: RiderProfileDesignStyles.caption,
                ),
              ],
              if (document.rejectionReason case final reason?)
                Text(reason, style: RiderProfileDesignStyles.caption),
            ],
          ),
          trailing: onTap == null
              ? null
              : const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }
}
