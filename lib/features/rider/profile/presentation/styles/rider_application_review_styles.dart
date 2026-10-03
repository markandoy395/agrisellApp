import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';

enum RiderReviewSectionVariant { rejection, note, missingItems }

abstract final class RiderApplicationReviewStyles {
  static final rejectionSectionDecoration = _sectionDecoration(
    AgrisellColors.statusRedBackground,
    AgrisellColors.statusRedText.withValues(alpha: .24),
  );

  static final noteSectionDecoration = _sectionDecoration(
    AgrisellColors.statusOrangeBackground,
    AgrisellColors.statusOrangeText.withValues(alpha: .24),
  );

  static final missingSectionDecoration = _sectionDecoration(
    AgrisellColors.homeBackground,
    AgrisellColors.borderLine,
  );

  static BoxDecoration _sectionDecoration(Color background, Color border) =>
      BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      );

  static BoxDecoration sectionDecoration(RiderReviewSectionVariant variant) =>
      switch (variant) {
        RiderReviewSectionVariant.rejection => rejectionSectionDecoration,
        RiderReviewSectionVariant.note => noteSectionDecoration,
        RiderReviewSectionVariant.missingItems => missingSectionDecoration,
      };

  static Color sectionColor(RiderReviewSectionVariant variant) =>
      variant == RiderReviewSectionVariant.rejection
          ? AgrisellColors.statusRedText
          : AgrisellColors.statusOrangeText;

  static const rejectionHeading = TextStyle(
    color: AgrisellColors.statusRedText,
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: .3,
  );

  static final noteHeading = rejectionHeading.copyWith(
    color: AgrisellColors.statusOrangeText,
  );

  static TextStyle sectionHeading(RiderReviewSectionVariant variant) =>
      variant == RiderReviewSectionVariant.rejection
          ? rejectionHeading
          : noteHeading;

  static const rejectionBody = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );

  static const noteBody = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    height: 1.4,
  );

  static const missingItemPadding = EdgeInsets.symmetric(vertical: 3);
}
