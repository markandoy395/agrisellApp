import 'package:agresell_app/core/theme/shared_presentation_styles.dart';
import 'package:flutter/material.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_details.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_summary.dart';

class RiderDeliveryRequestOverview extends StatelessWidget {
  const RiderDeliveryRequestOverview({required this.request, super.key});

  final DeliveryRequest request;

  @override
  Widget build(BuildContext context) => RiderSurfaceCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          request.productName,
          style: SharedPresentationStyles.headingTitleExtraBold,
        ),
        const SizedBox(height: 12),
        RiderRequestDetailLine(
          icon: Icons.storefront_outlined,
          text: 'Seller: ${request.sellerName}',
        ),
        RiderRequestDetailLine(
          icon: Icons.person_outline_rounded,
          text: 'Customer: ${request.buyerName}',
        ),
        RiderRequestDetailLine(
          icon: Icons.place_outlined,
          text: 'Pick up from: ${request.pickupLocation.address}',
        ),
        RiderRequestDetailLine(
          icon: Icons.location_on_outlined,
          text: 'Deliver to: ${request.deliveryLocation.address}',
        ),
        const SizedBox(height: 7),
        RiderRequestSummaryChips(request: request),
        if (request.pickupInstructions.isNotEmpty) ...[
          const SizedBox(height: 12),
          _Instruction(
            label: 'Pickup instructions',
            value: request.pickupInstructions,
          ),
        ],
        if (request.deliveryInstructions.isNotEmpty) ...[
          const SizedBox(height: 8),
          _Instruction(
            label: 'Delivery instructions',
            value: request.deliveryInstructions,
          ),
        ],
      ],
    ),
  );
}

class _Instruction extends StatelessWidget {
  const _Instruction({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Text(
    '$label: $value',
    style: SharedPresentationStyles.mutedCaptionSemiboldLoose,
  );
}
