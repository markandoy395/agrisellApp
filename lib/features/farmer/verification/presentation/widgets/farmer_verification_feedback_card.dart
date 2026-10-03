import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/verification/domain/farmer_verification_details.dart';

import '../styles/farmer_information_request_styles.dart';
import '../styles/farmer_verification_feedback_styles.dart';

class FarmerVerificationFeedbackCard extends StatelessWidget {
  const FarmerVerificationFeedbackCard({required this.details, super.key});

  final FarmerVerificationDetails details;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: FarmerVerificationFeedbackStyles.feedbackPanel,
      child: Padding(
        padding: FarmerVerificationFeedbackStyles.feedbackPadding,
        child: Column(
          crossAxisAlignment: FarmerInformationRequestStyles.alignStart,
          children: [
            Wrap(
              alignment: FarmerVerificationFeedbackStyles.wrapAlignment,
              crossAxisAlignment:
                  FarmerVerificationFeedbackStyles.wrapCrossAlignment,
              spacing: FarmerInformationRequestStyles.inlineGap,
              runSpacing: FarmerInformationRequestStyles.labelGap,
              children: [
                Container(
                  padding: FarmerVerificationFeedbackStyles.badgePadding,
                  decoration: FarmerVerificationFeedbackStyles.actionBadge,
                  child: const Text(
                    'ACTION REQUIRED',
                    style: FarmerVerificationFeedbackStyles.badgeLabel,
                  ),
                ),
                Text(
                  'Requested: ${details.formattedRequestedDate}',
                  style: FarmerVerificationFeedbackStyles.requestedDate,
                ),
              ],
            ),
            const SizedBox(height: FarmerInformationRequestStyles.sectionGap),
            const Text(
              'NOTE FROM REVIEWER',
              style: FarmerVerificationFeedbackStyles.heading,
            ),
            const SizedBox(height: FarmerInformationRequestStyles.labelGap),
            Container(
              width: FarmerInformationRequestStyles.fullWidth,
              padding: FarmerVerificationFeedbackStyles.notePadding,
              decoration: FarmerVerificationFeedbackStyles.notePanel,
              child: Text(
                details.hasMessage
                    ? details.message!
                    : 'Please review your farmer profile and submit the missing or outdated verification information.',
                style: FarmerVerificationFeedbackStyles.message,
              ),
            ),
            if (details.hasMissingItems) ...[
              const SizedBox(height: FarmerInformationRequestStyles.fieldGap),
              const Text(
                'MISSING OR REQUESTED ITEMS',
                style: FarmerVerificationFeedbackStyles.heading,
              ),
              const SizedBox(height: FarmerInformationRequestStyles.inlineGap),
              for (final item in details.missingItems)
                Padding(
                  padding: FarmerVerificationFeedbackStyles.itemPadding,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_box_outline_blank_rounded,
                        color: FarmerVerificationFeedbackStyles.actionColor,
                        size: FarmerVerificationFeedbackStyles.itemIconSize,
                      ),
                      const SizedBox(
                        width: FarmerInformationRequestStyles.inlineGap,
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: FarmerVerificationFeedbackStyles.missingItem,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
