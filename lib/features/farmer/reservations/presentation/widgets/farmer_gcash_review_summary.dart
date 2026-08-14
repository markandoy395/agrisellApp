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
    decoration: BoxDecoration(
      color: AgrisellColors.forestSoft,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'BUYER-SUBMITTED REFERENCE',
          style: TextStyle(
            color: AgrisellColors.mutedText,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 5),
        SelectableText(
          order.payment.transactionReference,
          style: const TextStyle(
            color: AgrisellColors.brandBlack,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
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
                style: TextStyle(
                  color: order.payment.hasReceiptImage
                      ? AgrisellColors.statusGreenText
                      : AgrisellColors.statusOrangeText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
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
                style: TextStyle(
                  color: AgrisellColors.mutedText,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              formatBasketPeso(order.total),
              style: const TextStyle(
                color: AgrisellColors.headingGreen,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
