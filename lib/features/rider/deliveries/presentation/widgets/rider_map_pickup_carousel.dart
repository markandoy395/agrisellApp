import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:flutter/material.dart';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_stage.dart';
import '../styles/rider_map_design_styles.dart';
import 'rider_delivery_request_details.dart';

class RiderMapPickupCarousel extends StatelessWidget {
  const RiderMapPickupCarousel({
    required this.requests,
    required this.onTap,
    required this.onOpenList,
    super.key,
  });
  final List<DeliveryRequest> requests;
  final ValueChanged<DeliveryRequest> onTap;
  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) {
    final pickups = requests
        .where((request) => request.stage == DeliveryStage.readyForPickup)
        .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: RiderMapDesignStyles.carouselIconContainer,
              child: const Icon(
                Icons.playlist_add_check_circle_outlined,
                color: AgrisellColors.authGreen,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ready for pickup',
                    style: RiderMapDesignStyles.title,
                  ),
                  Text(
                    '${pickups.length} requests nearby',
                    style: RiderMapDesignStyles.green,
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: onOpenList,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View all'),
                  Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (pickups.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'Eligible pickup requests will appear here.',
              style: RiderMapDesignStyles.caption,
            ),
          )
        else
          SizedBox(
            height: 220 + MediaQuery.textScalerOf(context).scale(12) * 6,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: pickups.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) => _Pickup(
                request: pickups[index],
                onTap: () => onTap(pickups[index]),
              ),
            ),
          ),
      ],
    );
  }
}

class _Pickup extends StatelessWidget {
  const _Pickup({required this.request, required this.onTap});
  final DeliveryRequest request;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 165,
    child: DecoratedBox(
      decoration: RiderMapDesignStyles.carouselCard,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: RiderRequestProductImage(
                    url: request.productImageUrl,
                    productName: request.productName,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  request.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RiderMapDesignStyles.title,
                ),
                Text(
                  request.sellerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: RiderMapDesignStyles.caption,
                ),
                const SizedBox(height: 4),
                Text(
                  'PHP ${request.deliveryFee.toStringAsFixed(2)}',
                  style: RiderMapDesignStyles.priceGreen,
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 13,
                      color: AgrisellColors.statusBlueText,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      request.routeDistanceKm == null
                          ? '-'
                          : '${request.routeDistanceKm!.toStringAsFixed(1)} km',
                      style: RiderMapDesignStyles.metaText,
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.access_time_rounded,
                      size: 13,
                      color: AgrisellColors.statusBlueText,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      request.routeEstimatedTravelMinutes == null
                          ? '-'
                          : '${request.routeEstimatedTravelMinutes} min',
                      style: RiderMapDesignStyles.metaText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
