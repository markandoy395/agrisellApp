import 'package:flutter/material.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import '../../domain/delivery_request.dart';
import '../styles/rider_delivery_reference_styles.dart';
import 'rider_detail_card.dart';

class RiderDetailLocationCard extends StatelessWidget {
  const RiderDetailLocationCard({
    required this.request,
    this.delivery = false,
    super.key,
  });
  final DeliveryRequest request;
  final bool delivery;
  @override
  Widget build(BuildContext context) {
    final distance = delivery
        ? request.pickupToDeliveryDistanceKm
        : request.routeDistanceKm;
    final minutes = delivery
        ? request.pickupToDeliveryMinutes
        : request.routeEstimatedTravelMinutes;
    final deadline = delivery
        ? request.deliveryDeadline
        : request.pickupDeadline;
    final instructions = delivery
        ? request.deliveryInstructions
        : request.pickupInstructions;
    final color = delivery
        ? AgrisellColors.statusRedText
        : AgrisellColors.authGreen;
    return RiderDetailSection(
      title: delivery ? 'Delivery information' : 'Pickup information',
      icon: Icons.location_on_rounded,
      color: color,
      trailing: distance == null && minutes == null
          ? null
          : Text(
              [
                if (distance != null) '${distance.toStringAsFixed(1)} km',
                if (minutes != null) '$minutes min',
              ].join(' · '),
              style: RiderDeliveryReferenceStyles.strongCaption,
            ),
      children: [
        RiderDetailLine(
          icon: Icons.person_rounded,
          label: delivery
              ? 'Buyer: ${request.buyerName}'
              : '${request.sellerName} · Seller',
          color: AgrisellColors.headingGreen,
        ),
        RiderDetailLine(
          icon: Icons.place_outlined,
          label: delivery
              ? request.deliveryLocation.address
              : request.pickupLocation.address,
          color: color,
        ),
        if (deadline != null)
          RiderDetailLine(
            icon: Icons.schedule_rounded,
            label: delivery ? 'Delivery deadline' : 'Pickup deadline',
            value: riderDetailDate(context, deadline),
            color: AgrisellColors.statusRedText,
          ),
        if (instructions.isNotEmpty)
          RiderDetailInstructions(text: instructions, delivery: delivery),
      ],
    );
  }
}
