import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_verification_details.dart';

import '../styles/rider_application_card_styles.dart';
import 'rider_review_card.dart';
import 'rider_review_section.dart';

class RiderVerificationFeedbackCard extends StatelessWidget {
  const RiderVerificationFeedbackCard({required this.details, super.key});

  final RiderVerificationDetails details;

  @override
  Widget build(BuildContext context) {
    final hasReason = details.hasRejectionReason;
    final hasMessage = details.hasMessage;
    final hasMissing = details.hasMissingItems;
    if (!hasReason && !hasMessage && !hasMissing) {
      return const SizedBox.shrink();
    }

    return RiderReviewCard(
      title: 'ADMIN REVIEW FEEDBACK',
      icon: Icons.rate_review_outlined,
      iconColor: AgrisellColors.forestGreen,
      children: [
        if (hasReason) ...[
          RiderReviewSection(
            title: 'REJECTION REASON',
            icon: Icons.error_outline_rounded,
            variant: RiderReviewSectionVariant.rejection,
            children: [
              Text(
                details.reason!,
                style: RiderApplicationCardStyles.rejectionBody,
              ),
            ],
          ),
          if (hasMessage || hasMissing) const SizedBox(height: 12),
        ],
        if (hasMessage) ...[
          RiderReviewSection(
            title: 'NOTE FROM REVIEWER',
            icon: Icons.comment_outlined,
            variant: RiderReviewSectionVariant.note,
            children: [
              Text(
                details.message!,
                style: RiderApplicationCardStyles.noteBody,
              ),
            ],
          ),
          if (hasMissing) const SizedBox(height: 12),
        ],
        if (hasMissing)
          RiderReviewSection(
            title: 'MISSING OR REQUESTED ITEMS',
            icon: Icons.checklist_rounded,
            variant: RiderReviewSectionVariant.missingItems,
            children: [
              const Text(
                'The reviewer specifically requested updates on the following items:',
                style: RiderApplicationCardStyles.caption,
              ),
              const SizedBox(height: 8),
              for (final item in details.missingItems) _MissingItem(item: item),
            ],
          ),
      ],
    );
  }
}

class _MissingItem extends StatelessWidget {
  const _MissingItem({required this.item});
  final String item;

  @override
  Widget build(BuildContext context) => Padding(
    padding: RiderApplicationCardStyles.missingItemPadding,
    child: Row(
      children: [
        const Icon(
          Icons.check_box_outline_blank_rounded,
          size: 16,
          color: AgrisellColors.statusOrangeText,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(item, style: RiderApplicationCardStyles.documentTitle),
        ),
      ],
    ),
  );
}
