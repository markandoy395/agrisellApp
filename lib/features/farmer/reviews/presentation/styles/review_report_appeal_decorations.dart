import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/styles/review_report_appeal_styles.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

abstract final class ReviewReportAppealDecorations {
  static const Radius sheetTopRadius = Radius.circular(24);
  static final BorderRadius optionRadius = BorderRadius.circular(10);
  static final BorderRadius inputRadius = BorderRadius.circular(12);
  static final BorderRadius buttonRadius = BorderRadius.circular(12);

  static const BoxDecoration sheetDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.vertical(top: sheetTopRadius),
  );

  static final BoxDecoration handleBarDecoration = BoxDecoration(
    color: ReviewReportAppealStyles.handleBarColor,
    borderRadius: BorderRadius.circular(ReviewReportAppealStyles.handleBarRadius),
  );

  static final BoxDecoration contextCardDecoration = BoxDecoration(
    color: ReviewReportAppealStyles.contextBackground,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: ReviewReportAppealStyles.contextBorder),
  );

  static BoxDecoration headerIconDecoration(Color primaryColor) =>
      BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(
          ReviewReportAppealStyles.headerIconRadius,
        ),
      );

  static BoxDecoration optionDecoration({
    required bool isSelected,
    required Color primaryColor,
  }) {
    if (isSelected) {
      return BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: optionRadius,
        border: Border.all(color: primaryColor, width: 1.5),
      );
    }
    return BoxDecoration(
      color: AgrisellColors.surface,
      borderRadius: optionRadius,
      border: Border.all(
        color: ReviewReportAppealStyles.optionBorder,
        width: 1.0,
      ),
    );
  }

  static final BoxDecoration errorBannerDecoration = BoxDecoration(
    color: ReviewReportAppealStyles.errorBackground,
    borderRadius: BorderRadius.circular(8),
    border: Border.all(color: ReviewReportAppealStyles.errorBorder),
  );

  static const RatingStarsStyle ratingStars = RatingStarsStyle(
    size: 13,
    filledColor: AgrisellColors.accentOrange,
    emptyColor: Color(0xFFD6DFDB),
  );

  static InputDecoration inputDecoration({
    required Color primaryColor,
    required String hintText,
  }) => InputDecoration(
    hintText: hintText,
    hintStyle: ReviewReportAppealStyles.inputHint,
    filled: true,
    fillColor: ReviewReportAppealStyles.inputFill,
    border: OutlineInputBorder(
      borderRadius: inputRadius,
      borderSide: const BorderSide(color: ReviewReportAppealStyles.inputBorder),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: inputRadius,
      borderSide: const BorderSide(color: ReviewReportAppealStyles.inputBorder),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: inputRadius,
      borderSide: BorderSide(color: primaryColor, width: 1.5),
    ),
    contentPadding: ReviewReportAppealStyles.inputContentPadding,
  );

  static final ButtonStyle cancelButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.mutedText,
    side: const BorderSide(color: ReviewReportAppealStyles.cancelBorder),
    padding: ReviewReportAppealStyles.buttonPadding,
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
  );

  static ButtonStyle submitButtonStyle(Color primaryColor) =>
      ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: AgrisellColors.surface,
        padding: ReviewReportAppealStyles.buttonPadding,
        shape: RoundedRectangleBorder(borderRadius: buttonRadius),
        elevation: 0,
      );
}
