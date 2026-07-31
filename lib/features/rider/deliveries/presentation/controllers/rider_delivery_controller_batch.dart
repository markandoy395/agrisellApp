part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerBatch on RiderDeliveryController {
  List<DeliveryRequest> get activeDeliveryRequests {
    final riderId = _riderId ?? '';
    return _requests
        .where((item) => item.isAssignedTo(riderId) && !item.stage.isTerminal)
        .toList(growable: false);
  }

  bool get canReceiveAdditionalDelivery {
    final profile = _profile;
    if (profile == null ||
        _status.verificationStatus != RiderVerificationStatus.verified ||
        !_isBackendReachable ||
        !_requestAccess.canAcceptRequests) {
      return false;
    }
    final availabilityAllowsBatch =
        _status.availability == RiderAvailability.onlineAvailable ||
        _status.availability.isHandlingDelivery;
    return availabilityAllowsBatch &&
        activeDeliveryRequests.length < profile.maximumActiveDeliveries;
  }

  bool get canPreviewAdditionalDelivery {
    final profile = _profile;
    if (profile == null ||
        _status.verificationStatus != RiderVerificationStatus.verified ||
        !_isBackendReachable ||
        !_requestAccess.canPreviewRequests) {
      return false;
    }
    final availabilityAllowsBatch =
        _status.availability == RiderAvailability.onlineAvailable ||
        _status.availability.isHandlingDelivery;
    return availabilityAllowsBatch &&
        activeDeliveryRequests.length < profile.maximumActiveDeliveries;
  }

  RiderBatchPlan? get batchPlan {
    final active = activeDeliveryRequests;
    if (active.isEmpty) return null;
    return const RiderBatchOptimizer()
        .evaluate(activeDeliveries: active, context: _batchContext())
        .plan;
  }

  RiderBatchEvaluation batchEvaluationFor(DeliveryRequest candidate) =>
      const RiderBatchOptimizer().evaluate(
        activeDeliveries: activeDeliveryRequests,
        candidate: candidate,
        context: _batchContext(),
      );

  List<DeliveryRequest> get routeOrderedRequests {
    final plan = batchPlan;
    if (plan == null) return _requests;
    final byId = {for (final item in _requests) item.id: item};
    final orderedIds = plan.stops.map((stop) => stop.deliveryId).toSet();
    return [
      for (final id in orderedIds)
        if (byId[id] != null) byId[id]!,
      for (final item in _requests)
        if (!orderedIds.contains(item.id)) item,
    ];
  }

  void selectActiveDelivery(String deliveryId) {
    _activeDeliveries.select(deliveryId);
    _notify();
  }

  RiderBatchContext _batchContext() {
    final profile = _profile;
    final location = _currentRiderLocation;
    return RiderBatchContext(
      riderEligible:
          profile?.canAcceptDeliveries == true &&
          (_status.availability == RiderAvailability.onlineAvailable ||
              _status.availability.isHandlingDelivery),
      maximumActiveDeliveries: profile?.maximumActiveDeliveries ?? 1,
      capacityKg: profile?.capacityKg,
      currentLocation: location == null
          ? _search
          : RiderDeliverySearch(
              latitude: location.latitude,
              longitude: location.longitude,
            ),
      handlingCapabilityKeys:
          profile?.handlingCapabilityKeys ?? const <String>{},
      now: DateTime.now(),
    );
  }
}
