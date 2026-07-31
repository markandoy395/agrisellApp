part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerRequestMatching on RiderDeliveryController {
  bool get usesRegisteredLocationEstimate =>
      _requestAccess.usesRegisteredLocationEstimate;

  double? pickupDistanceKmFor(DeliveryRequest request) =>
      _matchingContextOrNull()?.pickupDistanceKm(request) ??
      request.routeDistanceKm;

  int? pickupTravelMinutesFor(DeliveryRequest request) =>
      _matchingContextOrNull()?.pickupTravelMinutes(request) ??
      request.routeEstimatedTravelMinutes;

  bool isPickupInsideRegisteredServiceArea(DeliveryRequest request) {
    final matching = _matchingContextOrNull();
    if (matching == null) return false;
    final area = matching.registeredServiceArea;
    return area.matchesArea(request.serviceArea) &&
        area.containsPickup(request.pickupLocation);
  }

  RiderRequestQuery _buildQuery({String? cursor}) => RiderRequestQuery(
    matching: _matchingContext(),
    searchText: _searchText,
    sort: _requestSort,
    filters: _requestFilters,
    cursor: cursor,
  );

  RiderMatchingContext _matchingContext() {
    final context = _matchingContextOrNull();
    if (context == null) {
      throw StateError('An authenticated Rider profile is required.');
    }
    return context;
  }

  RiderMatchingContext? _matchingContextOrNull() {
    final profile = _profile;
    final riderId = _riderId;
    if (profile == null || riderId == null) return null;
    final activeCount = _requests
        .where(
          (request) =>
              request.isAssignedTo(riderId) && !request.stage.isTerminal,
        )
        .length;
    return RiderMatchingContext(
      riderId: riderId,
      availability: _status.availability,
      vehicleType: profile.vehicleType,
      capacityKg: profile.capacityKg,
      serviceArea: profile.serviceArea,
      serviceRadiusKm: profile.serviceRadiusKm,
      registeredLatitude: profile.gpsLatitude,
      registeredLongitude: profile.gpsLongitude,
      location: _search,
      gpsAccuracyMeters: _requestAccuracyMeters,
      allowRegisteredLocationEstimate:
          _requestAccess.usesRegisteredLocationEstimate,
      activeDeliveryCount: activeCount,
      maximumActiveDeliveries: profile.maximumActiveDeliveries,
      handlingCapabilityKeys: profile.handlingCapabilityKeys,
    );
  }
}
