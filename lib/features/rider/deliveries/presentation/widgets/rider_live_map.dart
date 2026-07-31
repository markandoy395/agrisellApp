import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/core/theme/agrisellColors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';

class RiderLiveMap extends StatelessWidget {
  const RiderLiveMap({
    required this.riderPoint,
    required this.routes,
    required this.activeRoute,
    required this.requests,
    required this.mapController,
    required this.riderId,
    required this.onMapReady,
    required this.onPositionChanged,
    super.key,
  });

  final DeliveryRoutePoint riderPoint;
  final List<RiderRoutePlan> routes;
  final RiderRoutePlan? activeRoute;
  final List<DeliveryRequest> requests;
  final MapController mapController;
  final String? riderId;
  final VoidCallback onMapReady;
  final PositionCallback onPositionChanged;

  @override
  Widget build(BuildContext context) {
    final displayedRiderPoint = LatLng(
      riderPoint.latitude,
      riderPoint.longitude,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: displayedRiderPoint,
          initialZoom: 15,
          onMapReady: onMapReady,
          onPositionChanged: onPositionChanged,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.agresell.agresell_app',
          ),
          if (routes.any((route) => route.points.length > 1))
            PolylineLayer(
              polylines: [
                for (final route in routes.reversed)
                  if (route.points.length > 1)
                    Polyline(
                      points: [
                        for (final point in route.points)
                          LatLng(point.latitude, point.longitude),
                      ],
                      color: identical(route, activeRoute)
                          ? AgrisellColors.authGreen.withValues(alpha: 0.88)
                          : AgrisellColors.mutedText.withValues(alpha: 0.42),
                      strokeWidth: identical(route, activeRoute) ? 5 : 3,
                    ),
              ],
            ),
          MarkerLayer(
            markers: [
              Marker(
                point: displayedRiderPoint,
                width: 44,
                height: 44,
                child: const _MapMarker(
                  icon: Icons.delivery_dining_rounded,
                  color: AgrisellColors.authGreen,
                  label: 'Rider current road position',
                ),
              ),
              ..._deliveryMarkers(),
            ],
          ),
          const SimpleAttributionWidget(
            source: Text('OpenStreetMap contributors'),
          ),
        ],
      ),
    );
  }

  List<Marker> _deliveryMarkers() {
    final selectedId = activeRoute?.requestId;
    final visible = selectedId == null
        ? requests
              .where((request) => request.stage == DeliveryStage.readyForPickup)
              .take(15)
        : requests.where((request) => request.id == selectedId);
    return [
      for (final request in visible)
        if (request.pickupLocation.hasCoordinates)
          Marker(
            point: LatLng(
              request.pickupLocation.latitude!,
              request.pickupLocation.longitude!,
            ),
            width: 42,
            height: 42,
            child: _MapMarker(
              icon: Icons.storefront_rounded,
              color: request.id == selectedId
                  ? AgrisellColors.statusOrangeText
                  : AgrisellColors.mutedText,
              label: 'Pickup: ${request.pickupLocation.address}',
            ),
          ),
      for (final request in visible)
        if (riderId != null &&
            request.isAssignedTo(riderId!) &&
            request.stage.isDeliveryLeg &&
            request.deliveryLocation.hasCoordinates)
          Marker(
            point: LatLng(
              request.deliveryLocation.latitude!,
              request.deliveryLocation.longitude!,
            ),
            width: 42,
            height: 42,
            child: _MapMarker(
              icon: Icons.location_on_rounded,
              color: AgrisellColors.statusBlueText,
              label: 'Drop-off: ${request.deliveryLocation.address}',
            ),
          ),
    ];
  }
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({
    required this.icon,
    required this.color,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    child: Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: AgrisellColors.surface, width: 2),
        boxShadow: [
          BoxShadow(
            color: AgrisellColors.brandBlack.withValues(alpha: 0.2),
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(icon, color: AgrisellColors.surface, size: 21),
    ),
  );
}
