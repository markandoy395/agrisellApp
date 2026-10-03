import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class DeliveryTrackingSheetStyles {
  // Dimensions & Factors
  static const double sheetMaxHeightFactor = 0.92;
  static const double sheetBorderRadius = 24.0;
  static const double handleWidth = 44.0;
  static const double handleHeight = 4.0;
  static const double closeIconSize = 22.0;
  static const double mapHeight = 320.0;
  static const double riderAvatarSize = 44.0;
  static const double riderAvatarIconSize = 24.0;
  static const double callRiderIconSize = 20.0;
  static const double checkpointDotSize = 22.0;
  static const double checkpointInnerDotSize = 8.0;
  static const double checkpointConnectorWidth = 2.0;
  static const double checkpointCheckIconSize = 14.0;

  // Gaps & Spacings
  static const double handleBottomGap = 12.0;
  static const double headerTextGap = 2.0;
  static const double loadingIndicatorGap = 16.0;
  static const double sectionGap = 16.0;
  static const double riderSectionGap = 18.0;
  static const double riderInfoGap = 12.0;
  static const double riderVehicleTopGap = 2.0;
  static const double checkpointsTitleGap = 12.0;
  static const double checkpointContentGap = 12.0;
  static const double checkpointBadgeGap = 8.0;
  static const double checkpointNotesGap = 2.0;
  static const double checkpointItemBottomPadding = 18.0;

  // Colors
  static const Color activeCheckpointColor = Color(0xFFD97706);
  static const Color inProgressBadgeBg = Color(0xFFFFF3CD);
  static const Color inProgressBadgeText = Color(0xFF856404);

  // Paddings
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(16, 12, 16, 8);
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(16, 12, 16, 28);
  static const EdgeInsets riderCardPadding = EdgeInsets.all(14);
  static const EdgeInsets inProgressBadgePadding = EdgeInsets.symmetric(
    horizontal: 6,
    vertical: 2,
  );

  // Decorations
  static const BoxDecoration sheetDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.vertical(top: Radius.circular(sheetBorderRadius)),
  );

  static BoxDecoration handleDecoration = BoxDecoration(
    color: AgrisellColors.borderLine,
    borderRadius: BorderRadius.circular(999),
  );

  static BoxDecoration riderCardDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
      color: AgrisellColors.authGreen.withValues(alpha: 0.2),
    ),
  );

  static BoxDecoration riderAvatarDecoration = BoxDecoration(
    color: AgrisellColors.authGreen,
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.authGreen.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 3),
      ),
    ],
  );

  static BoxDecoration inProgressBadgeDecoration = BoxDecoration(
    color: inProgressBadgeBg,
    borderRadius: BorderRadius.circular(4),
  );

  static BoxDecoration checkpointDotDecoration({
    required bool isDone,
    required bool isActive,
    required Color dotColor,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: isDone
          ? AgrisellColors.authGreen
          : (isActive ? activeCheckpointColor : Colors.white),
      border: Border.all(
        color: dotColor,
        width: 2,
      ),
      boxShadow: [
        if (isActive || isDone)
          BoxShadow(
            color: dotColor.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
      ],
    );
  }

  static const BoxDecoration checkpointInnerDotDecoration = BoxDecoration(
    shape: BoxShape.circle,
    color: Colors.white,
  );

  // Buttons & Dividers
  static const Divider headerDivider = Divider(
    height: 1,
    color: AgrisellColors.borderLine,
  );

  static ButtonStyle callRiderButtonStyle = IconButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: Colors.white,
  );

  // Typography
  static const TextStyle headerOrderId = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.mutedText,
  );

  static const TextStyle headerTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w900,
    color: AgrisellColors.brandBlack,
  );

  static const TextStyle loadingText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.mutedText,
  );

  static const TextStyle errorText = TextStyle(
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle riderName = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.brandBlack,
  );

  static const TextStyle riderVehicle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AgrisellColors.mutedText,
  );

  static const TextStyle checkpointsTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.brandBlack,
  );

  static const TextStyle inProgressBadgeTextLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: inProgressBadgeText,
  );

  static const TextStyle checkpointNotes = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AgrisellColors.mutedText,
  );

  static TextStyle checkpointLabel({required bool isEmphasized}) {
    return TextStyle(
      fontSize: 13,
      fontWeight: isEmphasized ? FontWeight.w800 : FontWeight.w600,
      color: isEmphasized ? AgrisellColors.brandBlack : AgrisellColors.mutedText,
    );
  }

  static Color checkpointDotColor({required bool isDone, required bool isActive}) {
    if (isDone) return AgrisellColors.authGreen;
    if (isActive) return activeCheckpointColor;
    return AgrisellColors.deliveryGray;
  }

  static Color connectorLineColor({required bool isDone}) {
    return isDone ? AgrisellColors.authGreen : AgrisellColors.borderLine;
  }
}
