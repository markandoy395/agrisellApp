import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

class FarmerReviewNoticeStyle {
  const FarmerReviewNoticeStyle({
    required this.decoration,
    required this.title,
    required this.iconColor,
    this.body = FarmerReviewNoticeStyles.noteBody,
    this.padding = FarmerReviewNoticeStyles.notePadding,
    this.iconSize = FarmerReviewNoticeStyles.noteIconSize,
    this.titleGap = FarmerReviewNoticeStyles.noteTitleGap,
  });

  final BoxDecoration decoration;
  final TextStyle title;
  final TextStyle body;
  final Color iconColor;
  final EdgeInsets padding;
  final double iconSize;
  final double titleGap;
}

abstract final class FarmerReviewNoticeStyles {
  static const notePadding = EdgeInsets.all(12);
  static const noteIconSize = 16.0;
  static const noteTitleGap = 6.0;
  static const hiddenColor = Color(0xFFB82828);
  static const moderationColor = Color(0xFF9E6B08);
  static const noteBody = TextStyle(
    color: Color(0xFF4A4031),
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );
  static const supportBody = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );
  static const _hiddenTitle = TextStyle(
    color: hiddenColor,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static const _moderationTitle = TextStyle(
    color: moderationColor,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static const _supportTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w800,
  );
  static const _overviewTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );
  static const _pendingTitle = TextStyle(
    color: Color(0xFF92400E),
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static final hidden = FarmerReviewNoticeStyle(
    decoration: _decoration(
      const Color(0xFFFDF3F2),
      const Color(0xFFF5C6CB),
      12,
    ),
    title: _hiddenTitle,
    iconColor: hiddenColor,
  );
  static final moderation = FarmerReviewNoticeStyle(
    decoration: _decoration(
      const Color(0xFFFDF8EE),
      const Color(0xFFFCE1B5),
      12,
    ),
    title: _moderationTitle,
    iconColor: moderationColor,
  );
  static final support = FarmerReviewNoticeStyle(
    decoration: _decoration(
      const Color(0xFFEAF5EE),
      const Color(0xFFB8E0CA),
      12,
    ),
    title: _supportTitle,
    body: supportBody,
    iconColor: AgrisellColors.authGreen,
  );
  static final pending = FarmerReviewNoticeStyle(
    decoration: _decoration(
      const Color(0xFFFEF3C7),
      const Color(0xFFFDE68A),
      10,
    ),
    title: _pendingTitle,
    iconColor: const Color(0xFFB45309),
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    titleGap: 8,
  );
  static final overview = FarmerReviewNoticeStyle(
    decoration: _decoration(
      const Color(0xFFF3FAF6),
      const Color(0xFFCDE4D7),
      10,
    ),
    title: _overviewTitle,
    iconColor: AgrisellColors.authGreen,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    iconSize: 18,
    titleGap: 8,
  );

  static BoxDecoration _decoration(
    Color background,
    Color border,
    double radius,
  ) => BoxDecoration(
    color: background,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border),
  );
}
