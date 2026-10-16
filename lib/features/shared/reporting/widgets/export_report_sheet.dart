import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'dart:io';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/reporting/services/csv_export_service.dart';
import '../styles/export_report_sheet_styles.dart';
import 'export_report_action_buttons.dart';
import 'export_report_data_preview_table.dart';
import 'export_report_sheet_header.dart';
import 'export_report_status_banners.dart';
import 'export_report_summary_cards.dart';

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

    ScaffoldMessenger.of(context).showAppSnackBar(
      SnackBar(
        content: Text(
          'CSV data copied to clipboard (${widget.rows.length} rows)',
        ),
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

      ScaffoldMessenger.of(context).showAppSnackBar(
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
    final maxHeight =
        MediaQuery.of(context).size.height *
        ExportReportSheetStyles.maxSheetHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: ExportReportSheetStyles.sheetDecoration,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExportReportSheetHeader(
              title: widget.title,
              fileName: widget.fileName,
              onClose: () => Navigator.of(context).pop(),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: ExportReportSheetStyles.bodyPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExportReportSummaryCards(
                      rowCount: widget.rows.length,
                      totalAmountLabel: widget.totalAmountLabel,
                      dateRangeLabel: widget.dateRangeLabel,
                    ),
                    const SizedBox(height: ExportReportSheetStyles.sectionGap),
                    ExportReportDataPreviewTable(
                      headers: widget.headers,
                      previewRows: previewRows,
                    ),
                    ExportReportStatusBanners(
                      savedFilePath: _savedFile?.path,
                      errorMessage: _errorMessage,
                    ),
                  ],
                ),
              ),
            ),
            ExportReportActionButtons(
              isCopied: _isCopied,
              isSaving: _isSaving,
              onCopy: _handleCopy,
              onSave: _handleSave,
            ),
          ],
        ),
      ),
    );
  }
}
