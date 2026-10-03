import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/profile/presentation/styles/rider_application_review_styles.dart';
import '../utils/rider_application_status_content.dart';

export 'package:agresell_app/features/rider/profile/presentation/styles/rider_application_review_styles.dart';

abstract final class RiderApplicationCardStyles {
  static const referencePadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 12,
  );

  static final referenceDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const referenceLabel = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const referenceValue = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const statusPadding = EdgeInsets.all(18);

  static const statusIconPadding = EdgeInsets.all(9);

  static final statusIconDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(10),
  );

  static const statusTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const body = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.35,
  );

  static const reviewedDate = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontStyle: FontStyle.italic,
  );

  static const cardPadding = EdgeInsets.all(16);

  static final cardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(color: AgrisellColors.borderLine),
  );

  static const cardTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const documentMargin = EdgeInsets.only(bottom: 10);

  static const sectionPadding = EdgeInsets.all(12);

  static final documentDecoration = BoxDecoration(
    color: AgrisellColors.homeBackground,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
      color: AgrisellColors.statusRedText.withValues(alpha: .2),
    ),
  );

  static const documentTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const rejectedBadgePadding = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 3,
  );

  static final rejectedBadgeDecoration = BoxDecoration(
    color: AgrisellColors.statusRedBackground,
    borderRadius: BorderRadius.circular(6),
    border: Border.all(
      color: AgrisellColors.statusRedText.withValues(alpha: .24),
    ),
  );

  static const rejectedBadgeText = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const caption = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const documentReasonPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 8,
  );

  static final documentReasonDecoration = BoxDecoration(
    color: AgrisellColors.statusRedBackground.withValues(alpha: .5),
    borderRadius: BorderRadius.circular(6),
  );

  static const documentReasonText = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );

  static Color statusColor(RiderApplicationStatusContent content) {
    if (content.isApproved) return AgrisellColors.statusGreenText;
    if (content.isNeedsInfo) return AgrisellColors.statusOrangeText;
    if (content.isRejected) return AgrisellColors.statusRedText;
    return AgrisellColors.statusOrangeText;
  }

  static IconData statusIcon(RiderApplicationStatusContent content) {
    if (content.isApproved) return Icons.check_circle_rounded;
    if (content.isNeedsInfo) return Icons.assignment_late_rounded;
    if (content.isRejected) return Icons.cancel_rounded;
    return Icons.hourglass_top_rounded;
  }

  static final approvedDecoration = _statusDecoration(
    AgrisellColors.statusGreenBackground,
    AgrisellColors.statusGreenText,
  );
  static final pendingDecoration = _statusDecoration(
    AgrisellColors.statusOrangeBackground,
    AgrisellColors.statusOrangeText,
  );
  static final rejectedDecoration = _statusDecoration(
    AgrisellColors.statusRedBackground,
    AgrisellColors.statusRedText,
  );

  static BoxDecoration statusDecoration(RiderApplicationStatusContent content) {
    if (content.isApproved) return approvedDecoration;
    if (content.isNeedsInfo) return pendingDecoration;
    if (content.isRejected) return rejectedDecoration;
    return pendingDecoration;
  }

  static BoxDecoration _statusDecoration(Color background, Color border) =>
      BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border.withValues(alpha: .24)),
      );

  // Delegated review section styles
  static BoxDecoration sectionDecoration(RiderReviewSectionVariant variant) =>
      RiderApplicationReviewStyles.sectionDecoration(variant);

  static Color sectionColor(RiderReviewSectionVariant variant) =>
      RiderApplicationReviewStyles.sectionColor(variant);

  static TextStyle sectionHeading(RiderReviewSectionVariant variant) =>
      RiderApplicationReviewStyles.sectionHeading(variant);

  static const rejectionBody = RiderApplicationReviewStyles.rejectionBody;
  static const noteBody = RiderApplicationReviewStyles.noteBody;
  static const missingItemPadding =
      RiderApplicationReviewStyles.missingItemPadding;
}
