import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_request_metadata.dart';
import '../styles/rider_pickup_design_styles.dart';
import 'rider_detail_card.dart';
import 'rider_detail_product_card.dart';
import 'rider_pickup_waiting_card.dart';

class RiderPickupHeader extends StatelessWidget {
  const RiderPickupHeader({super.key});
  @override
  Widget build(BuildContext context) => Container(
    decoration: RiderPickupDesignStyles.header,
    child: SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 14, 18, 22),
        child: Row(
          children: [
            const BackButton(color: AgrisellColors.surface),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Confirm pickup',
                    style: RiderPickupDesignStyles.heading,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Complete the requirements to confirm pickup',
                    style: RiderPickupDesignStyles.whiteCaption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class RiderPickupSummaryCard extends StatelessWidget {
  const RiderPickupSummaryCard({required this.request, super.key});
  final DeliveryRequest request;
  @override
  Widget build(BuildContext context) => RiderDetailCard(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RiderDetailProductImage(
          url: request.productImageUrl,
          productName: request.productName,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(request.productName, style: RiderPickupDesignStyles.title),
              Text(
                request.orderNumber.toLowerCase().startsWith('order ')
                    ? request.orderNumber
                    : 'Order ${request.orderNumber}',
                style: RiderPickupDesignStyles.caption,
              ),
              if (request.productCategory.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.eco_rounded,
                      color: AgrisellColors.authGreen,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        request.productCategory,
                        style: RiderPickupDesignStyles.body,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              Text(
                'Pickup: ${request.pickupLocation.address.split(',').first}',
                style: RiderPickupDesignStyles.pickupLabel,
              ),
              if (request.pickupLocation.address.contains(','))
                Text(
                  request.pickupLocation.address
                      .split(',')
                      .skip(1)
                      .join(',')
                      .trim(),
                  style: RiderPickupDesignStyles.caption,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class RiderPickupInstructionsCard extends StatelessWidget {
  const RiderPickupInstructionsCard({
    required this.request,
    this.waitingStartedAt,
    super.key,
  });
  final DeliveryRequest request;
  final DateTime? waitingStartedAt;
  @override
  Widget build(BuildContext context) => RiderDetailCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: RiderPickupDesignStyles.tint(AgrisellColors.authGreen),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.description_rounded,
                color: AgrisellColors.authGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pickup instructions',
                      style: RiderPickupDesignStyles.pickupLabel,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      request.pickupInstructions.isEmpty
                          ? 'No pickup instructions.'
                          : request.pickupInstructions,
                      style: RiderPickupDesignStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (request.handlingRequirements.isNotEmpty) ...[
          const SizedBox(height: 12),
          const RiderDetailLine(
            icon: Icons.inventory_2_outlined,
            label: 'Handling requirements',
          ),
          for (final requirement in request.handlingRequirements)
            Text(
              requirement.instructions.isEmpty
                  ? requirement.type.label
                  : requirement.instructions,
              style: RiderPickupDesignStyles.body,
            ),
        ],
        if (waitingStartedAt case final startedAt?) ...[
          const SizedBox(height: 12),
          RiderPickupWaitingCard(startedAt: startedAt),
        ],
      ],
    ),
  );
}
