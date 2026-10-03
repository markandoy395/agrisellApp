import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_route_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_map_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_live_map.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_controls.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_location_fallback.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_overlays.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_route_panel.dart';

class RiderMapContent extends StatelessWidget {
  const RiderMapContent({
    required this.controller,
    required this.mapController,
    required this.requests,
    required this.farms,
    required this.roadAccessConnections,
    required this.farmDiscoveryError,
    required this.farmsLoading,
    required this.routeController,
    required this.riderId,
    required this.filter,
    required this.mapZoom,
    required this.discoveryRadiusKm,
    required this.navigationActive,
    required this.onFilterChanged,
    required this.onMarkerTap,
    required this.onFarmTap,
    required this.onNavigateActive,
    required this.onExitNavigation,
    required this.onRecenter,
    required this.onRefresh,
    required this.onOpenList,
    required this.onMapReady,
    required this.onPositionChanged,
    super.key,
  });

  final RiderLocationController controller;
  final MapController mapController;
  final List<DeliveryRequest> requests;
  final List<RiderNearbyFarm> farms;
  final List<RiderRoadAccessConnection> roadAccessConnections;
  final String? farmDiscoveryError;
  final bool farmsLoading;
  final RiderRouteController routeController;
  final String? riderId;
  final RiderMapFilter filter;
  final double mapZoom;
  final double discoveryRadiusKm;
  final bool navigationActive;
  final ValueChanged<RiderMapFilter> onFilterChanged;
  final RiderMapMarkerCallback onMarkerTap;
  final ValueChanged<RiderNearbyFarm> onFarmTap;
  final ValueChanged<DeliveryRequest> onNavigateActive;
  final VoidCallback onExitNavigation;
  final VoidCallback onRecenter;
  final VoidCallback onRefresh;
  final VoidCallback onOpenList;
  final VoidCallback onMapReady;
  final PositionCallback onPositionChanged;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final location = controller.location;
    final isLocationReady =
        (state == RiderLocationState.ready ||
            state == RiderLocationState.approximateLocation) &&
        location != null;

    if (!isLocationReady) {
      return RiderMapLocationFallback(controller: controller);
    }

    final displayedPoint = routeController.displayPoint(location);
    final riderPoint =
        RiderMapCameraPolicy.isCoordinateValid(
          displayedPoint.latitude,
          displayedPoint.longitude,
        )
        ? displayedPoint
        : DeliveryRoutePoint(
            latitude: location.latitude,
            longitude: location.longitude,
          );
    final active = requests
        .where(
          (request) =>
              riderId != null &&
              request.isAssignedTo(riderId!) &&
              !request.stage.isTerminal,
        )
        .firstOrNull;

    return Stack(
      children: [
        Positioned.fill(
          child: RiderLiveMap(
            riderPoint: riderPoint,
            routes: navigationActive ? routeController.routes : const [],
            activeRoute: navigationActive ? routeController.activeRoute : null,
            requests: requests,
            farms: farms,
            roadAccessConnections: roadAccessConnections,
            mapController: mapController,
            riderId: riderId,
            filter: filter,
            mapZoom: mapZoom,
            discoveryRadiusKm: discoveryRadiusKm,
            onMarkerTap: onMarkerTap,
            onFarmTap: onFarmTap,
            onMapReady: onMapReady,
            onPositionChanged: onPositionChanged,
          ),
        ),
        Positioned(
          left: 12,
          right: 12,
          top: 0,
          child: RiderMapTopOverlay(
            discoveryRadiusKm: discoveryRadiusKm,
            farmsLoading: farmsLoading,
            filter: filter,
            farmDiscoveryError: farmDiscoveryError,
            activeRequest: active,
            navigationActive: navigationActive,
            onOpenList: onOpenList,
            onRefresh: onRefresh,
            onFilterChanged: onFilterChanged,
            onNavigateActive: () {
              if (active != null) onNavigateActive(active);
            },
          ),
        ),
        Positioned(
          right: RiderMapStyles.controlsRight,
          bottom: RiderMapStyles.controlsBottom(
            navigationActive: navigationActive,
          ),
          child: RiderMapControls(
            mapController: mapController,
            onRecenter: onRecenter,
          ),
        ),
        if (navigationActive)
          Positioned(
            left: 12,
            right: 12,
            bottom: RiderMapStyles.routePanelBottom,
            child: RiderRoutePanel(
              controller: routeController,
              requests: requests,
              location: location,
              locationController: controller,
              showRequestPicker: false,
              onExitNavigation: onExitNavigation,
            ),
          ),
      ],
    );
  }
}
