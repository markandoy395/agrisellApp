import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';
import '../styles/rider_application_card_styles.dart';

class RiderRejectedDocumentItem extends StatelessWidget {
  const RiderRejectedDocumentItem({required this.doc, super.key});

  final RiderVerificationDocumentItem doc;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: RiderApplicationCardStyles.documentMargin,
    padding: RiderApplicationCardStyles.sectionPadding,
    decoration: RiderApplicationCardStyles.documentDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.description_outlined,
              size: 18,
              color: AgrisellColors.headingGreen,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                doc.displayName,
                style: RiderApplicationCardStyles.documentTitle,
              ),
            ),
            Container(
              padding: RiderApplicationCardStyles.rejectedBadgePadding,
              decoration: RiderApplicationCardStyles.rejectedBadgeDecoration,
              child: const Text(
                'Rejected',
                style: RiderApplicationCardStyles.rejectedBadgeText,
              ),
            ),
          ],
        ),
        if (doc.documentNumber != null && doc.documentNumber!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            'Number: ${doc.documentNumber}',
            style: RiderApplicationCardStyles.caption,
          ),
        ],
        if (doc.rejectionReason != null &&
            doc.rejectionReason!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: RiderApplicationCardStyles.documentReasonPadding,
            decoration: RiderApplicationCardStyles.documentReasonDecoration,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: AgrisellColors.statusRedText,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    doc.rejectionReason!,
                    style: RiderApplicationCardStyles.documentReasonText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}
