import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class BuyerRefundTrackerStyles {
  // App Bar
  static const appBarTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const tabLabelStyle = TextStyle(
    fontWeight: FontWeight.w700,
    fontSize: 13,
  );

  // List View & Empty State
  static const listPadding = EdgeInsets.fromLTRB(16, 16, 16, 32);
  static const emptyPadding = EdgeInsets.all(24);
  static const emptyIconSize = 32.0;
  static const emptyIconCircleSize = 64.0;
  static const cardSeparator = SizedBox(height: 14);

  static const emptyTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const emptySubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.4,
  );

  // Card Styles
  static const cardPadding = EdgeInsets.all(14);

  static final cardDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(14),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
        blurRadius: 14,
        offset: const Offset(0, 4),
      ),
    ],
  );

  static const orderIdStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const badgePadding = EdgeInsets.symmetric(horizontal: 8, vertical: 3);

  static BoxDecoration badgeDecoration({
    required bool isCompleted,
    required bool isApproved,
  }) => BoxDecoration(
    color: isCompleted
        ? AgrisellColors.statusGreenBackground
        : (isApproved
            ? AgrisellColors.statusOrangeBackground
            : AgrisellColors.statusPurpleBackground),
    borderRadius: BorderRadius.circular(6),
  );

  static TextStyle badgeTextStyle({
    required bool isCompleted,
    required bool isApproved,
  }) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: isCompleted
        ? AgrisellColors.statusGreenText
        : (isApproved
            ? AgrisellColors.statusOrangeText
            : AgrisellColors.statusPurpleText),
  );

  static const orderTitleStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.brandBlack,
  );

  static const orderSubtitleStyle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w600,
  );

  static const amountContainerPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );

  static final amountContainerDecoration = BoxDecoration(
    color: AgrisellColors.searchBackground,
    borderRadius: BorderRadius.circular(8),
  );

  static const amountLabelStyle = TextStyle(
    fontSize: 12,
    color: AgrisellColors.mutedText,
    fontWeight: FontWeight.w700,
  );

  static const amountValueStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w900,
    color: AgrisellColors.authGreen,
  );

  static const refTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AgrisellColors.brandBlack,
  );

  static final trackButtonStyle = OutlinedButton.styleFrom(
    side: const BorderSide(color: AgrisellColors.authGreen),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  static const trackButtonTextStyle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: AgrisellColors.authGreen,
  );
}
