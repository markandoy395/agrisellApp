import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/orders/presentation/styles/buyer_refund_detail_styles.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_status_banner.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_summary_row.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_timeline.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

/// Opens the modal bottom sheet displaying full refund progress and details.
Future<void> showBuyerRefundDetailSheet(
  BuildContext context, {
  required PlacedOrder order,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: BuyerRefundDetailStyles.sheetShape,
      builder: (_) => BuyerRefundDetailSheet(order: order),
    );

/// Modal bottom sheet widget displaying refund progress timeline and transaction details.
class BuyerRefundDetailSheet extends StatelessWidget {
  const BuyerRefundDetailSheet({required this.order, super.key});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final payment = order.payment;
    final isCompleted = payment.status == OrderPaymentStatus.refunded ||
        payment.refundStatus.toLowerCase() == 'completed';
    final isApproved = payment.status == OrderPaymentStatus.refundRequired ||
        payment.refundStatus.toLowerCase() == 'approved';
    final refundAmount = payment.refundAmount ?? order.total;
    final refundRef = payment.refundReference.isNotEmpty
        ? payment.refundReference
        : (payment.transactionReference.isNotEmpty
            ? payment.transactionReference
            : '');
    final reason = payment.refundReason.isNotEmpty
        ? payment.refundReason
        : (order.cancellationReason ?? 'Order cancelled');

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: BuyerRefundDetailStyles.sheetPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHandle(),
            const SizedBox(height: 16),
            _buildHeader(context),
            const SizedBox(height: 16),
            BuyerRefundStatusBanner(
              isCompleted: isCompleted,
              isApproved: isApproved,
              refundAmount: refundAmount,
              refundRef: refundRef,
            ),
            const SizedBox(height: 20),
            BuyerRefundTimeline(
              order: order,
              payment: payment,
              reason: reason,
              isApproved: isApproved,
              isCompleted: isCompleted,
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: AgrisellColors.borderLine),
            const SizedBox(height: 16),
            const Text(
              'Transaction Summary',
              style: BuyerRefundDetailStyles.sectionHeading,
            ),
            const SizedBox(height: 10),
            _buildSummary(
              payment: payment,
              refundAmount: refundAmount,
              reason: reason,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() => Center(
    child: Container(
      width: 36,
      height: 4,
      decoration: BuyerRefundDetailStyles.handleDecoration,
    ),
  );

  Widget _buildHeader(BuildContext context) => Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Refund Details & Tracker',
              style: BuyerRefundDetailStyles.headerTitle,
            ),
            const SizedBox(height: 3),
            Text(
              'Order ID: ${order.id}',
              style: BuyerRefundDetailStyles.orderIdSubtitle,
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Close',
        icon: const Icon(Icons.close_rounded, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
    ],
  );

  Widget _buildSummary({
    required OrderPayment payment,
    required double refundAmount,
    required String reason,
  }) =>
      Column(
        children: [
          BuyerRefundSummaryRow(
            label: 'Payment Method',
            value: payment.method.label,
          ),
          if (payment.transactionReference.isNotEmpty)
            BuyerRefundSummaryRow(
              label: 'Original Reference',
              value: payment.transactionReference,
            ),
          BuyerRefundSummaryRow(
            label: 'Original Order Total',
            value: formatBasketPeso(order.total),
          ),
          BuyerRefundSummaryRow(
            label: 'Refund Amount',
            value: formatBasketPeso(refundAmount),
          ),
          BuyerRefundSummaryRow(label: 'Reason', value: reason),
        ],
      );
}
