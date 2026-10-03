import 'package:latlong2/latlong.dart';
import 'package:agresell_app/features/shared/tracking/domain/delivery_tracking_models.dart';

LatLng deliveryMapCenter(DeliveryTrackingSnapshot snapshot) =>
    snapshot.riderLatLng ??
    snapshot.destination?.latLng ??
    snapshot.pickup?.latLng ??
    const LatLng(8.48, 124.65);

/// Prefer the rider and stops; use route geometry only when none are available.
List<LatLng> deliveryMapFitPoints(DeliveryTrackingSnapshot snapshot) {
  final points = <LatLng>[
    if (snapshot.riderLatLng != null) snapshot.riderLatLng!,
    if (snapshot.pickup != null) snapshot.pickup!.latLng,
    if (snapshot.destination != null) snapshot.destination!.latLng,
  ];
  if (points.isEmpty && snapshot.routeCoordinates.isNotEmpty) {
    points.addAll(snapshot.routeCoordinates);
  }
  return points;
}
