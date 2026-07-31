part of 'rider_delivery_controller.dart';

extension RiderDeliveryControllerActions on RiderDeliveryController {
  Future<DeliveryAcceptanceOutcome> accept({
    required String requestId,
    required String riderId,
  }) {
    final current = _acceptanceOperations[requestId];
    if (current != null) return current;
    late final Future<DeliveryAcceptanceOutcome> operation;
    operation = _acceptOnce(requestId: requestId, riderId: riderId)
        .whenComplete(() {
          if (identical(_acceptanceOperations[requestId], operation)) {
            _acceptanceOperations.remove(requestId);
            _notify();
          }
        });
    _acceptanceOperations[requestId] = operation;
    _notify();
    return operation;
  }

  Future<DeliveryAcceptanceOutcome> _acceptOnce({
    required String requestId,
    required String riderId,
  }) async {
    if (!canReceiveAdditionalDelivery ||
        (_riderId != null && _riderId != riderId)) {
      final failure =
          _status.verificationStatus != RiderVerificationStatus.verified ||
              (_riderId != null && _riderId != riderId)
          ? DeliveryAcceptanceFailure.riderNotAllowed
          : !_isBackendReachable ||
                _status.availability == RiderAvailability.offline
          ? DeliveryAcceptanceFailure.riderOffline
          : !_requestAccess.canAcceptRequests
          ? DeliveryAcceptanceFailure.locationUnacceptable
          : activeDeliveryRequests.length >=
                (_profile?.maximumActiveDeliveries ?? 1)
          ? DeliveryAcceptanceFailure.activeDeliveryLimit
          : DeliveryAcceptanceFailure.riderUnavailable;
      return DeliveryAcceptanceOutcome.failure(failure, failure.userMessage);
    }
    final idempotencyKey = _acceptanceKeys.putIfAbsent(
      requestId,
      _newAcceptanceKey,
    );
    try {
      final receipt = await _repository
          .acceptDelivery(
            DeliveryAcceptanceCommand(
              requestId: requestId,
              riderId: riderId,
              idempotencyKey: idempotencyKey,
            ),
          )
          .timeout(_acceptanceTimeout);
      _acceptanceKeys.remove(requestId);
      final statuses = await _repository.fetchActiveDeliveryStatuses(riderId);
      for (final snapshot in statuses) {
        _activeDeliveries.update(snapshot);
      }
      final status = statuses
          .where((item) => item.request.id == receipt.request.id)
          .firstOrNull;
      _activeDeliveries.accept(
        receipt.activeDelivery,
        status: status?.currentStatus ?? receipt.request.stage.canonicalStatus,
        events: status?.events ?? const [],
      );
      await _replace(receipt.request, riderId: riderId);
      return DeliveryAcceptanceOutcome.success(receipt);
    } on TimeoutException {
      return _acceptanceFailure(
        requestId,
        DeliveryAcceptanceFailure.networkTimeout,
      );
    } on DeliveryAcceptanceException catch (error) {
      return _acceptanceFailure(requestId, error.failure);
    } catch (_) {
      return _acceptanceFailure(requestId, DeliveryAcceptanceFailure.unknown);
    }
  }

  DeliveryAcceptanceOutcome _acceptanceFailure(
    String requestId,
    DeliveryAcceptanceFailure failure,
  ) {
    if (!failure.keepsIdempotencyKey) _acceptanceKeys.remove(requestId);
    final riderId = _riderId;
    if (riderId != null) unawaited(load(riderId: riderId));
    return DeliveryAcceptanceOutcome.failure(failure, failure.userMessage);
  }

  String _newAcceptanceKey() {
    const hex = '0123456789abcdef';
    return List<String>.generate(
      32,
      (_) => hex[_secureRandom.nextInt(hex.length)],
      growable: false,
    ).join();
  }

  Future<DeliveryActionResult> decline({
    required String requestId,
    required String riderId,
  }) => _perform(
    riderId: riderId,
    action: () => _repository.decline(requestId: requestId, riderId: riderId),
  );

  Future<DeliveryActionResult> cancel({
    required String requestId,
    required String riderId,
    required String reason,
  }) => _perform(
    riderId: riderId,
    action: () => _repository.cancel(
      requestId: requestId,
      riderId: riderId,
      reason: reason,
    ),
  );

  Future<DeliveryActionResult> advance({
    required String requestId,
    required String riderId,
    required DeliveryStage nextStage,
    DeliveryProof? proof,
  }) => _perform(
    riderId: riderId,
    action: () => _repository.advance(
      requestId: requestId,
      riderId: riderId,
      nextStage: nextStage,
      proof: proof,
    ),
  );

  Future<DeliveryActionResult> _perform({
    required String riderId,
    required Future<DeliveryRequest> Function() action,
  }) async {
    if (!_status.canManageActiveDelivery) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.notEligible,
        message: 'Verification and online availability are required.',
      );
    }
    try {
      final updated = await action();
      await _replace(updated, riderId: riderId);
      return DeliveryActionResult.success(updated);
    } on DeliveryDomainException catch (error) {
      return DeliveryActionResult.failure(
        failure: _legacyFailureFor(error.code),
        message: error.message,
      );
    } catch (_) {
      return const DeliveryActionResult.failure(
        failure: DeliveryActionFailure.unknown,
        message: 'The delivery update could not be completed.',
      );
    }
  }

  Future<void> _replace(
    DeliveryRequest request, {
    required String riderId,
  }) async {
    final found = _requests.any((item) => item.id == request.id);
    final updated = <DeliveryRequest>[
      for (final item in _requests)
        if (item.id == request.id) request else item,
      if (!found) request,
    ];
    _requests = sortRiderDeliveryRequests(
      updated.where((item) => item.isVisibleTo(riderId)).toList(),
    );
    if (request.stage.isTerminal) _activeDeliveries.remove(request.id);
    final remaining = _requests.where(
      (item) => item.isAssignedTo(riderId) && !item.stage.isTerminal,
    );
    final availabilityStage = remaining.firstOrNull?.stage ?? request.stage;
    _status = _status.copyWith(
      availability: riderAvailabilityForDeliveryStage(
        availabilityStage,
        _status.availability,
      ),
    );
    _notify();
    await _persistState();
  }
}
