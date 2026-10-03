import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/reporting/styles/export_report_sheet_styles.dart';

abstract final class ExportReportSheetDecorations {
  static const Radius sheetTopRadius = Radius.circular(24);
  static final BorderRadius cardRadius = BorderRadius.circular(12);
  static final BorderRadius periodRadius = BorderRadius.circular(8);
  static final BorderRadius tableContainerRadius = BorderRadius.circular(12);
  static final BorderRadius savedFileRadius = BorderRadius.circular(8);
  static final BorderRadius buttonRadius = BorderRadius.circular(12);

  static const BoxDecoration sheetDecoration = BoxDecoration(
    color: AgrisellColors.surface,
    borderRadius: BorderRadius.vertical(top: sheetTopRadius),
  );

  static final BoxDecoration handleBarDecoration = BoxDecoration(
    color: ExportReportSheetStyles.handleBarColor,
    borderRadius: BorderRadius.circular(
      ExportReportSheetStyles.handleBarRadius,
    ),
  );

  static final BoxDecoration headerIconDecoration = BoxDecoration(
    color: AgrisellColors.authGreen.withValues(alpha: 0.12),
    borderRadius: BorderRadius.circular(
      ExportReportSheetStyles.headerIconRadius,
    ),
  );

  static final BoxDecoration recordsCardDecoration = BoxDecoration(
    color: ExportReportSheetStyles.recordsCardBackground,
    borderRadius: cardRadius,
    border: Border.all(color: ExportReportSheetStyles.recordsCardBorder),
  );

  static final BoxDecoration statementCardDecoration = BoxDecoration(
    color: ExportReportSheetStyles.statementCardBackground,
    borderRadius: cardRadius,
    border: Border.all(color: ExportReportSheetStyles.statementCardBorder),
  );

  static final BoxDecoration periodDecoration = BoxDecoration(
    color: ExportReportSheetStyles.periodBackground,
    borderRadius: periodRadius,
    border: Border.all(color: ExportReportSheetStyles.periodBorder),
  );

  static final BoxDecoration tableContainerDecoration = BoxDecoration(
    color: ExportReportSheetStyles.tableContainerBackground,
    borderRadius: tableContainerRadius,
    border: Border.all(color: ExportReportSheetStyles.tableContainerBorder),
  );

  static final BoxDecoration savedFileDecoration = BoxDecoration(
    color: ExportReportSheetStyles.savedFileBackground,
    borderRadius: savedFileRadius,
    border: Border.all(color: ExportReportSheetStyles.savedFileBorder),
  );

  static final ButtonStyle copyButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AgrisellColors.headingGreen,
    side: const BorderSide(color: ExportReportSheetStyles.copyButtonBorder),
    padding: ExportReportSheetStyles.buttonPadding,
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
  );

  static final ButtonStyle saveButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AgrisellColors.authGreen,
    foregroundColor: AgrisellColors.surface,
    padding: ExportReportSheetStyles.buttonPadding,
    shape: RoundedRectangleBorder(borderRadius: buttonRadius),
    elevation: 0,
  );
}
