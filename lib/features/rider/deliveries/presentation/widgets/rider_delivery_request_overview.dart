import 'package:flutter/material.dart';
import '../../domain/delivery_request.dart';
import '../styles/rider_deliveries_design_styles.dart';
import 'rider_delivery_card_header.dart';
import 'rider_delivery_request_summary.dart';

class RiderDeliveryRequestOverview extends StatelessWidget {
  const RiderDeliveryRequestOverview({required this.request, super.key});
  final DeliveryRequest request;

  @override
  Widget build(BuildContext context) => Container(
    decoration: RiderDeliveriesDesignStyles.card,
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RiderDeliveryCardHeader(request: request),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'PHP ${request.deliveryFee.toStringAsFixed(2)}',
                style: RiderDeliveriesDesignStyles.earning,
              ),
              Text(
                'Estimated earning',
                style: RiderDeliveriesDesignStyles.caption,
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: ExpansionTile(
            key: PageStorageKey<String>(
              'rider-delivery-information-${request.id}',
            ),
            tilePadding: EdgeInsets.zero,
            title: Text(
              'Delivery information',
              style: RiderDeliveriesDesignStyles.label,
            ),
            children: [
              RiderRequestSummaryChips(request: request),
              Text(
                'Customer: ${request.buyerName}',
                style: RiderDeliveriesDesignStyles.caption,
              ),
              if (request.pickupInstructions.isNotEmpty)
                Text(
                  'Pickup instructions: ${request.pickupInstructions}',
                  style: RiderDeliveriesDesignStyles.caption,
                ),
              if (request.deliveryInstructions.isNotEmpty)
                Text(
                  'Delivery instructions: ${request.deliveryInstructions}',
                  style: RiderDeliveriesDesignStyles.caption,
                ),
            ],
          ),
        ),
      ],
    ),
  );
}
