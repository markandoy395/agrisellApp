import 'package:flutter/material.dart';

import 'package:agresell_app/features/buyer/orders/presentation/styles/buyer_refund_detail_styles.dart';

/// Single step within the refund progress timeline.
class BuyerRefundTimelineStep extends StatelessWidget {
  const BuyerRefundTimelineStep({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.isCompleted,
    required this.isCurrent,
    this.isLast = false,
    super.key,
  });

  final String title;
  final String subtitle;
  final String timestamp;
  final bool isCompleted;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BuyerRefundDetailStyles.timelineCircleDecoration(
              isCompleted: isCompleted,
              isCurrent: isCurrent,
            ),
            child: Icon(
              isCompleted
                  ? Icons.check_rounded
                  : (isCurrent ? Icons.refresh_rounded : Icons.circle),
              size: 13,
              color: BuyerRefundDetailStyles.timelineIconColor(
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              ),
            ),
          ),
          if (!isLast)
            Container(
              width: 2,
              height: 42,
              color: BuyerRefundDetailStyles.timelineLineColor(
                isCompleted: isCompleted,
              ),
            ),
        ],
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Padding(
          padding: BuyerRefundDetailStyles.timelineStepBottomPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: BuyerRefundDetailStyles.timelineStepTitle(
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    timestamp,
                    style: BuyerRefundDetailStyles.timelineTimestamp,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: BuyerRefundDetailStyles.timelineSubtitle,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
