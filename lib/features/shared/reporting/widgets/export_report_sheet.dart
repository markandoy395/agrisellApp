import 'dart:io';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/reporting/services/csv_export_service.dart';

class ExportReportSheet extends StatefulWidget {
  const ExportReportSheet({
    required this.title,
    required this.fileName,
    required this.headers,
    required this.rows,
    this.totalAmountLabel,
    this.dateRangeLabel,
    super.key,
  });

  final String title;
  final String fileName;
  final List<String> headers;
  final List<List<dynamic>> rows;
  final String? totalAmountLabel;
  final String? dateRangeLabel;

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String fileName,
    required List<String> headers,
    required List<List<dynamic>> rows,
    String? totalAmountLabel,
    String? dateRangeLabel,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExportReportSheet(
        title: title,
        fileName: fileName,
        headers: headers,
        rows: rows,
        totalAmountLabel: totalAmountLabel,
        dateRangeLabel: dateRangeLabel,
      ),
    );
  }

  @override
  State<ExportReportSheet> createState() => _ExportReportSheetState();
}

class _ExportReportSheetState extends State<ExportReportSheet> {
  bool _isCopied = false;
  bool _isSaving = false;
  File? _savedFile;
  String? _errorMessage;

  late final String _csvData;

  @override
  void initState() {
    super.initState();
    _csvData = CsvExportService.generateCsv(
      headers: widget.headers,
      rows: widget.rows,
    );
  }

  Future<void> _handleCopy() async {
    await CsvExportService.copyToClipboard(_csvData);
    if (!mounted) return;
    setState(() => _isCopied = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV data copied to clipboard (${widget.rows.length} rows)'),
        backgroundColor: AgrisellColors.headingGreen,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );

    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isCopied = false);
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final file = await CsvExportService.saveCsvToFile(
        fileName: widget.fileName,
        csvContent: _csvData,
      );
      if (!mounted) return;
      setState(() {
        _savedFile = file;
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saved to ${file.path.split("/").last}'),
          backgroundColor: AgrisellColors.authGreen,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _errorMessage = 'Could not save file: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final previewRows = widget.rows.take(3).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: const BoxDecoration(
        color: AgrisellColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle Bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 16, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AgrisellColors.authGreen.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.table_chart_rounded,
                      color: AgrisellColors.authGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            color: AgrisellColors.headingGreen,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.fileName,
                          style: const TextStyle(
                            color: AgrisellColors.mutedText,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AgrisellColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE2ECE6)),

            // Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Summary metric cards
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3FAF6),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFCDE4D7)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Records',
                                  style: TextStyle(
                                    color: AgrisellColors.mutedText,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.rows.length} rows',
                                  style: const TextStyle(
                                    color: AgrisellColors.headingGreen,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (widget.totalAmountLabel != null) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF6F9F7),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2EBE6)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Statement Value',
                                    style: TextStyle(
                                      color: AgrisellColors.mutedText,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    widget.totalAmountLabel!,
                                    style: const TextStyle(
                                      color: AgrisellColors.authGreen,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    if (widget.dateRangeLabel != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today_rounded,
                              size: 14,
                              color: AgrisellColors.mutedText,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Period: ${widget.dateRangeLabel}',
                              style: const TextStyle(
                                color: Color(0xFF475569),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Table Preview
                    const Text(
                      'Data Preview (First 3 Rows)',
                      style: TextStyle(
                        color: AgrisellColors.headingGreen,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAFCFA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2ECE6)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowHeight: 36,
                          dataRowMinHeight: 32,
                          dataRowMaxHeight: 40,
                          columnSpacing: 16,
                          headingTextStyle: const TextStyle(
                            color: AgrisellColors.headingGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                          dataTextStyle: const TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                          columns: widget.headers
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

                    if (_savedFile != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF5EE),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFB8E0CA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: AgrisellColors.authGreen,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'File saved to: ${_savedFile!.path}',
                                style: const TextStyle(
                                  color: AgrisellColors.headingGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Action Buttons Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _handleCopy,
                      icon: Icon(
                        _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                        size: 18,
                      ),
                      label: Text(_isCopied ? 'Copied' : 'Copy CSV'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AgrisellColors.headingGreen,
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _handleSave,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AgrisellColors.surface,
                              ),
                            )
                          : const Icon(Icons.download_rounded, size: 18),
                      label: Text(_isSaving ? 'Saving...' : 'Save CSV to Device'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AgrisellColors.authGreen,
                        foregroundColor: AgrisellColors.surface,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
