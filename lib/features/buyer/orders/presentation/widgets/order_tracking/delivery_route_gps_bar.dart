part of 'package:agresell_app/features/buyer/orders/presentation/screens/order_tracking_screen.dart';

class _DeliveryRouteGpsBar extends StatelessWidget {
  const _DeliveryRouteGpsBar({
    required this.status,
    required this.order,
  });

  final PlacedOrderStatus status;
  final PlacedOrder order;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      const SizedBox(height: 10),
      const Divider(height: 1, color: AgrisellColors.borderLine),
      const SizedBox(height: 8),
      InkWell(
        onTap: () => showDeliveryTrackingSheet(context, order: order),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: DeliveryRouteTrackerStyles.gpsCircleDecoration,
                child: const Icon(
                  Icons.location_on_rounded,
                  size: 16,
                  color: AgrisellColors.authGreen,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status == PlacedOrderStatus.shipping
                          ? 'Rider en route • Live GPS active'
                          : (status == PlacedOrderStatus.readyForPickup
                              ? 'Awaiting pickup • Live Map available'
                              : 'Delivered • View route summary'),
                      style: DeliveryRouteTrackerStyles.gpsStatusTitleStyle,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      status == PlacedOrderStatus.shipping
                          ? 'ETA: ~15 mins (2.4 km) • ~28 km/h'
                          : 'Tap to inspect live map & checkpoints',
                      style: DeliveryRouteTrackerStyles.gpsStatusSubtitleStyle,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: DeliveryRouteTrackerStyles.liveMapBadgeDecoration,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.map_rounded, size: 13, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Live Map',
                      style: DeliveryRouteTrackerStyles.liveMapTextStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
