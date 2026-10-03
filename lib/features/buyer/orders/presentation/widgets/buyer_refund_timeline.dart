import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/orders/presentation/styles/buyer_refund_detail_styles.dart';
import 'package:agresell_app/features/buyer/orders/presentation/utils/buyer_refund_helpers.dart';
import 'package:agresell_app/features/buyer/orders/presentation/widgets/buyer_refund_timeline_step.dart';
import 'package:agresell_app/features/shared/orders/domain/order_payment.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

/// Progress timeline section for the buyer refund detail sheet.
class BuyerRefundTimeline extends StatelessWidget {
  const BuyerRefundTimeline({
    required this.order,
    required this.payment,
    required this.reason,
    required this.isApproved,
    required this.isCompleted,
    super.key,
  });

  final PlacedOrder order;
  final OrderPayment payment;
  final String reason;
  final bool isApproved;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Refund Progress Timeline',
        style: BuyerRefundDetailStyles.sectionHeading,
      ),
      const SizedBox(height: 14),
      BuyerRefundTimelineStep(
        title: 'Order Cancelled',
        subtitle: 'Cancellation recorded. Reason: $reason',
        timestamp: BuyerRefundHelpers.formatDateTime(
          order.cancelledAt ?? order.placedAt,
        ),
        isCompleted: true,
        isCurrent: !isApproved && !isCompleted,
      ),
      BuyerRefundTimelineStep(
        title: 'Refund Reviewed & Approved',
        subtitle: 'Admin and seller verified payment eligibility for refund.',
        timestamp: isApproved || isCompleted
            ? BuyerRefundHelpers.formatDateTime(
                payment.refundedAt ?? order.cancelledAt,
              )
            : 'Pending verification',
        isCompleted: isApproved || isCompleted,
        isCurrent: isApproved && !isCompleted,
      ),
      BuyerRefundTimelineStep(
        title: 'Refund Disbursed / Completed',
        subtitle: isCompleted
            ? 'Funds transferred back to your GCash account.'
            : 'Processing disbursement to your account.',
        timestamp: isCompleted
            ? BuyerRefundHelpers.formatDateTime(
                payment.refundedAt ?? DateTime.now(),
              )
            : 'Pending disbursement',
        isCompleted: isCompleted,
        isCurrent: isCompleted,
        isLast: true,
      ),
    ],
  );
}
