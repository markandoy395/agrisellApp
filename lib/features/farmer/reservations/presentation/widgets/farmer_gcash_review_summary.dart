import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/buyer/cart/presentation/widgets/basket/basket_price_formatter.dart';
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
