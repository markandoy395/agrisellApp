import 'package:flutter/material.dart';
import '../../domain/rider_map_visibility.dart';
import 'rider_map_attribution.dart';
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
import 'rider_map_poi_markers.dart';
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
    this.visibility = const RiderMapVisibility(),
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
  final RiderMapVisibility visibility;

  @override
  Widget build(BuildContext context) {
    final displayedRiderPoint = LatLng(
      riderPoint.latitude,
      riderPoint.longitude,
    );

    final roadAccessLayer = RiderMapPolylineBuilder.buildRoadAccessLayer(
      connections: roadAccessConnections
          .where(
            (connection) => switch (connection.kind) {
              RiderRoadAccessKind.rider => true,
              RiderRoadAccessKind.farmer => visibility.farms,
              RiderRoadAccessKind.delivery =>
                visibility.pickups || visibility.active,
              RiderRoadAccessKind.buyer => visibility.dropOffs,
            },
          )
          .toList(growable: false),
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
      visibility: visibility,
    );

    final tileUrl = switch (visibility.mapViewType) {
      RiderMapViewType.defaultView => RiderLiveMapStyles.osmTileUrl,
      RiderMapViewType.satellite => RiderLiveMapStyles.satelliteTileUrl,
      RiderMapViewType.terrain => RiderLiveMapStyles.terrainTileUrl,
    };

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
          urlTemplate: tileUrl,
          userAgentPackageName: RiderLiveMapStyles.osmUserAgent,
        ),
        if (roadAccessLayer != null) roadAccessLayer,
        if (routesLayer != null) routesLayer,
        MarkerLayer(
          markers: [
            ...markerBuilder.buildMarkers(displayedRiderPoint),
            ...RiderMapPoiMarkers.build(
              center: displayedRiderPoint,
              visible: visibility.pointsOfInterest,
            ),
          ],
        ),
        const RiderMapAttribution(),
      ],
    );
  }
}
