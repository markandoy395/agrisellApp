import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/farmer/payouts/domain/farmer_cash_out_request.dart';
import 'package:agresell_app/features/farmer/payouts/domain/farmer_payout.dart';
import 'package:agresell_app/features/farmer/reporting/farmer_financial_exporter.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_analytics_models.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_history_models.dart';
import 'package:agresell_app/features/rider/reporting/rider_financial_exporter.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

void main() {
  group('FarmerFinancialExporter Tests', () {
    test('buildPayoutsReport aggregates payouts and cash outs into rows', () {
      final now = DateTime(2026, 9, 21, 10, 30);
      final payouts = [
        FarmerPayout(
          payoutId: '101',
          paymentId: '201',
          orderId: '301',
          clientOrderId: 'AG-301',
          amount: 1500.0,
          status: FarmerPayoutStatus.paid,
          reference: 'PAY-101-REF',
          buyerName: 'Maria Santos',
          createdAt: now,
          paidAt: now.add(const Duration(hours: 2)),
        ),
      ];
      final cashOuts = [
        FarmerCashOutRequest(
          requestId: '501',
          amount: 2000.0,
          payoutMethod: 'gcash',
          accountName: 'Juan Dela Cruz',
          accountNumber: '09171234567',
          status: 'paid',
          createdAt: now,
        ),
      ];

      final report = FarmerFinancialExporter.buildPayoutsReport(
        payouts: payouts,
        cashOutRequests: cashOuts,
      );

      expect(report.headers.length, 10);
      expect(report.rows.length, 2);
      expect(report.totalAmount, 3500.0);

      // Payout row assertions
      final payoutRow = report.rows[0];
      expect(payoutRow[0], 'Order Payout');
      expect(payoutRow[1], 'PAY-101-REF');
      expect(payoutRow[2], 'AG-301');
      expect(payoutRow[5], 'Maria Santos');
      expect(payoutRow[6], '1500.00');
      expect(payoutRow[7], 'Paid');

      // Cash-out row assertions
      final cashOutRow = report.rows[1];
      expect(cashOutRow[0], 'Cash-Out Request');
      expect(cashOutRow[1], 'REQ-501');
      expect(cashOutRow[4], 'GCash');
      expect(cashOutRow[5], 'Juan Dela Cruz (09171234567)');
      expect(cashOutRow[6], '2000.00');
      expect(cashOutRow[7], 'Paid');
    });

    test('buildOrdersSalesReport maps orders into tabular sales data', () {
      final now = DateTime(2026, 9, 21, 12, 0);
      final orders = [
        PlacedOrder(
          id: '1001',
          placedAt: now,
          status: PlacedOrderStatus.delivered,
          deliveryAddress: '123 Session Road, Baguio City',
          buyerName: 'Elena Reyes',
          phoneNumber: '09181112233',
          payment: const OrderPayment.cashOnDelivery(),
          items: const [
            PlacedOrderItem(
              productId: 'p1',
              productName: 'Organic Highland Spinach',
              image: 'assets/images/vege.jpeg',
              sellerName: 'Green Farm',
              pricePerKg: 170.0,
              unit: 'kg',
              quantity: 5,
            ),
          ],
        ),
      ];

      final report = FarmerFinancialExporter.buildOrdersSalesReport(orders: orders);

      expect(report.headers.length, 9);
      expect(report.rows.length, 1);
      expect(report.totalAmount, 850.0);

      final row = report.rows[0];
      expect(row[0], '1001');
      expect(row[1], '2026-09-21 12:00');
      expect(row[2], 'Completed');
      expect(row[3], 'Elena Reyes');
      expect(row[4], 'Organic Highland Spinach');
      expect(row[5], '5');
      expect(row[6], '850.00');
      expect(row[7], 'CASHONDELIVERY');
      expect(row[8], '123 Session Road, Baguio City');
    });
  });

  group('RiderFinancialExporter Tests', () {
    test('buildEarningsReport maps rider earning entries and handles net calculations', () {
      final now = DateTime(2026, 9, 21, 14, 0);
      final range = RiderDateRange.forPeriod(RiderAnalyticsPeriod.today, now);
      final earnings = [
        RiderEarningEntry(
          id: 'earn-001',
          occurredAt: now,
          description: 'Highland express delivery',
          amount: 150.0,
          type: RiderEarningType.deliveryFee,
          payoutStatus: RiderPayoutStatus.paid,
          bonus: 20.0,
          incentive: 10.0,
          deduction: 5.0,
          deliveryId: 'DEL-99',
        ),
      ];

      final report = RiderFinancialExporter.buildEarningsReport(
        earnings: earnings,
        dateRange: range,
      );

      expect(report.headers.length, 11);
      expect(report.rows.length, 1);
      // Net: 150 + 20 + 10 - 5 = 175
      expect(report.totalAmount, 175.0);

      final row = report.rows[0];
      expect(row[0], 'earn-001');
      expect(row[2], 'DEL-99');
      expect(row[3], 'Highland express delivery');
      expect(row[4], 'Delivery fee');
      expect(row[5], '150.00');
      expect(row[6], '20.00');
      expect(row[7], '10.00');
      expect(row[8], '5.00');
      expect(row[9], '175.00');
      expect(row[10], 'Paid');
    });

    test('buildDeliveryHistoryReport maps trip history items', () {
      final now = DateTime(2026, 9, 21, 15, 30);
      final history = [
        RiderDeliveryHistoryEntry(
          id: 'del-55',
          orderNumber: 'AG-550',
          completedAt: now,
          pickupAddress: 'Farm Lot 4, La Trinidad',
          deliveryAddress: 'Burnham Park, Baguio',
          productName: 'Fresh Strawberries',
          quantityDescription: '3 boxes (1.5 kg)',
          deliveryFee: 120.0,
          status: RiderHistoryStatus.completed,
          customerRating: 5.0,
        ),
      ];

      final report = RiderFinancialExporter.buildDeliveryHistoryReport(
        deliveries: history,
      );

      expect(report.headers.length, 11);
      expect(report.rows.length, 1);
      expect(report.totalAmount, 120.0);

      final row = report.rows[0];
      expect(row[0], 'del-55');
      expect(row[1], 'AG-550');
      expect(row[3], 'Fresh Strawberries');
      expect(row[4], '3 boxes (1.5 kg)');
      expect(row[7], '120.00');
      expect(row[8], 'Completed');
      expect(row[10], '5.0 ★');
    });
  });
}
