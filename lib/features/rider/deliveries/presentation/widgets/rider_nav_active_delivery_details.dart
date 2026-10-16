import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter/material.dart';
import '../styles/rider_map_progress_styles.dart';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_stage.dart';
import '../../domain/delivery_status.dart';
import '../styles/rider_map_design_styles.dart';
import '../styles/rider_map_nav_styles.dart';
import 'rider_delivery_card_header.dart';
import 'rider_delivery_compact_progress.dart';
import 'rider_nav_action_buttons.dart';

class RiderNavActiveDeliveryDetails extends StatelessWidget {
  const RiderNavActiveDeliveryDetails({
    required this.delivery,
    required this.onOpenDelivery,
    this.status,
    this.onMessage,
    super.key,
  });

  final DeliveryRequest delivery;
  final VoidCallback onOpenDelivery;
  final DeliveryStatus? status;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RiderDeliveryCardHeader(request: delivery),
      const SizedBox(height: 16),
      RiderDeliveryCompactProgress(
        status: status ?? delivery.stage.canonicalStatus,
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: RiderMapDesignStyles.card,
        child: Row(
          children: [
            const Icon(
              Icons.location_on_rounded,
              color: AgrisellColors.authGreen,
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.stage.isDeliveryLeg
                        ? 'Deliver to'
                        : 'Pick up from',
                    style: RiderMapDesignStyles.caption,
                  ),
                  Text(
                    delivery.stage.isDeliveryLeg
                        ? delivery.deliveryLocation.address
                        : delivery.pickupLocation.address,
                    style: RiderMapDesignStyles.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            TextButton(
              style: RiderMapNavStyles.navigatePillButton,
              onPressed: onOpenDelivery,
              child: const Text('Navigate'),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: RiderMapNavStyles.nextAlertCard,
        child: Row(
          children: [
            const Icon(
              Icons.near_me_rounded,
              color: AgrisellColors.statusBlueText,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.stage.isDeliveryLeg
                        ? 'Next: Arrive at delivery'
                        : 'Next: Arrive at pickup',
                    style: RiderMapProgressStyles.nextAction,
                  ),
                  Text(
                    'Pickup deadline: ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(delivery.pickupDeadline))}',
                    style: RiderMapDesignStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      RiderNavActionButtons(
        onCall: () {},
        onMessage: onMessage,
        onProblem: () {},
        onMore: () {},
        onManageDelivery: onOpenDelivery,
      ),
    ],
  );
}
