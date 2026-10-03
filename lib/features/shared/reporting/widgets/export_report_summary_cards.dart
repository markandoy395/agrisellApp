import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../styles/export_report_sheet_styles.dart';

class ExportReportSummaryCards extends StatelessWidget {
  const ExportReportSummaryCards({
    required this.rowCount,
    this.totalAmountLabel,
    this.dateRangeLabel,
    super.key,
  });

  final int rowCount;
  final String? totalAmountLabel;
  final String? dateRangeLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: ExportReportSheetStyles.cardPadding,
                decoration: ExportReportSheetStyles.recordsCardDecoration,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Records',
                      style: ExportReportSheetStyles.cardLabel,
                    ),
                    const SizedBox(height: ExportReportSheetStyles.cardTitleGap),
                    Text(
                      '$rowCount rows',
                      style: ExportReportSheetStyles.recordsCardValue,
                    ),
                  ],
                ),
              ),
            ),
            if (totalAmountLabel != null) ...[
              const SizedBox(width: ExportReportSheetStyles.summaryRowGap),
              Expanded(
                child: Container(
                  padding: ExportReportSheetStyles.cardPadding,
                  decoration: ExportReportSheetStyles.statementCardDecoration,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statement Value',
                        style: ExportReportSheetStyles.cardLabel,
                      ),
                      const SizedBox(
                        height: ExportReportSheetStyles.cardTitleGap,
                      ),
                      Text(
                        totalAmountLabel!,
                        style: ExportReportSheetStyles.statementCardValue,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        if (dateRangeLabel != null) ...[
          Container(
            margin: ExportReportSheetStyles.periodMargin,
            padding: ExportReportSheetStyles.periodPadding,
            decoration: ExportReportSheetStyles.periodDecoration,
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: ExportReportSheetStyles.periodIconSize,
                  color: AgrisellColors.mutedText,
                ),
                const SizedBox(width: ExportReportSheetStyles.periodIconGap),
                Text(
                  'Period: $dateRangeLabel',
                  style: ExportReportSheetStyles.periodTextStyle,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
