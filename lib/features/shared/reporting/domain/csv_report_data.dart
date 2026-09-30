class CsvReportData {
  const CsvReportData({
    required this.headers,
    required this.rows,
    required this.totalAmount,
    this.dateRangeLabel,
  });

  final List<String> headers;
  final List<List<dynamic>> rows;
  final double totalAmount;
  final String? dateRangeLabel;
}
