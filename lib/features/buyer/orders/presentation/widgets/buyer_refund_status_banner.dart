import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/buyer/orders/presentation/styles/buyer_refund_detail_styles.dart';
import 'package:agresell_app/features/buyer/orders/presentation/utils/buyer_refund_helpers.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';

/// Highlights total refund amount, status badge pill, and reference number.
class BuyerRefundStatusBanner extends StatelessWidget {
  const BuyerRefundStatusBanner({
    required this.isCompleted,
    required this.isApproved,
    required this.refundAmount,
    required this.refundRef,
    super.key,
  });

  final bool isCompleted;
  final bool isApproved;
  final double refundAmount;
  final String refundRef;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: BuyerRefundDetailStyles.bannerPadding,
    decoration: BuyerRefundDetailStyles.bannerDecoration(
      isCompleted: isCompleted,
      isApproved: isApproved,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Refund Amount',
              style: BuyerRefundDetailStyles.bannerTitle(
                isCompleted: isCompleted,
                isApproved: isApproved,
              ),
            ),
            Container(
              padding: BuyerRefundDetailStyles.statusBadgePadding,
              decoration: BuyerRefundDetailStyles.statusBadgeDecoration,
              child: Text(
                isCompleted
                    ? 'Refund Completed'
                    : (isApproved ? 'Refund Approved' : 'In Progress'),
                style: BuyerRefundDetailStyles.bannerStatusBadgeText(
                  isCompleted: isCompleted,
                  isApproved: isApproved,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          formatBasketPeso(refundAmount),
          style: BuyerRefundDetailStyles.bannerAmount(
            isCompleted: isCompleted,
            isApproved: isApproved,
          ),
        ),
        if (refundRef.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                'Reference: $refundRef',
                style: BuyerRefundDetailStyles.referenceText,
              ),
              const SizedBox(width: 6),
              InkWell(
                onTap: () => BuyerRefundHelpers.copyReference(context, refundRef),
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
  );
}
