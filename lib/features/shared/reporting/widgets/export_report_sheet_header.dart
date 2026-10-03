import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/export_report_sheet_styles.dart';

class ExportReportSheetHeader extends StatelessWidget {
  const ExportReportSheetHeader({
    required this.title,
    required this.fileName,
    required this.onClose,
    super.key,
  });

  final String title;
  final String fileName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            margin: ExportReportSheetStyles.handleBarMargin,
            width: ExportReportSheetStyles.handleBarWidth,
            height: ExportReportSheetStyles.handleBarHeight,
            decoration: ExportReportSheetStyles.handleBarDecoration,
          ),
        ),
        Padding(
          padding: ExportReportSheetStyles.headerPadding,
          child: Row(
            children: [
              Container(
                padding: ExportReportSheetStyles.headerIconPadding,
                decoration: ExportReportSheetStyles.headerIconDecoration,
                child: const Icon(
                  Icons.table_chart_rounded,
                  color: AgrisellColors.authGreen,
                  size: ExportReportSheetStyles.headerIconSize,
                ),
              ),
              const SizedBox(width: ExportReportSheetStyles.headerGap),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: ExportReportSheetStyles.headerTitle),
                    const SizedBox(height: ExportReportSheetStyles.subtitleGap),
                    Text(
                      fileName,
                      style: ExportReportSheetStyles.headerSubtitle,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AgrisellColors.mutedText,
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: ExportReportSheetStyles.dividerColor),
      ],
    );
  }
}
