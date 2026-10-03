import 'package:flutter/material.dart';

import '../styles/export_report_sheet_styles.dart';

class ExportReportDataPreviewTable extends StatelessWidget {
  const ExportReportDataPreviewTable({
    required this.headers,
    required this.previewRows,
    super.key,
  });

  final List<String> headers;
  final List<List<dynamic>> previewRows;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Data Preview (First 3 Rows)',
          style: ExportReportSheetStyles.sectionTitle,
        ),
        const SizedBox(height: ExportReportSheetStyles.titleGap),
        Container(
          decoration: ExportReportSheetStyles.tableContainerDecoration,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowHeight: ExportReportSheetStyles.tableHeadingRowHeight,
              dataRowMinHeight: ExportReportSheetStyles.tableDataRowMinHeight,
              dataRowMaxHeight: ExportReportSheetStyles.tableDataRowMaxHeight,
              columnSpacing: ExportReportSheetStyles.tableColumnSpacing,
              headingTextStyle: ExportReportSheetStyles.tableHeader,
              dataTextStyle: ExportReportSheetStyles.tableCell,
              columns: headers
                  .map((h) => DataColumn(label: Text(h)))
                  .toList(),
              rows: previewRows.map((row) {
                return DataRow(
                  cells: row
                      .map((cell) => DataCell(Text(cell.toString())))
                      .toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
