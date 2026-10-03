import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';
import '../styles/rider_application_card_styles.dart';
import '../utils/rider_application_status_content.dart';

export 'rider_verification_feedback_card.dart';
export 'rider_rejected_documents_card.dart';

class RiderApplicationReferenceCard extends StatelessWidget {
  const RiderApplicationReferenceCard({required this.reference, super.key});
  final String reference;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: RiderApplicationCardStyles.referencePadding,
    decoration: RiderApplicationCardStyles.referenceDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'APPLICATION REFERENCE',
          style: RiderApplicationCardStyles.referenceLabel,
        ),
        const SizedBox(height: 3),
        SelectableText(
          reference,
          style: RiderApplicationCardStyles.referenceValue,
        ),
      ],
    ),
  );
}

class RiderApplicationStatusCard extends StatelessWidget {
  const RiderApplicationStatusCard({
    this.isPending = true,
    this.details,
    super.key,
  });

  final bool isPending;
  final RiderVerificationDetails? details;

  @override
  Widget build(BuildContext context) {
    final content = RiderApplicationStatusContent(
      details: details,
      isPending: isPending,
    );
    return Container(
      width: double.infinity,
      padding: RiderApplicationCardStyles.statusPadding,
      decoration: RiderApplicationCardStyles.statusDecoration(content),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: RiderApplicationCardStyles.statusIconPadding,
            decoration: RiderApplicationCardStyles.statusIconDecoration,
            child: Icon(
              RiderApplicationCardStyles.statusIcon(content),
              color: RiderApplicationCardStyles.statusColor(content),
              size: 24,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.title,
                  style: RiderApplicationCardStyles.statusTitle,
                ),
                const SizedBox(height: 5),
                Text(
                  content.description,
                  style: RiderApplicationCardStyles.body,
                ),
                if (details?.reviewedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Reviewed on ${formatRiderReviewDate(details!.reviewedAt!)}',
                    style: RiderApplicationCardStyles.reviewedDate,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class RiderApplicationNextStepsCard extends StatelessWidget {
  const RiderApplicationNextStepsCard({
    this.isPending = true,
    this.details,
    super.key,
  });

  final bool isPending;
  final RiderVerificationDetails? details;

  @override
  Widget build(BuildContext context) {
    final content = RiderApplicationStatusContent(
      details: details,
      isPending: isPending,
    );
    return Container(
      width: double.infinity,
      padding: RiderApplicationCardStyles.cardPadding,
      decoration: RiderApplicationCardStyles.cardDecoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AgrisellColors.forestGreen,
            size: 21,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  content.nextStepsTitle,
                  style: RiderApplicationCardStyles.cardTitle,
                ),
                const SizedBox(height: 5),
                Text(
                  content.nextStepsDescription,
                  style: RiderApplicationCardStyles.body,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
