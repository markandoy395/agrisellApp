import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_live_map_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_icon_marker.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_types.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_opportunity_markers_builder.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';

/// Constructs markers for assigned orders, opportunities, farms, and rider location.
class RiderMapMarkerBuilder {
  const RiderMapMarkerBuilder({
    required this.riderPoint,
    required this.requests,
    required this.farms,
    required this.riderId,
    required this.filter,
    required this.mapZoom,
    required this.discoveryRadiusKm,
    required this.mapController,
    required this.onMarkerTap,
    required this.onFarmTap,
  });

  static const double nearbyFilterRadiusKm = 5.0;
  static const double riderMarkerCollisionRadiusKm = 0.2;
  static const int maximumOpportunityMarkers = 30;

  final DeliveryRoutePoint riderPoint;
  final List<DeliveryRequest> requests;
  final List<RiderNearbyFarm> farms;
  final String? riderId;
  final RiderMapFilter filter;
  final double mapZoom;
  final double discoveryRadiusKm;
  final MapController mapController;
  final RiderMapMarkerCallback onMarkerTap;
  final ValueChanged<RiderNearbyFarm> onFarmTap;

  List<Marker> buildMarkers(LatLng displayedRiderPoint) {
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
        .take(maximumOpportunityMarkers)
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
      if (showDeliveries)
        ...RiderOpportunityMarkersBuilder.build(
          opportunities: opportunities,
          mapZoom: mapZoom,
          mapController: mapController,
          filter: filter,
          onMarkerTap: onMarkerTap,
        ),
      if (showFarmers) ..._farmerMarkers(),
      if (showAssigned)
        for (final request in assigned)
          if (_destination(request).hasCoordinates)
            Marker(
              point: LatLng(
                _destination(request).latitude!,
                _destination(request).longitude!,
              ),
              width: RiderLiveMapStyles.prominentMarkerExtent,
              height: RiderLiveMapStyles.prominentMarkerExtent,
              child: RiderMapIconMarker(
                icon: RiderMapFilter.assigned.icon,
                label: request.stage.isDeliveryLeg
                    ? 'Assigned delivery destination'
                    : 'Assigned pickup: ${request.sellerName}',
                prominent: true,
                tapExtent: RiderLiveMapStyles.prominentMarkerExtent,
                onTap: () =>
                    onMarkerTap(request, RiderMapMarkerKind.assignedDelivery),
              ),
            ),
      Marker(
        point: displayedRiderPoint,
        width: RiderLiveMapStyles.prominentMarkerExtent,
        height: RiderLiveMapStyles.prominentMarkerExtent,
        child: const RiderMapIconMarker(
          icon: Icons.navigation_rounded,
          label: 'Your current location',
          prominent: true,
        ),
      ),
    ];
  }

  List<Marker> _farmerMarkers() {
    final visible = filter == RiderMapFilter.nearby
        ? farms.where((farm) => farm.distanceKm <= nearbyFilterRadiusKm)
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
      width: _markerExtent(RiderLiveMapStyles.standardMarkerExtent, offset.dx),
      height: _markerExtent(RiderLiveMapStyles.standardMarkerExtent, offset.dy),
      child: RiderMapIconMarker(
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
      riderMarkerCollisionRadiusKm;

  bool _insideSelectedRadius(DeliveryRequest request) {
    final radius =
        (filter == RiderMapFilter.nearby
                ? discoveryRadiusKm.clamp(0.5, nearbyFilterRadiusKm)
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
