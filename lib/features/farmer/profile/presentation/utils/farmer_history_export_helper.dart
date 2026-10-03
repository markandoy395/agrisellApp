import 'package:flutter/material.dart';

import 'package:agresell_app/features/farmer/reporting/farmer_financial_exporter.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/shared/reporting/widgets/export_report_sheet.dart';

abstract final class FarmerHistoryExportHelper {
  static void exportOrdersCsv(
    BuildContext context, {
    required List<PlacedOrder> orders,
  }) {
    final report = FarmerFinancialExporter.buildOrdersSalesReport(
      orders: orders,
    );
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    ExportReportSheet.show(
      context,
      title: 'Farmer Sales & Orders Report',
      fileName: 'farmer_orders_$dateStr.csv',
      headers: report.headers,
      rows: report.rows,
      totalAmountLabel: formatBasketPeso(report.totalAmount),
    );
  }
}
