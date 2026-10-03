import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/farmer/reviews/presentation/styles/review_report_appeal_decorations.dart';
import 'package:agresell_app/features/shared/widgets/ratings/rating_stars.dart';

export 'package:agresell_app/features/farmer/reviews/presentation/styles/review_report_appeal_decorations.dart';

abstract final class ReviewReportAppealStyles {
  // Colors
  static const Color appealPrimary = AgrisellColors.authGreen;
  static const Color reportPrimary = Color(0xFFD97706);
  static const Color handleBarColor = Color(0xFFCBD5E1);
  static const Color dividerColor = Color(0xFFE2ECE6);
  static const Color contextBackground = Color(0xFFF6F9F7);
  static const Color contextBorder = Color(0xFFE2EBE6);
  static const Color commentColor = Color(0xFF475569);
  static const Color optionBorder = Color(0xFFE2E8F0);
  static const Color optionUnselectedText = Color(0xFF334155);
  static const Color optionUnselectedIcon = Color(0xFF94A3B8);
  static const Color inputFill = Color(0xFFF8FAFC);
  static const Color inputBorder = Color(0xFFE2E8F0);
  static const Color errorBackground = Color(0xFFFDF2F2);
  static const Color errorBorder = Color(0xFFFCA5A5);
  static const Color errorIconColor = Color(0xFFDC2626);
  static const Color errorTextColor = Color(0xFFB91C1C);
  static const Color cancelBorder = Color(0xFFCBD5E1);

  // Dimensions & Gaps
  static const double handleBarWidth = 44.0;
  static const double handleBarHeight = 4.0;
  static const double handleBarRadius = 2.0;
  static const double maxSheetHeightFactor = 0.9;
  static const double headerIconSize = 22.0;
  static const double headerIconRadius = 12.0;
  static const double optionIconSize = 18.0;
  static const double errorIconSize = 16.0;
  static const double loadingIndicatorSize = 18.0;
  static const double loadingIndicatorStroke = 2.0;

  static const double headerGap = 14.0;
  static const double subtitleGap = 2.0;
  static const double metaGap = 4.0;
  static const double commentGap = 6.0;
  static const double titleGap = 8.0;
  static const double optionIconGap = 10.0;
  static const double sectionGap = 16.0;
  static const double itemGap = 12.0;
  static const double buttonGap = 12.0;
  static const double errorContentGap = 8.0;

  // Paddings & Margins
  static const EdgeInsets handleBarMargin = EdgeInsets.only(top: 12, bottom: 8);
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(20, 8, 16, 12);
  static const EdgeInsets headerIconPadding = EdgeInsets.all(10);
  static const EdgeInsets bodyPadding = EdgeInsets.fromLTRB(20, 16, 20, 16);
  static const EdgeInsets contextPadding = EdgeInsets.all(12);
  static const EdgeInsets optionItemMargin = EdgeInsets.only(bottom: 6);
  static const EdgeInsets optionContentPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const EdgeInsets inputContentPadding = EdgeInsets.all(12);
  static const EdgeInsets errorMargin = EdgeInsets.only(top: 8);
  static const EdgeInsets errorPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const EdgeInsets footerPadding = EdgeInsets.fromLTRB(20, 8, 20, 16);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(vertical: 13);

  // Text Styles
  static const TextStyle headerTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle headerSubtitle = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle contextCommodity = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle contextMeta = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle contextComment = TextStyle(
    color: commentColor,
    fontSize: 12,
    fontStyle: FontStyle.italic,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle optionSelectedText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle optionUnselectedTextStyle = TextStyle(
    color: optionUnselectedText,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static TextStyle optionTextStyle({required bool isSelected}) =>
      isSelected ? optionSelectedText : optionUnselectedTextStyle;

  static const TextStyle inputText = TextStyle(
    fontSize: 13,
    color: AgrisellColors.headingGreen,
  );

  static const TextStyle inputHint = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
  );

  static const TextStyle errorText = TextStyle(
    color: errorTextColor,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle cancelButtonText = TextStyle(
    fontWeight: FontWeight.w700,
  );

  static const TextStyle submitButtonText = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 14,
  );

  // Delegated Decorations & Controls
  static Radius get sheetTopRadius => ReviewReportAppealDecorations.sheetTopRadius;
  static BorderRadius get optionRadius => ReviewReportAppealDecorations.optionRadius;
  static BorderRadius get inputRadius => ReviewReportAppealDecorations.inputRadius;
  static BorderRadius get buttonRadius => ReviewReportAppealDecorations.buttonRadius;

  static BoxDecoration get sheetDecoration =>
      ReviewReportAppealDecorations.sheetDecoration;
  static BoxDecoration get handleBarDecoration =>
      ReviewReportAppealDecorations.handleBarDecoration;
  static BoxDecoration get contextCardDecoration =>
      ReviewReportAppealDecorations.contextCardDecoration;
  static BoxDecoration headerIconDecoration(Color primaryColor) =>
      ReviewReportAppealDecorations.headerIconDecoration(primaryColor);
  static BoxDecoration optionDecoration({
    required bool isSelected,
    required Color primaryColor,
  }) => ReviewReportAppealDecorations.optionDecoration(
    isSelected: isSelected,
    primaryColor: primaryColor,
  );
  static BoxDecoration get errorBannerDecoration =>
      ReviewReportAppealDecorations.errorBannerDecoration;
  static RatingStarsStyle get ratingStars =>
      ReviewReportAppealDecorations.ratingStars;
  static InputDecoration inputDecoration({
    required Color primaryColor,
    required String hintText,
  }) => ReviewReportAppealDecorations.inputDecoration(
    primaryColor: primaryColor,
    hintText: hintText,
  );
  static ButtonStyle get cancelButtonStyle =>
      ReviewReportAppealDecorations.cancelButtonStyle;
  static ButtonStyle submitButtonStyle(Color primaryColor) =>
      ReviewReportAppealDecorations.submitButtonStyle(primaryColor);
}
