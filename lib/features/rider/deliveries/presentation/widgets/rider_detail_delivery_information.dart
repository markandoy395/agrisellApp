import 'package:flutter/material.dart';
import '../../domain/delivery_request.dart';
import 'rider_detail_card.dart';

class RiderDetailDeliveryInformation extends StatelessWidget {
  const RiderDetailDeliveryInformation({required this.request, super.key});
  final DeliveryRequest request;
  @override
  Widget build(BuildContext context) => RiderDetailSection(
    title: 'Delivery information',
    icon: Icons.person_outline_rounded,
    children: [
      RiderDetailLine(
        icon: Icons.person_outline_rounded,
        label: 'Customer: ${request.buyerName}',
      ),
      if (request.pickupInstructions.isNotEmpty) ...[
        RiderDetailInstructions(text: request.pickupInstructions),
        const SizedBox(height: 8),
      ],
      if (request.deliveryInstructions.isNotEmpty)
        RiderDetailInstructions(
          text: request.deliveryInstructions,
          delivery: true,
        ),
    ],
  );
}
