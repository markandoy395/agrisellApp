import 'package:agresell_app/features/rider/deliveries/domain/delivery_route.dart';

enum RiderRoadAccessKind { rider, farmer, delivery, buyer }

class RiderRoadAccessSource {
  const RiderRoadAccessSource({
    required this.id,
    required this.kind,
    required this.point,
    required this.label,
    this.routeRequestId,
  });

  final String id;
  final RiderRoadAccessKind kind;
  final DeliveryRoutePoint point;
  final String label;
  final String? routeRequestId;
}

class RiderRoadAccessSnap {
  const RiderRoadAccessSnap({
    required this.point,
    required this.roadName,
    required this.distanceMeters,
  });

  final DeliveryRoutePoint point;
  final String roadName;
  final double distanceMeters;
}

class RiderRoadAccessConnection {
  const RiderRoadAccessConnection({
    required this.id,
    required this.kind,
    required this.sourcePoint,
    required this.roadPoint,
    required this.sourceLabel,
    required this.roadName,
    required this.distanceMeters,
  });

  final String id;
  final RiderRoadAccessKind kind;
  final DeliveryRoutePoint sourcePoint;
  final DeliveryRoutePoint roadPoint;
  final String sourceLabel;
  final String roadName;
  final double distanceMeters;

  RiderRoadAccessConnection withSourcePoint(DeliveryRoutePoint point) =>
      RiderRoadAccessConnection(
        id: id,
        kind: kind,
        sourcePoint: point,
        roadPoint: roadPoint,
        sourceLabel: sourceLabel,
        roadName: roadName,
        distanceMeters: distanceMeters,
      );
}
