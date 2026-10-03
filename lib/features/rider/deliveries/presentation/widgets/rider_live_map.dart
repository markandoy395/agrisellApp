import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_live_map_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_marker_builder.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_polyline_builder.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_types.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';

export 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_types.dart';

/// Interactive FlutterMap view for rider routing, deliveries, and nearby farms.
class RiderLiveMap extends StatelessWidget {
  const RiderLiveMap({
    required this.riderPoint,
    required this.routes,
    required this.activeRoute,
    required this.requests,
    required this.farms,
    required this.roadAccessConnections,
    required this.mapController,
    required this.riderId,
    required this.filter,
    required this.mapZoom,
    required this.discoveryRadiusKm,
    required this.onMarkerTap,
    required this.onFarmTap,
    required this.onMapReady,
    required this.onPositionChanged,
    super.key,
  });

  final DeliveryRoutePoint riderPoint;
  final List<RiderRoutePlan> routes;
  final RiderRoutePlan? activeRoute;
  final List<DeliveryRequest> requests;
  final List<RiderNearbyFarm> farms;
  final List<RiderRoadAccessConnection> roadAccessConnections;
  final MapController mapController;
  final String? riderId;
  final RiderMapFilter filter;
  final double mapZoom;
  final double discoveryRadiusKm;
  final RiderMapMarkerCallback onMarkerTap;
  final ValueChanged<RiderNearbyFarm> onFarmTap;
  final VoidCallback onMapReady;
  final PositionCallback onPositionChanged;

  @override
  Widget build(BuildContext context) {
    final displayedRiderPoint = LatLng(
      riderPoint.latitude,
      riderPoint.longitude,
    );

    final roadAccessLayer = RiderMapPolylineBuilder.buildRoadAccessLayer(
      connections: roadAccessConnections,
      filter: filter,
    );

    final routesLayer = RiderMapPolylineBuilder.buildRoutesLayer(
      routes: routes,
      activeRoute: activeRoute,
    );

    final markerBuilder = RiderMapMarkerBuilder(
      riderPoint: riderPoint,
      requests: requests,
      farms: farms,
      riderId: riderId,
      filter: filter,
      mapZoom: mapZoom,
      discoveryRadiusKm: discoveryRadiusKm,
      mapController: mapController,
      onMarkerTap: onMarkerTap,
      onFarmTap: onFarmTap,
    );

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: displayedRiderPoint,
        initialZoom: RiderLiveMapStyles.initialZoom,
        minZoom: RiderLiveMapStyles.minZoom,
        maxZoom: RiderLiveMapStyles.maxZoom,
        onMapReady: onMapReady,
        onPositionChanged: onPositionChanged,
      ),
      children: [
        TileLayer(
          urlTemplate: RiderLiveMapStyles.osmTileUrl,
          userAgentPackageName: RiderLiveMapStyles.osmUserAgent,
        ),
        if (roadAccessLayer != null) roadAccessLayer,
        if (routesLayer != null) routesLayer,
        MarkerLayer(markers: markerBuilder.buildMarkers(displayedRiderPoint)),
        const RichAttributionWidget(
          attributions: [
            TextSourceAttribution(RiderLiveMapStyles.osmAttribution),
          ],
        ),
      ],
    );
  }
}
