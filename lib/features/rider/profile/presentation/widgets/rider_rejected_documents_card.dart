import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';

import 'rider_rejected_document_item.dart';
import 'rider_review_card.dart';

class RiderRejectedDocumentsCard extends StatelessWidget {
  const RiderRejectedDocumentsCard({required this.details, super.key});

  final RiderVerificationDetails details;

  @override
  Widget build(BuildContext context) {
    final documents = details.rejectedDocuments;
    if (documents.isEmpty) return const SizedBox.shrink();

    return RiderReviewCard(
      title: 'DOCUMENT FEEDBACK',
      icon: Icons.folder_off_outlined,
      iconColor: AgrisellColors.statusRedText,
      description:
          'The following documents require attention or re-submission:',
      children: [
        for (final document in documents)
          RiderRejectedDocumentItem(doc: document),
      ],
    );
  }
}
