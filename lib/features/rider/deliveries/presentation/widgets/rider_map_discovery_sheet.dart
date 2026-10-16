import 'package:flutter/material.dart';
import '../../domain/delivery_request.dart';
import '../../domain/rider_nearby_farm.dart';
import '../styles/rider_map_design_styles.dart';
import 'rider_active_delivery_card.dart';
import 'rider_map_pickup_carousel.dart';
import 'rider_map_overlays.dart';

class RiderMapDiscoverySheet extends StatelessWidget {
  const RiderMapDiscoverySheet({
    required this.requests,
    required this.farms,
    required this.active,
    required this.onRequestTap,
    required this.onFarmTap,
    required this.onNavigate,
    required this.onOpenList,
    required this.onRefresh,
    required this.farmError,
    required this.farmsLoading,
    super.key,
  });
  final List<DeliveryRequest> requests;
  final List<RiderNearbyFarm> farms;
  final DeliveryRequest? active;
  final ValueChanged<DeliveryRequest> onRequestTap;
  final ValueChanged<RiderNearbyFarm> onFarmTap;
  final VoidCallback onNavigate;
  final VoidCallback onOpenList;
  final VoidCallback onRefresh;
  final String? farmError;
  final bool farmsLoading;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: .48,
    minChildSize: .16,
    maxChildSize: .78,
    builder: (context, scrollController) => Container(
      decoration: RiderMapDesignStyles.sheet,
      child: Material(
        color: Colors.transparent,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          children: [
            const Center(child: Icon(Icons.drag_handle, size: 24)),
            if (active != null) ...[
              RiderActiveDeliveryCard(request: active!, onNavigate: onNavigate),
              const SizedBox(height: 12),
            ],
            RiderMapPickupCarousel(
              requests: requests,
              onTap: onRequestTap,
              onOpenList: onOpenList,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              style: RiderMapDesignStyles.primaryButton,
              onPressed: onOpenList,
              icon: const Icon(Icons.format_list_bulleted_rounded),
              label: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('View all requests'),
                  SizedBox(width: 6),
                  Icon(Icons.chevron_right_rounded, size: 20),
                ],
              ),
            ),
            if (farmError != null) ...[
              const SizedBox(height: 12),
              RiderMapDiscoveryError(message: farmError!, onRetry: onRefresh),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Nearby farms',
                    style: RiderMapDesignStyles.title,
                  ),
                ),
                IconButton(
                  tooltip: 'Refresh location',
                  onPressed: farmsLoading ? null : onRefresh,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            if (farmsLoading) const LinearProgressIndicator(),
            for (final farm in farms.take(10))
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.agriculture_outlined),
                title: Text(farm.name, style: RiderMapDesignStyles.body),
                subtitle: Text(
                  '${farm.distanceKm.toStringAsFixed(1)} km',
                  style: RiderMapDesignStyles.caption,
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => onFarmTap(farm),
              ),
          ],
        ),
      ),
    ),
  );
}
