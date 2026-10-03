import 'package:agresell_app/features/farmer/reservations/presentation/styles/farmer_order_buyer_summary_styles.dart';
import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/shared/orders/domain/placed_order.dart';

class FarmerOrderBuyerSummary extends StatelessWidget {
  const FarmerOrderBuyerSummary({required this.order, super.key});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: FarmerOrderBuyerSummaryStyles.containerDecoration,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.person_add_alt_1_outlined,
              size: 17,
              color: AgrisellColors.headingGreen,
            ),
            SizedBox(width: 6),
            Text(
              'New buyer order',
              style: SharedPresentationStyles.headingBodyExtraBold,
            ),
          ],
        ),
        const SizedBox(height: 8),
        _BuyerSummaryLine(
          icon: Icons.location_on_outlined,
          value: order.deliveryAddress,
        ),
        const SizedBox(height: 5),
        _BuyerSummaryLine(icon: Icons.phone_outlined, value: order.phoneNumber),
      ],
    ),
  );
}

class _BuyerSummaryLine extends StatelessWidget {
  const _BuyerSummaryLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(icon, size: 16, color: AgrisellColors.mutedText),
      const SizedBox(width: 7),
      Expanded(
        child: Text(value, style: FarmerOrderBuyerSummaryStyles.valueText),
      ),
    ],
  );
}
