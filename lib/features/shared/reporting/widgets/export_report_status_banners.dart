import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/export_report_sheet_styles.dart';

class ExportReportStatusBanners extends StatelessWidget {
  const ExportReportStatusBanners({
    this.savedFilePath,
    this.errorMessage,
    super.key,
  });

  final String? savedFilePath;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (savedFilePath != null)
          Container(
            margin: ExportReportSheetStyles.savedFileMargin,
            padding: ExportReportSheetStyles.savedFilePadding,
            decoration: ExportReportSheetStyles.savedFileDecoration,
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  size: ExportReportSheetStyles.savedFileIconSize,
                  color: AgrisellColors.authGreen,
                ),
                const SizedBox(width: ExportReportSheetStyles.savedFileIconGap),
                Expanded(
                  child: Text(
                    'File saved to: $savedFilePath',
                    style: ExportReportSheetStyles.savedFileText,
                  ),
                ),
              ],
            ),
          ),
        if (errorMessage != null)
          Padding(
            padding: ExportReportSheetStyles.errorMargin,
            child: Text(
              errorMessage!,
              style: ExportReportSheetStyles.errorMessage,
            ),
          ),
      ],
    );
  }
}
