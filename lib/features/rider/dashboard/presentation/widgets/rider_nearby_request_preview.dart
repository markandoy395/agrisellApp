import 'package:flutter/material.dart';
import 'rider_delivery_product_image.dart';
import '../styles/rider_reference_styles.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';

class RiderNearbyRequestPreview extends StatelessWidget {
  const RiderNearbyRequestPreview({required this.request, super.key});
  final DeliveryRequest request;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(6),
    decoration: RiderReferenceStyles.listRow,
    child: Row(
      children: [
        RiderDeliveryProductImage(path: request.productImageUrl),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RiderReferenceStyles.value,
              ),
              const SizedBox(height: 3),
              Text(
                request.pickupLocation.address,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: RiderReferenceStyles.caption,
              ),
              if (request.deliveryFee > 0)
                Text(
                  'PHP ${request.deliveryFee.toStringAsFixed(2)}',
                  style: RiderReferenceStyles.fee,
                ),
            ],
          ),
        ),
        if (request.routeDistanceKm != null) ...[
          const SizedBox(width: 6),
          const Icon(
            Icons.location_on_outlined,
            size: 16,
            color: RiderReferenceStyles.blue,
          ),
          const SizedBox(width: 3),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${request.routeDistanceKm!.toStringAsFixed(1)} km',
                style: RiderReferenceStyles.value,
              ),
              if (request.routeEstimatedTravelMinutes != null)
                Text(
                  '${request.routeEstimatedTravelMinutes} min',
                  style: RiderReferenceStyles.caption,
                ),
            ],
          ),
        ],
        const Icon(
          Icons.chevron_right_rounded,
          color: RiderReferenceStyles.muted,
          size: 18,
        ),
      ],
    ),
  );
}

class RiderNearbyQueueIcon extends StatelessWidget {
  const RiderNearbyQueueIcon({this.isMuted = false, super.key});
  final bool isMuted;
  @override
  Widget build(BuildContext context) => const Icon(
    Icons.location_on_outlined,
    color: RiderReferenceStyles.green,
    size: 22,
  );
}
