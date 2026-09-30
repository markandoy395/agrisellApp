import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

Future<void> showBuyerRefundDetailSheet(
  BuildContext context, {
  required PlacedOrder order,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AgrisellColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _BuyerRefundDetailSheet(order: order),
    );

class _BuyerRefundDetailSheet extends StatelessWidget {
  const _BuyerRefundDetailSheet({required this.order});

  final PlacedOrder order;

  String _formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return 'Pending';
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final month = monthNames[dateTime.month - 1];
    final day = dateTime.day.toString().padLeft(2, '0');
    final year = dateTime.year;
    final hour = dateTime.hour > 12
        ? dateTime.hour - 12
        : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$month $day, $year · $hour:$minute $period';
  }

  void _copyReference(BuildContext context, String reference) {
    if (reference.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: reference.trim()));
    ScaffoldMessenger.of(context).showAppSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Refund reference copied to clipboard.'),
      ),
    );
  }

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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AgrisellColors.borderLine,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Refund Details & Tracker',
                        style: TextStyle(
                          color: AgrisellColors.headingGreen,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Order ID: ${order.id}',
                        style: const TextStyle(
                          color: AgrisellColors.mutedText,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
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
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AgrisellColors.statusGreenBackground
                    : (isApproved
                        ? AgrisellColors.statusOrangeBackground
                        : AgrisellColors.statusPurpleBackground),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted
                      ? AgrisellColors.statusGreenText.withValues(alpha: 0.3)
                      : (isApproved
                          ? AgrisellColors.statusOrangeText.withValues(alpha: 0.3)
                          : AgrisellColors.statusPurpleText.withValues(alpha: 0.3)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Refund Amount',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isCompleted
                              ? AgrisellColors.statusGreenText
                              : (isApproved
                                  ? AgrisellColors.statusOrangeText
                                  : AgrisellColors.statusPurpleText),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCompleted
                              ? 'Refund Completed'
                              : (isApproved ? 'Refund Approved' : 'In Progress'),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isCompleted
                                ? AgrisellColors.statusGreenText
                                : (isApproved
                                    ? AgrisellColors.statusOrangeText
                                    : AgrisellColors.statusPurpleText),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatBasketPeso(refundAmount),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isCompleted
                          ? AgrisellColors.statusGreenText
                          : (isApproved
                              ? AgrisellColors.statusOrangeText
                              : AgrisellColors.statusPurpleText),
                    ),
                  ),
                  if (refundRef.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Reference: $refundRef',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AgrisellColors.brandBlack,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => _copyReference(context, refundRef),
                          borderRadius: BorderRadius.circular(4),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.copy_rounded,
                              size: 15,
                              color: AgrisellColors.authGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Refund Progress Timeline',
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            _TimelineStep(
              title: 'Order Cancelled',
              subtitle: 'Cancellation recorded. Reason: $reason',
              timestamp: _formatDateTime(order.cancelledAt ?? order.placedAt),
              isCompleted: true,
              isCurrent: !isApproved && !isCompleted,
            ),
            _TimelineStep(
              title: 'Refund Reviewed & Approved',
              subtitle: 'Admin and seller verified payment eligibility for refund.',
              timestamp: isApproved || isCompleted
                  ? _formatDateTime(payment.refundedAt ?? order.cancelledAt)
                  : 'Pending verification',
              isCompleted: isApproved || isCompleted,
              isCurrent: isApproved && !isCompleted,
            ),
            _TimelineStep(
              title: 'Refund Disbursed / Completed',
              subtitle: isCompleted
                  ? 'Funds transferred back to your GCash account.'
                  : 'Processing disbursement to your account.',
              timestamp: isCompleted
                  ? _formatDateTime(payment.refundedAt ?? DateTime.now())
                  : 'Pending disbursement',
              isCompleted: isCompleted,
              isCurrent: isCompleted,
              isLast: true,
            ),
            const SizedBox(height: 18),
            const Divider(height: 1, color: AgrisellColors.borderLine),
            const SizedBox(height: 16),
            const Text(
              'Transaction Summary',
              style: TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            _SummaryRow(label: 'Payment Method', value: payment.method.label),
            if (payment.transactionReference.isNotEmpty)
              _SummaryRow(
                label: 'Original Reference',
                value: payment.transactionReference,
              ),
            _SummaryRow(
              label: 'Original Order Total',
              value: formatBasketPeso(order.total),
            ),
            _SummaryRow(
              label: 'Refund Amount',
              value: formatBasketPeso(refundAmount),
            ),
            _SummaryRow(label: 'Reason', value: reason),
          ],
        ),
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
    this.isLast = false,
  });

  final String title;
  final String subtitle;
  final String timestamp;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AgrisellColors.authGreen
                    : (isCurrent
                        ? AgrisellColors.statusOrangeText
                        : AgrisellColors.searchBackground),
                border: Border.all(
                  color: isCompleted || isCurrent
                      ? Colors.transparent
                      : AgrisellColors.borderLine,
                  width: 2,
                ),
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_rounded
                    : (isCurrent ? Icons.refresh_rounded : Icons.circle),
                size: 13,
                color: isCompleted || isCurrent
                    ? Colors.white
                    : AgrisellColors.mutedText,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: isCompleted
                    ? AgrisellColors.authGreen
                    : AgrisellColors.borderLine,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isCompleted || isCurrent
                              ? AgrisellColors.brandBlack
                              : AgrisellColors.mutedText,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timestamp,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AgrisellColors.mutedText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AgrisellColors.mutedText,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AgrisellColors.mutedText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12,
                color: AgrisellColors.brandBlack,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
