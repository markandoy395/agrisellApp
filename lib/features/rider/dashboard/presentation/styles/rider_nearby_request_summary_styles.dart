import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

abstract final class RiderNearbyRequestSummaryStyles {
  // Padding & Insets
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets temporaryNoticePadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 8,
  );

  // Typography
  static const TextStyle headerTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle headerSubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle moreRequestsStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle itemTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle itemFeeStyle = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 12,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle itemAddressStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.2,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle emptyTitleStyle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w900,
  );

  static const TextStyle emptySubtitleStyle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle temporaryNoticeTextStyle = TextStyle(
    color: AgrisellColors.statusOrangeText,
    fontSize: 12,
    height: 1.25,
    fontWeight: FontWeight.w700,
  );

  // Dividers
  static const Color dividerColor = AgrisellColors.borderLine;
  static const double dividerHeight = 18.0;

  // Decorations
  static final BoxDecoration itemIconDecoration = BoxDecoration(
    color: AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(12),
  );

  static BoxDecoration queueIconDecoration(bool isMuted) => BoxDecoration(
    color: isMuted
        ? AgrisellColors.deliveryGray.withValues(alpha: 0.75)
        : AgrisellColors.forestSoft,
    borderRadius: BorderRadius.circular(14),
  );

  static Color queueIconColor(bool isMuted) =>
      isMuted ? AgrisellColors.mutedText : AgrisellColors.authGreen;

  static final BoxDecoration temporaryNoticeDecoration = BoxDecoration(
    color: AgrisellColors.statusOrangeBackground,
    borderRadius: BorderRadius.circular(10),
  );
}
