import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_gcash_review_summary_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/payments/price_formatter.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class FarmerGcashReviewSummary extends StatelessWidget {
  const FarmerGcashReviewSummary({required this.order, super.key});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(13),
    decoration: FarmerGcashReviewSummaryStyles.containerDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BUYER-SUBMITTED REFERENCE',
          style: SharedPresentationStyles.mutedCaptionBold,
        ),
        const SizedBox(height: 5),
        SelectableText(
          order.payment.transactionReference,
          style: FarmerGcashReviewSummaryStyles.textStyle,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Icon(
              order.payment.hasReceiptImage
                  ? Icons.image_outlined
                  : Icons.warning_amber_rounded,
              size: 17,
              color: order.payment.hasReceiptImage
                  ? AgrisellColors.statusGreenText
                  : AgrisellColors.statusOrangeText,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                order.payment.hasReceiptImage
                    ? 'Receipt image uploaded'
                    : 'No receipt image attached',
                style: FarmerGcashReviewSummaryStyles.textStyle2(order),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Expected amount',
                style: SharedPresentationStyles.mutedCaptionSemibold,
              ),
            ),
            Text(
              formatBasketPeso(order.total),
              style: FarmerGcashReviewSummaryStyles.textStyle3,
            ),
          ],
        ),
      ],
    ),
  );
}
