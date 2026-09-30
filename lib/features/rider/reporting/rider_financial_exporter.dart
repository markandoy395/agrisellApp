import 'package:agresell_app/features/shared/reporting/domain/csv_report_data.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/widgets/rider_analytics_formatters.dart';

class RiderFinancialExporter {
  const RiderFinancialExporter();

  /// Builds a detailed earnings report for a rider across a specific date range.
  static CsvReportData buildEarningsReport({
    required List<RiderEarningEntry> earnings,
    required RiderDateRange dateRange,
    RiderEarningsSummary? summary,
  }) {
    final headers = [
      'Transaction ID',
      'Date & Time',
      'Delivery Reference',
      'Description',
      'Earning Type',
      'Gross Earning (PHP)',
      'Bonus (PHP)',
      'Incentive (PHP)',
      'Deduction (PHP)',
      'Net Amount (PHP)',
      'Payout Status',
    ];

    final rows = <List<dynamic>>[];
    double totalNet = 0.0;

    for (final entry in earnings) {
      final gross = entry.amount;
      final bonus = entry.bonus;
      final incentive = entry.incentive;
      final deduction = entry.deduction + entry.penalty;
      final net = gross + bonus + incentive - deduction;
      totalNet += net;

      rows.add([
        entry.id,
        _formatDateTime(entry.occurredAt),
        entry.deliveryId ?? entry.orderNumber ?? 'N/A',
        entry.description,
        entry.type.label,
        gross.toStringAsFixed(2),
        bonus.toStringAsFixed(2),
        incentive.toStringAsFixed(2),
        deduction.toStringAsFixed(2),
        net.toStringAsFixed(2),
        entry.payoutStatus.label,
      ]);
    }

    return CsvReportData(
      headers: headers,
      rows: rows,
      totalAmount: summary?.netEarnings ?? totalNet,
      dateRangeLabel: formatRiderDateRange(dateRange),
    );
  }

  /// Builds a delivery manifest and trip history report for completed/closed rider trips.
  static CsvReportData buildDeliveryHistoryReport({
    required List<RiderDeliveryHistoryEntry> deliveries,
  }) {
    final headers = [
      'Delivery ID',
      'Order Number',
      'Completed Date',
      'Commodity / Product',
      'Quantity',
      'Pickup Address',
      'Dropoff Address',
      'Delivery Fee (PHP)',
      'Delivery Status',
      'Payment Status',
      'Customer Rating',
    ];

    final rows = <List<dynamic>>[];
    double totalFees = 0.0;

    for (final item in deliveries) {
      totalFees += item.deliveryFee;
      rows.add([
        item.id,
        item.orderNumber,
        _formatDateTime(item.completedAt),
        item.productName,
        item.quantityDescription,
        item.pickupAddress,
        item.deliveryAddress,
        item.deliveryFee.toStringAsFixed(2),
        item.status.label,
        item.paymentStatus.name.toUpperCase(),
        item.customerRating != null ? '${item.customerRating} ★' : 'No rating',
      ]);
    }

    return CsvReportData(
      headers: headers,
      rows: rows,
      totalAmount: totalFees,
    );
  }

  static String _formatDateTime(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }
}
