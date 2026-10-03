import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/reporting/styles/export_report_sheet_decorations.dart';

export 'package:agresell_app/features/shared/reporting/styles/export_report_sheet_decorations.dart';

abstract final class ExportReportSheetStyles {
  // Colors
  static const Color handleBarColor = Color(0xFFCBD5E1);
  static const Color dividerColor = Color(0xFFE2ECE6);
  static const Color recordsCardBackground = Color(0xFFF3FAF6);
  static const Color recordsCardBorder = Color(0xFFCDE4D7);
  static const Color statementCardBackground = Color(0xFFF6F9F7);
  static const Color statementCardBorder = Color(0xFFE2EBE6);
  static const Color periodBackground = Color(0xFFF8FAFC);
  static const Color periodBorder = Color(0xFFE2E8F0);
  static const Color periodText = Color(0xFF475569);
  static const Color tableContainerBackground = Color(0xFFFAFCFA);
  static const Color tableContainerBorder = Color(0xFFE2ECE6);
  static const Color tableCellText = Color(0xFF334155);
  static const Color savedFileBackground = Color(0xFFEAF5EE);
  static const Color savedFileBorder = Color(0xFFB8E0CA);
  static const Color errorText = Color(0xFFDC2626);
  static const Color copyButtonBorder = Color(0xFFCBD5E1);

  // Dimensions & Factors
  static const double maxSheetHeightFactor = 0.88;
  static const double handleBarWidth = 44.0;
  static const double handleBarHeight = 4.0;
  static const double handleBarRadius = 2.0;
  static const double headerIconSize = 22.0;
  static const double headerIconRadius = 12.0;
  static const double periodIconSize = 14.0;
  static const double savedFileIconSize = 16.0;
  static const double actionButtonIconSize = 18.0;
  static const double loadingIndicatorSize = 16.0;
  static const double loadingIndicatorStroke = 2.0;

  static const double tableHeadingRowHeight = 36.0;
  static const double tableDataRowMinHeight = 32.0;
  static const double tableDataRowMaxHeight = 40.0;
  static const double tableColumnSpacing = 16.0;

  // Gaps & Spacing
  static const double headerGap = 14.0;
  static const double subtitleGap = 2.0;
  static const double cardTitleGap = 4.0;
  static const double summaryRowGap = 12.0;
  static const double periodIconGap = 8.0;
  static const double sectionGap = 16.0;
  static const double titleGap = 8.0;
  static const double savedFileIconGap = 8.0;
  static const double buttonGap = 12.0;

  // Paddings & Margins
  static const EdgeInsets handleBarMargin = EdgeInsets.only(top: 12, bottom: 8);
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(20, 8, 16, 12);
  static const EdgeInsets headerIconPadding = EdgeInsets.all(10);
  static const EdgeInsets bodyPadding = EdgeInsets.fromLTRB(20, 16, 20, 16);
  static const EdgeInsets cardPadding = EdgeInsets.all(12);
  static const EdgeInsets periodMargin = EdgeInsets.only(top: 10);
  static const EdgeInsets periodPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 8,
  );
  static const EdgeInsets savedFileMargin = EdgeInsets.only(top: 12);
  static const EdgeInsets savedFilePadding = EdgeInsets.all(10);
  static const EdgeInsets errorMargin = EdgeInsets.only(top: 12);
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

  static const TextStyle cardLabel = TextStyle(
    color: AgrisellColors.mutedText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle recordsCardValue = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle statementCardValue = TextStyle(
    color: AgrisellColors.authGreen,
    fontSize: 15,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle periodValue = TextStyle(
    color: periodText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 13,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle tableHeading = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle tableHeader = tableHeading;

  static const TextStyle periodTextStyle = TextStyle(
    color: periodText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle tableCell = TextStyle(
    color: tableCellText,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle savedFileText = TextStyle(
    color: AgrisellColors.headingGreen,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle errorMessage = TextStyle(
    color: errorText,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  // Delegated Radii & Decorations
  static Radius get sheetTopRadius => ExportReportSheetDecorations.sheetTopRadius;
  static BorderRadius get cardRadius => ExportReportSheetDecorations.cardRadius;
  static BorderRadius get periodRadius =>
      ExportReportSheetDecorations.periodRadius;
  static BorderRadius get tableContainerRadius =>
      ExportReportSheetDecorations.tableContainerRadius;
  static BorderRadius get savedFileRadius =>
      ExportReportSheetDecorations.savedFileRadius;
  static BorderRadius get buttonRadius =>
      ExportReportSheetDecorations.buttonRadius;

  static BoxDecoration get sheetDecoration =>
      ExportReportSheetDecorations.sheetDecoration;
  static BoxDecoration get handleBarDecoration =>
      ExportReportSheetDecorations.handleBarDecoration;
  static BoxDecoration get headerIconDecoration =>
      ExportReportSheetDecorations.headerIconDecoration;
  static BoxDecoration get recordsCardDecoration =>
      ExportReportSheetDecorations.recordsCardDecoration;
  static BoxDecoration get statementCardDecoration =>
      ExportReportSheetDecorations.statementCardDecoration;
  static BoxDecoration get periodDecoration =>
      ExportReportSheetDecorations.periodDecoration;
  static BoxDecoration get tableContainerDecoration =>
      ExportReportSheetDecorations.tableContainerDecoration;
  static BoxDecoration get savedFileDecoration =>
      ExportReportSheetDecorations.savedFileDecoration;
  static ButtonStyle get copyButtonStyle =>
      ExportReportSheetDecorations.copyButtonStyle;
  static ButtonStyle get saveButtonStyle =>
      ExportReportSheetDecorations.saveButtonStyle;
}
