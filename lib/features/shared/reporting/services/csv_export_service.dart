import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CsvExportService {
  const CsvExportService();

  /// Formats headers and row data into an RFC 4180 compliant CSV string.
  /// Prepends UTF-8 BOM (\uFEFF) for seamless Microsoft Excel & spreadsheet compatibility.
  static String generateCsv({
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    final buffer = StringBuffer('\uFEFF');

    // Header line
    buffer.write(headers.map(_formatCell).join(','));
    buffer.write('\r\n');

    // Data rows
    for (final row in rows) {
      buffer.write(row.map(_formatCell).join(','));
      buffer.write('\r\n');
    }

    return buffer.toString();
  }

  /// Escapes a cell value according to RFC 4180 rules.
  static String _formatCell(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    final needsQuotes = str.contains(',') ||
        str.contains('"') ||
        str.contains('\n') ||
        str.contains('\r');

    if (needsQuotes) {
      return '"${str.replaceAll('"', '""')}"';
    }
    return str;
  }

  /// Writes the CSV text to local application documents or cache storage.
  static Future<File> saveCsvToFile({
    required String fileName,
    required String csvContent,
  }) async {
    Directory directory;
    try {
      directory = await getApplicationDocumentsDirectory();
    } catch (_) {
      directory = await getTemporaryDirectory();
    }

    final sanitizedName = fileName.endsWith('.csv') ? fileName : '$fileName.csv';
    final filePath = '${directory.path}/$sanitizedName';
    final file = File(filePath);
    return file.writeAsString(csvContent, flush: true);
  }

  /// Copies the raw CSV data to system clipboard.
  static Future<void> copyToClipboard(String csvContent) async {
    await Clipboard.setData(ClipboardData(text: csvContent));
  }
}
