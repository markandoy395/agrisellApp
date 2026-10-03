import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/dashboard/presentation/styles/rider_nearby_request_summary_styles.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_status_pills.dart';

class RiderNearbyRequestPreview extends StatelessWidget {
  const RiderNearbyRequestPreview({required this.request, super.key});

  final DeliveryRequest request;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 38,
        height: 38,
        alignment: Alignment.center,
        decoration: RiderNearbyRequestSummaryStyles.itemIconDecoration,
        child: const Icon(
          Icons.inventory_2_outlined,
          size: 20,
          color: AgrisellColors.authGreen,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    request.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: RiderNearbyRequestSummaryStyles.itemTitleStyle,
                  ),
                ),
                if (request.deliveryFee > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    'PHP ${request.deliveryFee.toStringAsFixed(0)}',
                    style: RiderNearbyRequestSummaryStyles.itemFeeStyle,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              request.pickupLocation.address,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: RiderNearbyRequestSummaryStyles.itemAddressStyle,
            ),
            const SizedBox(height: 7),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                if (request.routeDistanceKm != null)
                  RiderStatusPill(
                    label:
                        '${request.routeDistanceKm!.toStringAsFixed(1)} km away',
                    icon: Icons.near_me_outlined,
                    backgroundColor: AgrisellColors.statusBlueBackground,
                    foregroundColor: AgrisellColors.statusBlueText,
                  ),
                if (request.routeEstimatedTravelMinutes != null)
                  RiderStatusPill(
                    label: '${request.routeEstimatedTravelMinutes} min',
                    icon: Icons.schedule_rounded,
                    backgroundColor: AgrisellColors.statusPurpleBackground,
                    foregroundColor: AgrisellColors.statusPurpleText,
                  ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

class RiderNearbyQueueIcon extends StatelessWidget {
  const RiderNearbyQueueIcon({this.isMuted = false, super.key});

  final bool isMuted;

  @override
  Widget build(BuildContext context) => Container(
    width: 46,
    height: 46,
    alignment: Alignment.center,
    decoration: RiderNearbyRequestSummaryStyles.queueIconDecoration(isMuted),
    child: Icon(
      Icons.local_shipping_outlined,
      color: RiderNearbyRequestSummaryStyles.queueIconColor(isMuted),
      size: 24,
    ),
  );
}
