import 'dart:async';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location_quality.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_directions_sheet.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';

part 'rider_route_panel_details.dart';
part 'rider_route_panel_helpers.dart';

class RiderRoutePanel extends StatelessWidget {
  const RiderRoutePanel({
    required this.controller,
    required this.requests,
    required this.location,
    required this.locationController,
    super.key,
  });

  final RiderRouteController controller;
  final List<DeliveryRequest> requests;
  final RiderDeviceLocation location;
  final RiderLocationController locationController;

  @override
  Widget build(BuildContext context) {
    final available = requests
        .where((request) => request.pickupLocation.hasCoordinates)
        .toList(growable: false);
    final route = controller.activeRoute;
    final selected = _selectedRequest(available, controller.selectedRequestId);
    return RiderSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.route_rounded,
                color: AgrisellColors.authGreen,
                size: 20,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isDense: true,
                    isExpanded: true,
                    value: selected?.id,
                    hint: const Text('Select a pickup'),
                    items: [
                      for (final request in available)
                        DropdownMenuItem(
                          value: request.id,
                          child: Text(
                            request.productName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                    onChanged: (requestId) {
                      if (requestId == null) return;
                      unawaited(
                        controller.selectRequest(
                          requestId: requestId,
                          location: location,
                          requests: requests,
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (route != null)
                IconButton(
                  tooltip: controller.isOnline
                      ? 'Refresh road route'
                      : 'Route refresh needs internet',
                  visualDensity: VisualDensity.compact,
                  onPressed: controller.canRefresh
                      ? () => unawaited(
                          controller.refreshRoute(
                            location: location,
                            requests: requests,
                          ),
                        )
                      : null,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  color: AgrisellColors.authGreen,
                ),
              if (route != null)
                IconButton(
                  tooltip: 'Turn-by-turn directions',
                  visualDensity: VisualDensity.compact,
                  onPressed: () => showRiderDirectionsSheet(context, route),
                  icon: const Icon(Icons.directions_rounded, size: 21),
                  color: AgrisellColors.authGreen,
                ),
            ],
          ),
          if (route == null)
            _RouteStatus(controller: controller)
          else ...[
            _RouteMetrics(
              controller: controller,
              route: route,
              selectedRequest: selected,
            ),
            _GpsRouteStatus(
              location: location,
              warning: locationController.operationalWarning,
              onSettings:
                  locationController.isBackgroundRestricted ||
                      locationController.isApproximate
                  ? () => unawaited(locationController.openAppSettings())
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}
