import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_nearby_farm.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_road_access.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_geometry.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_route_plan.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/rider_map_camera_policy.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_map_types.dart';

abstract final class RiderMapRoadAccessResolver {
  static const minimumRoadAccessGuideMeters = 4.0;
  static const maximumRoadAccessGuideMeters = 1000.0;
  static const roadAccessReuseMovementMeters = 50.0;
  static const roadAccessConcurrency = 4;

  static bool isUsefulGuideDistance(double distance) =>
      distance.isFinite &&
      distance >= minimumRoadAccessGuideMeters &&
      distance <= maximumRoadAccessGuideMeters;

  static RiderRoadAccessSource? sourceForRequest(
    DeliveryRequest request,
    RiderMapMarkerKind markerKind,
  ) {
    final isBuyerDestination =
        markerKind == RiderMapMarkerKind.assignedDelivery &&
        request.stage.isDeliveryLeg;
    final destination = isBuyerDestination
        ? request.deliveryLocation
        : request.pickupLocation;
    if (!destination.hasCoordinates ||
        !RiderMapCameraPolicy.isCoordinateValid(
          destination.latitude!,
          destination.longitude!,
        )) {
      return null;
    }
    return RiderRoadAccessSource(
      id: '${isBuyerDestination ? 'buyer' : 'delivery'}:${request.id}',
      kind: isBuyerDestination
          ? RiderRoadAccessKind.buyer
          : RiderRoadAccessKind.delivery,
      point: DeliveryRoutePoint(
        latitude: destination.latitude!,
        longitude: destination.longitude!,
      ),
      label: isBuyerDestination
          ? 'Assigned delivery destination'
          : request.pickupLocation.address,
      routeRequestId: request.id,
    );
  }

  static RiderRoadAccessSource? sourceForFarm(RiderNearbyFarm farm) {
    if (!RiderMapCameraPolicy.isCoordinateValid(
      farm.latitude,
      farm.longitude,
    )) {
      return null;
    }
    return RiderRoadAccessSource(
      id: 'farm:${farm.id}',
      kind: RiderRoadAccessKind.farmer,
      point: DeliveryRoutePoint(
        latitude: farm.latitude,
        longitude: farm.longitude,
      ),
      label: farm.name,
      routeRequestId: 'farm:${farm.id}',
    );
  }

  static RiderRoadAccessSnap? activeRouteSnap(
    RiderRoadAccessSource source,
    RiderRoutePlan? route,
  ) {
    if (route == null) return null;
    if (source.kind == RiderRoadAccessKind.rider) {
      return RiderRoadAccessSnap(
        point: route.snappedOrigin,
        roadName: route.originRoadName,
        distanceMeters: routePointDistanceMeters(
          source.point,
          route.snappedOrigin,
        ),
      );
    }
    if (source.routeRequestId != route.requestId) return null;
    return RiderRoadAccessSnap(
      point: route.snappedDestination,
      roadName: route.destinationRoadName,
      distanceMeters: routePointDistanceMeters(
        source.point,
        route.snappedDestination,
      ),
    );
  }

  static RiderRoadAccessConnection? connectionFromSnap(
    RiderRoadAccessSource source,
    RiderRoadAccessSnap snap,
  ) {
    final distance = snap.distanceMeters.isFinite
        ? snap.distanceMeters
        : routePointDistanceMeters(source.point, snap.point);
    if (!isUsefulGuideDistance(distance) ||
        !RiderMapCameraPolicy.isCoordinateValid(
          snap.point.latitude,
          snap.point.longitude,
        )) {
      return null;
    }
    return RiderRoadAccessConnection(
      id: source.id,
      kind: source.kind,
      sourcePoint: source.point,
      roadPoint: snap.point,
      sourceLabel: source.label,
      roadName: snap.roadName,
      distanceMeters: distance,
    );
  }
}
