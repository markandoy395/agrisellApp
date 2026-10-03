import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

abstract final class FarmerReviewsStyles {
  static const alignStart = CrossAxisAlignment.start;
  static const shrinkWrap = MainAxisSize.min;
  static const alignEnd = MainAxisAlignment.end;
  static const center = Alignment.center;
  static const centeredText = TextAlign.center;
  static const trailingText = TextAlign.end;
  static const horizontal = Axis.horizontal;
  static const tinyGap = 2.0;
  static const smallGap = 4.0;
  static const labelGap = 6.0;
  static const inlineGap = 8.0;
  static const contentGap = 10.0;
  static const sectionGap = 12.0;
  static const noticeGap = 14.0;
  static const overviewColumnGap = 24.0;
  static const distributionLabelWidth = 28.0;
  static const distributionHeight = 6.0;
  static const smallIconSize = 12.0;
  static const productIconSize = 14.0;
  static const avatarRadius = 18.0;
  static const emptyIconSize = 48.0;
  static const emptyIconColor = Color(0xFF94A3B8);
  static const avatarBackground = Color(0xFFE2EFE7);
  static const starColor = AgrisellColors.accentOrange;
  static const progressBackground = Color(0xFFE5ECE8);
  static const progressColor = AlwaysStoppedAnimation<Color>(
    AgrisellColors.authGreen,
  );
  static final progressRadius = BorderRadius.circular(4);
  static const overviewPadding = EdgeInsets.all(18);
  static const reviewPadding = EdgeInsets.all(16);
  static const reviewMargin = EdgeInsets.only(bottom: 12);
  static const productPadding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
  static const emptyPadding = EdgeInsets.symmetric(
    horizontal: 24,
    vertical: 36,
  );
  static const filterPadding = EdgeInsets.symmetric(horizontal: 4);
  static const filterSpacing = EdgeInsets.only(right: 8);

  static final overviewDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.06),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );
  static final reviewDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AgrisellColors.brandBlack.withValues(alpha: 0.05),
        blurRadius: 12,
        offset: const Offset(0, 3),
      ),
    ],
  );
  static final productDecoration = BoxDecoration(
    color: const Color(0xFFF2F6F4),
    borderRadius: BorderRadius.circular(8),
  );
  static final emptyDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.circular(18),
  );
  static const overviewStars = RatingStarsStyle(
    size: 18,
    filledColor: AgrisellColors.accentOrange,
    emptyColor: Color(0xFFD6DFDB),
  );
  static const reviewStars = RatingStarsStyle(
    size: 16,
    filledColor: AgrisellColors.accentOrange,
    emptyColor: Color(0xFFD6DFDB),
  );
  static const score = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w900,
    height: 1.1,
  );
  static const reviewCount = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
  static const label = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static const mutedLabel = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );
  static const avatar = TextStyle(
    color: AgrisellColors.authGreen,
    fontWeight: FontWeight.w800,
    fontSize: 14,
  );
  static const buyerName = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 14,
    fontWeight: FontWeight.w800,
  );
  static const date = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );
  static const comment = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w500,
  );
  static const emptyTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );
  static const emptyMessage = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 13,
    height: 1.4,
  );
}
