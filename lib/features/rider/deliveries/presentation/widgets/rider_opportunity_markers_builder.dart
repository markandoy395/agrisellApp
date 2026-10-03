import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_live_map_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_cluster_marker.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_icon_marker.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_types.dart';

/// Builds opportunity delivery markers and cluster markers depending on zoom level.
abstract final class RiderOpportunityMarkersBuilder {
  static List<Marker> build({
    required List<DeliveryRequest> opportunities,
    required double mapZoom,
    required MapController mapController,
    required RiderMapFilter filter,
    required RiderMapMarkerCallback onMarkerTap,
  }) {
    if (mapZoom >= 13 || opportunities.length < 10) {
      return [
        for (final request in opportunities)
          buildSingleMarker(
            request: request,
            filter: filter,
            onMarkerTap: onMarkerTap,
          ),
      ];
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
          buildSingleMarker(
            request: group.single,
            filter: filter,
            onMarkerTap: onMarkerTap,
          )
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
            width: RiderLiveMapStyles.clusterMarkerExtent,
            height: RiderLiveMapStyles.clusterMarkerExtent,
            child: RiderMapClusterMarker(
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

  static Marker buildSingleMarker({
    required DeliveryRequest request,
    required RiderMapFilter filter,
    required RiderMapMarkerCallback onMarkerTap,
  }) {
    final offset =
        filter == RiderMapFilter.all ? const Offset(-10, 0) : Offset.zero;
    final width = RiderLiveMapStyles.standardMarkerExtent + (offset.dx.abs() * 2);

    return Marker(
      point: LatLng(
        request.pickupLocation.latitude!,
        request.pickupLocation.longitude!,
      ),
      width: width,
      height: RiderLiveMapStyles.standardMarkerExtent,
      child: RiderMapIconMarker(
        icon: RiderMapFilter.deliveries.icon,
        label: 'Available pickup: ${request.productName}',
        offset: offset,
        onTap: () => onMarkerTap(request, RiderMapMarkerKind.availableDelivery),
      ),
    );
  }
}
