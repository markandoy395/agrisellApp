part of 'rider_delivery_repository.dart';

extension _InMemoryRiderAcceptance on InMemoryRiderDeliveryRepository {
  Future<DeliveryAcceptanceReceipt> _acceptDelivery(
    DeliveryAcceptanceCommand command,
  ) async {
    final result = await _inAcceptanceTransaction(
      () => _acceptInsideTransaction(command),
    );
    if (result.changed) _changes.add(null);
    return result.receipt;
  }

  Future<_AcceptanceCommit> _acceptInsideTransaction(
    DeliveryAcceptanceCommand command,
  ) async {
    final riderId = command.riderId.trim();
    final requestId = command.requestId.trim();
    final key = command.idempotencyKey.trim();
    if (riderId.isEmpty) {
      throw const DeliveryAcceptanceException(
        DeliveryAcceptanceFailure.riderNotAllowed,
      );
    }
    if (requestId.isEmpty) {
      throw const DeliveryAcceptanceException(
        DeliveryAcceptanceFailure.requestNotFound,
      );
    }
    if (key.isEmpty) {
      throw const DeliveryAcceptanceException(
        DeliveryAcceptanceFailure.transactionConflict,
      );
    }
    final idempotencyId = '$riderId|$key';
    final replay = _idempotencyReceipts[idempotencyId];
    if (replay != null) {
      if (replay.requestId != requestId) {
        throw const DeliveryAcceptanceException(
          DeliveryAcceptanceFailure.transactionConflict,
        );
      }
      return _AcceptanceCommit(replay.receipt.asReplay(), false);
    }
    final request = _requests[requestId];
    if (request == null) {
      throw const DeliveryAcceptanceException(
        DeliveryAcceptanceFailure.requestNotFound,
      );
    }
    final existing = _existingRiderAssignment(request, riderId, idempotencyId);
    if (existing != null) return existing;
    final failure = validateDeliveryAcceptance(
      request: request,
      rider: _riderStates[riderId],
      now: _clock(),
    );
    if (failure != null) throw DeliveryAcceptanceException(failure);
    _validateBatchAcceptance(request, _riderStates[riderId]!);
    try {
      await _beforeAcceptanceCommit?.call();
    } on DeliveryAcceptanceException {
      rethrow;
    } catch (_) {
      throw const DeliveryAcceptanceException(
        DeliveryAcceptanceFailure.transactionFailed,
      );
    }
    final acceptedAt = _clock();
    final accepted = request.copyWith(
      stage: DeliveryStage.accepted,
      assignedRiderId: riderId,
    );
    final active = ActiveDeliveryRecord(
      id: 'active-$requestId-${++_assignmentSequence}',
      requestId: requestId,
      riderId: riderId,
      acceptedAt: acceptedAt,
      estimatedEarning: request.deliveryFee,
    );
    final receipt = DeliveryAcceptanceReceipt(
      request: accepted,
      activeDelivery: active,
      riderAvailability: RiderAvailability.deliveryReserved,
    );
    _requests[requestId] = accepted;
    _statusSnapshots[requestId] = DeliveryStatusSnapshot(
      request: accepted,
      currentStatus: DeliveryStatus.accepted,
      events: [
        DeliveryStatusEvent(
          eventId: 'status-$requestId-1',
          deliveryId: requestId,
          previousStatus: DeliveryStatus.reserved,
          newStatus: DeliveryStatus.accepted,
          riderId: riderId,
          timestamp: acceptedAt,
          source: DeliveryEventSource.online,
          syncStatus: DeliveryEventSyncStatus.synchronized,
        ),
      ],
    );
    _activeDeliveries.putIfAbsent(riderId, () => {})[requestId] = active;
    _activeByRequest[requestId] = active;
    _riderStates[riderId] = _riderStates[riderId]!.reserve(requestId);
    _idempotencyReceipts[idempotencyId] = _IdempotencyRecord(
      requestId,
      receipt,
    );
    return _AcceptanceCommit(receipt, true);
  }

  _AcceptanceCommit? _existingRiderAssignment(
    DeliveryRequest request,
    String riderId,
    String idempotencyId,
  ) {
    if (!request.isAssignedTo(riderId)) return null;
    final active = _activeByRequest[request.id];
    if (active == null) {
      throw const DeliveryAcceptanceException(
        DeliveryAcceptanceFailure.serverError,
      );
    }
    final receipt = DeliveryAcceptanceReceipt(
      request: request,
      activeDelivery: active,
      riderAvailability: RiderAvailability.deliveryReserved,
      isIdempotentReplay: true,
    );
    _idempotencyReceipts[idempotencyId] = _IdempotencyRecord(
      request.id,
      receipt,
    );
    return _AcceptanceCommit(receipt, false);
  }

  Future<T> _inAcceptanceTransaction<T>(Future<T> Function() action) async {
    final previous = _transactionTail;
    final released = Completer<void>();
    _transactionTail = released.future;
    await previous;
    try {
      return await action();
    } finally {
      released.complete();
    }
  }
}

class _IdempotencyRecord {
  const _IdempotencyRecord(this.requestId, this.receipt);
  final String requestId;
  final DeliveryAcceptanceReceipt receipt;
}

class _AcceptanceCommit {
  const _AcceptanceCommit(this.receipt, this.changed);
  final DeliveryAcceptanceReceipt receipt;
  final bool changed;
}
