import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/shared/routing/domain/delivery_route.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';

DeliveryRequest? selectRiderRouteTarget(
  List<DeliveryRequest> requests,
  String? selectedRequestId,
) {
  for (final request in requests) {
    if (request.stage != DeliveryStage.readyForPickup &&
        !request.stage.isTerminal) {
      return request;
    }
  }
  if (selectedRequestId != null) {
    for (final request in requests) {
      if (request.id == selectedRequestId && !request.stage.isTerminal) {
        return request;
      }
    }
  }
  return requests
      .where(
        (request) =>
            request.stage == DeliveryStage.readyForPickup &&
            request.pickupLocation.hasCoordinates,
      )
      .firstOrNull;
}

bool riderRouteUsesDeliveryLocation(DeliveryRequest request) =>
    request.stage.isDeliveryLeg;

DeliveryRoutePoint? riderRouteDestination(DeliveryRequest request) {
  final location = riderRouteUsesDeliveryLocation(request)
      ? request.deliveryLocation
      : request.pickupLocation;
  if (!location.hasCoordinates) return null;
  return DeliveryRoutePoint(
    latitude: location.latitude!,
    longitude: location.longitude!,
  );
}
