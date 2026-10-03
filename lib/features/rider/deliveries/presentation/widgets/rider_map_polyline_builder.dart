import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/styles/rider_live_map_styles.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_types.dart';

/// Builds polyline layers for road access connections and calculated route plans.
abstract final class RiderMapPolylineBuilder {
  static PolylineLayer? buildRoadAccessLayer({
    required List<RiderRoadAccessConnection> connections,
    required RiderMapFilter filter,
  }) {
    if (connections.isEmpty) return null;
    return PolylineLayer(
      polylines: [
        for (final connection in connections)
          if (showRoadAccessConnection(connection, filter))
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
              color: RiderLiveMapStyles.roadAccessColor,
              strokeWidth: RiderLiveMapStyles.roadAccessStrokeWidth,
              pattern: RiderLiveMapStyles.roadAccessPattern,
            ),
      ],
    );
  }

  static bool showRoadAccessConnection(
    RiderRoadAccessConnection connection,
    RiderMapFilter filter,
  ) =>
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

  static PolylineLayer? buildRoutesLayer({
    required List<RiderRoutePlan> routes,
    required RiderRoutePlan? activeRoute,
  }) {
    if (!routes.any((route) => route.points.length > 1)) return null;
    return PolylineLayer(
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
                  ? RiderLiveMapStyles.activeRouteColor
                  : RiderLiveMapStyles.inactiveRouteColor,
              strokeWidth: identical(route, activeRoute)
                  ? RiderLiveMapStyles.activeRouteStrokeWidth
                  : RiderLiveMapStyles.inactiveRouteStrokeWidth,
            ),
      ],
    );
  }
}
