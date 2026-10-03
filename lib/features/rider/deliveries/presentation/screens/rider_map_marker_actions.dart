part of 'rider_map_screen.dart';

extension _RiderMapMarkerActions on _RiderMapScreenState {
  Future<void> _openMarker(
    DeliveryRequest request,
    RiderMapMarkerKind kind,
  ) async {
    final location = _locationController.location;
    final riderId = widget.profile?.id;
    final active = riderId == null
        ? null
        : widget.deliveryController.requests
              .where(
                (item) => item.isAssignedTo(riderId) && !item.stage.isTerminal,
              )
              .firstOrNull;
    final blocked =
        riderId != null && active != null && !request.isAssignedTo(riderId);
    final destination =
        kind == RiderMapMarkerKind.assignedDelivery &&
            request.stage.isDeliveryLeg
        ? request.deliveryLocation
        : request.pickupLocation;
    final roadAccessSource = _roadAccessSourceForRequest(request, kind);
    _selectRoadAccessSource(roadAccessSource);
    final shouldNavigate = await showRiderMapMarkerSheet(
      context,
      request: request,
      kind: kind,
      distanceKm: location != null && destination.hasCoordinates
          ? RiderDeliverySearch(
              latitude: location.latitude,
              longitude: location.longitude,
            ).distanceTo(
              latitude: destination.latitude!,
              longitude: destination.longitude!,
            )
          : null,
      travelMinutes:
          kind == RiderMapMarkerKind.assignedDelivery &&
              request.stage.isDeliveryLeg
          ? null
          : widget.deliveryController.pickupTravelMinutesFor(request),
      navigationBlockedByActiveDelivery: blocked,
    );
    if (!mounted) return;
    if (!shouldNavigate) {
      _clearRoadAccessSelection(roadAccessSource?.id);
      return;
    }
    if (riderId == null) {
      _clearRoadAccessSelection(roadAccessSource?.id);
      _showMapMessage('Your rider profile is still loading. Try again.');
      return;
    }

    // Navigation does not accept a job. Refresh first so stale or revoked
    // opportunities cannot be routed from an old marker.
    await widget.deliveryController.refreshRequests();
    if (!mounted) return;
    if (!request.isAssignedTo(riderId) &&
        widget.deliveryController.loadState != RiderRequestLoadState.ready) {
      _showMapMessage(
        'This opportunity could not be revalidated. Check your connection '
        'and try again.',
      );
      _clearRoadAccessSelection(roadAccessSource?.id);
      return;
    }
    final refreshed = widget.deliveryController.requests
        .where((item) => item.id == request.id)
        .firstOrNull;
    if (refreshed == null ||
        (!refreshed.isAssignedTo(riderId) &&
            !refreshed.isAvailableTo(riderId))) {
      _showMapMessage('This delivery is no longer available to you.');
      _clearRoadAccessSelection(roadAccessSource?.id);
      return;
    }
    await _startNavigation(refreshed);
  }
}
