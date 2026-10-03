import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reviews/domain/farmer_review_models.dart';
import '../styles/review_report_appeal_styles.dart';

class ReviewReportAppealConfig {
  const ReviewReportAppealConfig._({
    required this.isAppeal,
    required this.primaryColor,
    required this.headerIcon,
    required this.headerTitle,
    required this.headerSubtitle,
    required this.reasonSectionTitle,
    required this.detailsSectionTitle,
    required this.detailsHint,
    required this.submitButtonLabel,
    required this.reasons,
    required this.submitErrorMessage,
  });

  factory ReviewReportAppealConfig.fromActionType(String actionType) {
    return actionType == 'appeal' ? appeal : report;
  }

  final bool isAppeal;
  final Color primaryColor;
  final IconData headerIcon;
  final String headerTitle;
  final String headerSubtitle;
  final String reasonSectionTitle;
  final String detailsSectionTitle;
  final String detailsHint;
  final String submitButtonLabel;
  final List<String> reasons;
  final String submitErrorMessage;

  static const appeal = ReviewReportAppealConfig._(
    isAppeal: true,
    primaryColor: ReviewReportAppealStyles.appealPrimary,
    headerIcon: Icons.shield_outlined,
    headerTitle: 'Appeal Moderation',
    headerSubtitle: 'Request administrator review for penalties',
    reasonSectionTitle: 'Select Grounds for Appeal',
    detailsSectionTitle: 'Appeal Statement & Explanation',
    detailsHint:
        'Provide clarification, context, or evidence to appeal this moderation decision...',
    submitButtonLabel: 'Submit Appeal',
    reasons: FarmerReview.appealGrounds,
    submitErrorMessage:
        'Unable to submit appeal. Please check your connection and try again.',
  );

  static const report = ReviewReportAppealConfig._(
    isAppeal: false,
    primaryColor: ReviewReportAppealStyles.reportPrimary,
    headerIcon: Icons.flag_outlined,
    headerTitle: 'Report Review',
    headerSubtitle: 'Flag abusive or malicious customer feedback',
    reasonSectionTitle: 'Select Reason for Reporting',
    detailsSectionTitle: 'Additional Context (Optional)',
    detailsHint:
        'Explain why this review violates platform terms or harms your farm...',
    submitButtonLabel: 'Submit Report',
    reasons: FarmerReview.reportReasons,
    submitErrorMessage:
        'Unable to submit report. Please check your connection and try again.',
  );
}
