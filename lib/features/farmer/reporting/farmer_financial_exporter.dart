import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/reporting/domain/csv_report_data.dart';

export 'package:agresell_app/features/shared/reporting/domain/csv_report_data.dart';

class FarmerFinancialExporter {
  const FarmerFinancialExporter();

  /// Builds a combined financial statement for farmer payouts and cash-out requests.
  static CsvReportData buildPayoutsReport({
    required List<FarmerPayout> payouts,
    required List<FarmerCashOutRequest> cashOutRequests,
  }) {
    final headers = [
      'Transaction Type',
      'Reference ID',
      'Order / Request ID',
      'Date',
      'Payment Method',
      'Account / Destination',
      'Gross Amount (PHP)',
      'Status',
      'Completed Date',
      'Notes / Details',
    ];

    final rows = <List<dynamic>>[];
    double totalAmount = 0.0;

    // Process order payouts
    for (final payout in payouts) {
      totalAmount += payout.amount;
      rows.add([
        'Order Payout',
        payout.reference.isNotEmpty ? payout.reference : 'N/A',
        payout.clientOrderId.isNotEmpty
            ? payout.clientOrderId
            : 'Order #${payout.orderId}',
        payout.createdAt != null
            ? _formatDateTime(payout.createdAt!)
            : 'N/A',
        'Direct Balance',
        payout.buyerName,
        payout.amount.toStringAsFixed(2),
        payout.status.label,
        payout.paidAt != null ? _formatDateTime(payout.paidAt!) : 'N/A',
        payout.failureReason.isNotEmpty
            ? payout.failureReason
            : (payout.isPaid ? 'Settled' : 'Pending settlement'),
      ]);
    }

    // Process cash-out withdrawals
    for (final request in cashOutRequests) {
      totalAmount += request.amount;
      rows.add([
        'Cash-Out Request',
        'REQ-${request.requestId}',
        request.requestId,
        request.createdAt != null
            ? _formatDateTime(request.createdAt!)
            : 'N/A',
        request.methodLabel,
        '${request.accountName} (${request.accountNumber})',
        request.amount.toStringAsFixed(2),
        request.statusLabel,
        request.isPaid && request.createdAt != null
            ? _formatDateTime(request.createdAt!)
            : 'N/A',
        request.rejectionReason.isNotEmpty
            ? request.rejectionReason
            : (request.notes.isNotEmpty ? request.notes : 'N/A'),
      ]);
    }

    return CsvReportData(
      headers: headers,
      rows: rows,
      totalAmount: totalAmount,
    );
  }

  /// Builds a sales ledger report from farmer orders.
  static CsvReportData buildOrdersSalesReport({
    required List<PlacedOrder> orders,
  }) {
    final headers = [
      'Order ID',
      'Order Date',
      'Status',
      'Buyer / Recipient',
      'Commodity Items',
      'Total Items / Quantity',
      'Order Total (PHP)',
      'Payment Method',
      'Delivery Address',
    ];

    final rows = <List<dynamic>>[];
    double totalAmount = 0.0;

    for (final order in orders) {
      totalAmount += order.total;
      final itemNames = order.items.map((i) => i.productName).join('; ');
      final totalQty = order.items.fold<int>(
        0,
        (sum, item) => sum + item.quantity,
      );

      rows.add([
        order.id,
        _formatDateTime(order.placedAt),
        order.status.label,
        order.buyerName.isNotEmpty ? order.buyerName : 'N/A',
        itemNames,
        totalQty.toString(),
        order.total.toStringAsFixed(2),
        order.payment.method.name.toUpperCase(),
        order.deliveryAddress,
      ]);
    }

    return CsvReportData(
      headers: headers,
      rows: rows,
      totalAmount: totalAmount,
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
