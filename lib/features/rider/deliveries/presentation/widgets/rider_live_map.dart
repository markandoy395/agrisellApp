import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';

enum RiderMapFilter { all, deliveries, farmers, assigned, nearby }

extension RiderMapFilterDetails on RiderMapFilter {
  String get label => switch (this) {
    RiderMapFilter.all => 'All',
    RiderMapFilter.deliveries => 'Deliveries',
    RiderMapFilter.farmers => 'Farmers',
    RiderMapFilter.assigned => 'Assigned',
    RiderMapFilter.nearby => 'Nearby',
  };

  IconData get icon => switch (this) {
    RiderMapFilter.all => Icons.layers_rounded,
    RiderMapFilter.deliveries => Icons.inventory_2_rounded,
    RiderMapFilter.farmers => Icons.agriculture_rounded,
    RiderMapFilter.assigned => Icons.local_shipping_rounded,
    RiderMapFilter.nearby => Icons.navigation_rounded,
  };
}

enum RiderMapMarkerKind { availableDelivery, farmer, assignedDelivery }

typedef RiderMapMarkerCallback =
    void Function(DeliveryRequest request, RiderMapMarkerKind kind);

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

  static const _nearbyFilterRadiusKm = 5.0;
  static const _riderMarkerCollisionRadiusKm = 0.2;
  static const _maximumOpportunityMarkers = 30;

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
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: displayedRiderPoint,
        initialZoom: 15,
        minZoom: 4,
        maxZoom: 19,
        onMapReady: onMapReady,
        onPositionChanged: onPositionChanged,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.agrisell.agresell_app',
        ),
        if (roadAccessConnections.isNotEmpty)
          PolylineLayer(
            polylines: [
              for (final connection in roadAccessConnections)
                if (_showRoadAccessConnection(connection))
                  Polyline(
                    points: [
                      LatLng(
                        connection.sourcePoint.latitude,
                        connection.sourcePoint.longitude,
                      ),
                      LatLng(
                        connection.roadPoint.latitude,
                        connection.roadPoint.longitude,
                      ),
                    ],
                    color: AgrisellColors.mutedText.withValues(alpha: 0.78),
                    strokeWidth: 2.2,
                    pattern: StrokePattern.dashed(segments: const [5, 5]),
                  ),
            ],
          ),
        if (routes.any((route) => route.points.length > 1))
          PolylineLayer(
            polylines: [
              for (final route in routes.reversed)
                if (route.points
                        .where(
                          (point) => RiderMapCameraPolicy.isCoordinateValid(
                            point.latitude,
                            point.longitude,
                          ),
                        )
                        .length >
                    1)
                  Polyline(
                    points: [
                      for (final point in route.points)
                        if (RiderMapCameraPolicy.isCoordinateValid(
                          point.latitude,
                          point.longitude,
                        ))
                          LatLng(point.latitude, point.longitude),
                    ],
                    color: identical(route, activeRoute)
                        ? AgrisellColors.authGreen.withValues(alpha: 0.92)
                        : AgrisellColors.mutedText.withValues(alpha: 0.32),
                    strokeWidth: identical(route, activeRoute) ? 6 : 3,
                  ),
            ],
          ),
        MarkerLayer(markers: _markers(displayedRiderPoint)),
        const RichAttributionWidget(
          attributions: [TextSourceAttribution('OpenStreetMap contributors')],
        ),
      ],
    );
  }

  List<Marker> _markers(LatLng displayedRiderPoint) {
    final assigned = requests
        .where(
          (request) =>
              riderId != null &&
              request.isAssignedTo(riderId!) &&
              !request.stage.isTerminal,
        )
        .toList(growable: false);
    final opportunities = requests
        .where(
          (request) =>
              request.stage == DeliveryStage.readyForPickup &&
              request.assignedRiderId == null &&
              request.pickupLocation.hasCoordinates &&
              _insideSelectedRadius(request),
        )
        .take(_maximumOpportunityMarkers)
        .toList(growable: false);
    final showAssigned =
        filter == RiderMapFilter.all ||
        filter == RiderMapFilter.assigned ||
        filter == RiderMapFilter.nearby;
    final showDeliveries =
        filter == RiderMapFilter.all ||
        filter == RiderMapFilter.deliveries ||
        filter == RiderMapFilter.nearby;
    final showFarmers =
        filter == RiderMapFilter.all ||
        filter == RiderMapFilter.farmers ||
        filter == RiderMapFilter.nearby;
    return [
      if (showDeliveries) ..._opportunityMarkers(opportunities),
      if (showFarmers) ..._farmerMarkers(),
      if (showAssigned)
        for (final request in assigned)
          if (_destination(request).hasCoordinates)
            Marker(
              point: LatLng(
                _destination(request).latitude!,
                _destination(request).longitude!,
              ),
              width: 60,
              height: 60,
              child: _MapMarker(
                icon: RiderMapFilter.assigned.icon,
                label: request.stage.isDeliveryLeg
                    ? 'Assigned delivery destination'
                    : 'Assigned pickup: ${request.sellerName}',
                prominent: true,
                tapExtent: 60,
                onTap: () =>
                    onMarkerTap(request, RiderMapMarkerKind.assignedDelivery),
              ),
            ),
      Marker(
        point: displayedRiderPoint,
        width: 60,
        height: 60,
        child: const _MapMarker(
          icon: Icons.navigation_rounded,
          label: 'Your current location',
          prominent: true,
        ),
      ),
    ];
  }

  bool _showRoadAccessConnection(RiderRoadAccessConnection connection) =>
      switch (connection.kind) {
        RiderRoadAccessKind.rider => true,
        RiderRoadAccessKind.farmer =>
          filter == RiderMapFilter.all ||
              filter == RiderMapFilter.farmers ||
              filter == RiderMapFilter.nearby,
        RiderRoadAccessKind.delivery =>
          filter == RiderMapFilter.all ||
              filter == RiderMapFilter.deliveries ||
              filter == RiderMapFilter.assigned ||
              filter == RiderMapFilter.nearby,
        RiderRoadAccessKind.buyer =>
          filter == RiderMapFilter.all ||
              filter == RiderMapFilter.assigned ||
              filter == RiderMapFilter.nearby,
      };

  List<Marker> _opportunityMarkers(List<DeliveryRequest> opportunities) {
    if (mapZoom >= 13 || opportunities.length < 10) {
      return [for (final request in opportunities) _opportunityMarker(request)];
    }
    final groups = <String, List<DeliveryRequest>>{};
    for (final request in opportunities) {
      final latitude = request.pickupLocation.latitude!;
      final longitude = request.pickupLocation.longitude!;
      final key = '${(latitude * 50).round()}:${(longitude * 50).round()}';
      groups.putIfAbsent(key, () => []).add(request);
    }
    return [
      for (final group in groups.values)
        if (group.length == 1)
          _opportunityMarker(group.single)
        else
          Marker(
            point: LatLng(
              group
                      .map((item) => item.pickupLocation.latitude!)
                      .reduce((a, b) => a + b) /
                  group.length,
              group
                      .map((item) => item.pickupLocation.longitude!)
                      .reduce((a, b) => a + b) /
                  group.length,
            ),
            width: 48,
            height: 48,
            child: _ClusterMarker(
              count: group.length,
              onTap: () {
                final camera = mapController.camera;
                if (!RiderMapCameraPolicy.canMoveCamera(camera)) return;
                mapController.move(
                  LatLng(
                    group.first.pickupLocation.latitude!,
                    group.first.pickupLocation.longitude!,
                  ),
                  RiderMapCameraPolicy.safeZoom(mapZoom + 2),
                );
              },
            ),
          ),
    ];
  }

  Marker _opportunityMarker(DeliveryRequest request) => Marker(
    point: LatLng(
      request.pickupLocation.latitude!,
      request.pickupLocation.longitude!,
    ),
    width: _markerExtent(56, filter == RiderMapFilter.all ? -10 : 0),
    height: 56,
    child: _MapMarker(
      icon: RiderMapFilter.deliveries.icon,
      label: 'Available pickup: ${request.productName}',
      offset: filter == RiderMapFilter.all ? const Offset(-10, 0) : Offset.zero,
      onTap: () => onMarkerTap(request, RiderMapMarkerKind.availableDelivery),
    ),
  );

  List<Marker> _farmerMarkers() {
    final visible = filter == RiderMapFilter.nearby
        ? farms.where((farm) => farm.distanceKm <= _nearbyFilterRadiusKm)
        : farms;
    return [for (final farm in visible.take(30)) _farmerMarker(farm)];
  }

  Marker _farmerMarker(RiderNearbyFarm farm) {
    final offset = _farmerOverlapsRider(farm)
        ? const Offset(34, 0)
        : filter == RiderMapFilter.all
        ? const Offset(10, 0)
        : Offset.zero;
    return Marker(
      point: LatLng(farm.latitude, farm.longitude),
      width: _markerExtent(56, offset.dx),
      height: _markerExtent(56, offset.dy),
      child: _MapMarker(
        icon: RiderMapFilter.farmers.icon,
        label: 'Farmer pickup: ${farm.name}',
        offset: offset,
        onTap: () => onFarmTap(farm),
      ),
    );
  }

  double _markerExtent(double base, double offset) => base + (offset.abs() * 2);

  bool _farmerOverlapsRider(RiderNearbyFarm farm) =>
      RiderDeliverySearch(
        latitude: riderPoint.latitude,
        longitude: riderPoint.longitude,
      ).distanceTo(latitude: farm.latitude, longitude: farm.longitude) <=
      _riderMarkerCollisionRadiusKm;

  bool _insideSelectedRadius(DeliveryRequest request) {
    final radius =
        (filter == RiderMapFilter.nearby
                ? discoveryRadiusKm.clamp(0.5, _nearbyFilterRadiusKm)
                : discoveryRadiusKm)
            .toDouble();
    return RiderDeliverySearch(
          latitude: riderPoint.latitude,
          longitude: riderPoint.longitude,
          radiusKm: radius,
        ).distanceTo(
          latitude: request.pickupLocation.latitude!,
          longitude: request.pickupLocation.longitude!,
        ) <=
        radius;
  }

  DeliveryLocation _destination(DeliveryRequest request) =>
      request.stage.isDeliveryLeg
      ? request.deliveryLocation
      : request.pickupLocation;
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.icon,
    required this.label,
    this.prominent = false,
    this.offset = Offset.zero,
    this.tapExtent = 56,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final bool prominent;
  final Offset offset;
  final double tapExtent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final visual = SizedBox.square(
      dimension: tapExtent,
      child: Center(
        child: Icon(
          icon,
          color: AgrisellColors.brandBlack,
          size: prominent ? 30 : 25,
        ),
      ),
    );
    final interactive = onTap == null
        ? IgnorePointer(child: visual)
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: visual,
          );
    return Semantics(
      button: onTap != null,
      label: label,
      child: SizedBox.expand(
        child: Stack(
          alignment: Alignment.center,
          children: [Transform.translate(offset: offset, child: interactive)],
        ),
      ),
    );
  }
}

class _ClusterMarker extends StatelessWidget {
  const _ClusterMarker({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$count nearby delivery opportunities. Zoom in.',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: const SizedBox.expand(
        child: Center(
          child: Icon(
            Icons.inventory_2_rounded,
            color: AgrisellColors.brandBlack,
            size: 30,
          ),
        ),
      ),
    ),
  );
}
