import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/delivery_request.dart';
import '../../domain/delivery_status.dart';
import '../controllers/rider_location_controller.dart';
import '../controllers/rider_route_controller.dart';
import '../styles/rider_map_design_styles.dart';
import '../styles/rider_map_nav_styles.dart';
import 'rider_route_panel.dart';
import 'rider_map_route_loading.dart';
import 'rider_nav_active_delivery_details.dart';

class RiderMapNavigationSheet extends StatelessWidget {
  const RiderMapNavigationSheet({
    required this.routeController,
    required this.locationController,
    required this.requests,
    required this.request,
    required this.onExit,
    required this.onOpenDelivery,
    this.onMessage,
    this.status,
    super.key,
  });
  final RiderRouteController routeController;
  final RiderLocationController locationController;
  final List<DeliveryRequest> requests;
  final DeliveryRequest? request;
  final VoidCallback onExit;
  final VoidCallback onOpenDelivery;
  final VoidCallback? onMessage;
  final DeliveryStatus? status;

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: .46,
    minChildSize: .18,
    maxChildSize: .84,
    builder: (context, scrollController) => Container(
      decoration: RiderMapDesignStyles.sheet,
      child: Material(
        color: Colors.transparent,
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
          children: [
            const Center(child: Icon(Icons.drag_handle)),
            Row(
              children: [
                Expanded(
                  child: routeController.activeRoute == null
                      ? RiderMapRouteLoading(
                          controller: routeController,
                          locationController: locationController,
                          requests: requests,
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              routeController.activeRoute == null
                                  ? 'Finding route...'
                                  : '${routeController.remainingTravelMinutes} min',
                              style: RiderMapDesignStyles.title,
                            ),
                            if (routeController.activeRoute != null)
                              Text(
                                '${routeController.remainingDistanceKm.toStringAsFixed(1)} km • '
                                'Arrive ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(routeController.estimatedArrival!))}',
                                style: RiderMapDesignStyles.caption,
                              ),
                          ],
                        ),
                ),
                TextButton(
                  style: RiderMapNavStyles.exitPillButton,
                  onPressed: onExit,
                  child: const Text('Exit'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (request case final delivery?) ...[
              RiderNavActiveDeliveryDetails(
                delivery: delivery,
                onOpenDelivery: onOpenDelivery,
                status: status,
                onMessage: onMessage,
              ),
            ],
            const SizedBox(height: 12),
            if (routeController.activeRoute != null)
              TextButton.icon(
                onPressed:
                    !routeController.canRefresh ||
                        locationController.location == null
                    ? null
                    : () => unawaited(
                        routeController.refreshRoute(
                          location: locationController.location!,
                          requests: requests,
                          includeAlternatives: true,
                        ),
                      ),
                icon: const Icon(Icons.alt_route),
                label: const Text('Find alternative routes'),
              ),
            if (locationController.location case final location?)
              RiderRoutePanel(
                controller: routeController,
                requests: requests,
                location: location,
                locationController: locationController,
                showRequestPicker: false,
              ),
          ],
        ),
      ),
    ),
  );
}
