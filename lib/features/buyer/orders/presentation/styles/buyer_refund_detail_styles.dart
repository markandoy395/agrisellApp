import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

/// Styling constants, dimensions, and typography for buyer refund details.
abstract final class BuyerRefundDetailStyles {
  // Dimensions & Insets
  static const double sheetCornerRadius = 20.0;
  static const RoundedRectangleBorder sheetShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(sheetCornerRadius)),
  );
  static const EdgeInsets sheetPadding = EdgeInsets.fromLTRB(20, 16, 20, 24);
  static const EdgeInsets bannerPadding = EdgeInsets.all(14);
  static const EdgeInsets statusBadgePadding =
      EdgeInsets.symmetric(horizontal: 8, vertical: 3);
  static const EdgeInsets summaryRowPadding = EdgeInsets.only(bottom: 7);
  static const EdgeInsets timelineStepBottomPadding =
      EdgeInsets.only(bottom: 12);

  // Drag Handle
  static final BoxDecoration handleDecoration = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(2),
  );

  // Status Banner Decorations
  static BoxDecoration bannerDecoration({
    required bool isCompleted,
    required bool isApproved,
  }) {
    final bgColor = isCompleted
        ? AgrisellColors.statusGreenBackground
        : (isApproved
            ? AgrisellColors.statusOrangeBackground
            : AgrisellColors.statusPurpleBackground);
    final borderColor = isCompleted
        ? AgrisellColors.statusGreenText.withValues(alpha: 0.3)
        : (isApproved
            ? AgrisellColors.statusOrangeText.withValues(alpha: 0.3)
            : AgrisellColors.statusPurpleText.withValues(alpha: 0.3));

    return BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: borderColor),
    );
  }

  static final BoxDecoration statusBadgeDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(6),
  );

  // Timeline Step Decorations
  static BoxDecoration timelineCircleDecoration({
    required bool isCompleted,
    required bool isCurrent,
  }) {
    final color = isCompleted
        ? AgrisellColors.authGreen
        : (isCurrent
            ? AgrisellColors.statusOrangeText
            : AgrisellColors.searchBackground);
    final borderColor = isCompleted || isCurrent
        ? Colors.transparent
        : AgrisellColors.borderLine;

    return BoxDecoration(
      shape: BoxShape.circle,
      color: color,
      border: Border.all(color: borderColor, width: 2),
    );
  }

  static Color timelineLineColor({required bool isCompleted}) =>
      isCompleted ? AgrisellColors.authGreen : AgrisellColors.borderLine;

  static Color timelineIconColor({
    required bool isCompleted,
    required bool isCurrent,
  }) =>
      isCompleted || isCurrent ? Colors.white : AgrisellColors.mutedText;

  // Typography
  static const TextStyle headerTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle orderIdSubtitle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static TextStyle bannerTitle({
    required bool isCompleted,
    required bool isApproved,
  }) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: _statusTextColor(isCompleted: isCompleted, isApproved: isApproved),
      );

  static TextStyle bannerStatusBadgeText({
    required bool isCompleted,
    required bool isApproved,
  }) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: _statusTextColor(isCompleted: isCompleted, isApproved: isApproved),
      );

  static TextStyle bannerAmount({
    required bool isCompleted,
    required bool isApproved,
  }) =>
      TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: _statusTextColor(isCompleted: isCompleted, isApproved: isApproved),
      );

  static const TextStyle referenceText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );

  static const TextStyle sectionHeading = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );

  static TextStyle timelineStepTitle({
    required bool isCompleted,
    required bool isCurrent,
  }) =>
      TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: isCompleted || isCurrent
            ? AgrisellColors.brandBlack
            : AgrisellColors.mutedText,
      );

  static const TextStyle timelineTimestamp = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle timelineSubtitle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    height: 1.3,
  );

  static const TextStyle summaryLabel = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle summaryValue = TextStyle(
    fontSize: 12,
    color: AgrisellColors.brandBlack,
    fontWeight: FontWeight.w700,
  );

  static Color _statusTextColor({
    required bool isCompleted,
    required bool isApproved,
  }) {
    if (isCompleted) return AgrisellColors.statusGreenText;
    if (isApproved) return AgrisellColors.statusOrangeText;
    return AgrisellColors.statusPurpleText;
  }
}
