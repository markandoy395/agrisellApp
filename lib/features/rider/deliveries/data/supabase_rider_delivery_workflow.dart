part of 'rider_delivery_repository.dart';

extension _SupabaseRiderDeliveryWorkflow on SupabaseRiderDeliveryRepository {
  Future<List<DeliveryRequest>> _fetchRequests(
    String riderId, {
    RiderDeliverySearch? search,
  }) async {
    final bundles = search == null
        ? <DeliveryBundle>[
            ...await _dataSource.getAvailableDeliveries(),
            ...await _dataSource.getAssignedDeliveries(),
          ]
        : await _dataSource.getNearbyDeliveries(search);
    final unique = <String, DeliveryBundle>{
      for (final bundle in bundles) bundle.delivery.deliveryId: bundle,
    };
    return unique.values.map((item) => _request(item, riderId)).toList();
  }

  Future<RiderRequestPage> _fetchNearbyRequests(RiderRequestQuery query) async {
    final all = await _fetchRequests(
      query.matching.riderId,
      search: query.matching.location,
    );
    final assigned = all
        .where(
          (request) =>
              request.isAssignedTo(query.matching.riderId) &&
              !request.stage.isTerminal,
        )
        .toList(growable: false);
    final search = query.searchText.trim().toLowerCase();
    final filtered = all.where((request) {
      if (!request.isAvailableTo(query.matching.riderId)) return false;
      // A farmer-selected request has already been matched to this Rider by
      // the server. Keep it visible even when nearby-request estimates are
      // incomplete; acceptance is still validated server-side.
      if (!request.isFarmerSelectedRequest &&
          riderRequestRejection(
                request,
                query.matching,
                requireCurrentGps:
                    !query.matching.usesRegisteredLocationEstimate,
              ) !=
              null) {
        return false;
      }
      if (!query.filters.allows(
        request,
        pickupDistanceKm: query.matching.pickupDistanceKm(request),
      )) {
        return false;
      }
      return search.isEmpty ||
          <String>[
            request.productName,
            request.orderNumber,
            request.pickupLocation.address,
            request.deliveryLocation.address,
          ].any((value) => value.toLowerCase().contains(search));
    }).toList();
    sortRiderRequests(
      filtered,
      query.sort,
      pickupDistanceKm: query.matching.pickupDistanceKm,
    );
    final offset = int.tryParse(query.cursor ?? '') ?? 0;
    if (offset >= filtered.length) {
      return RiderRequestPage(items: const [], assignedItems: assigned);
    }
    final end = (offset + query.pageSize).clamp(0, filtered.length);
    return RiderRequestPage(
      items: filtered.sublist(offset, end),
      assignedItems: assigned,
      nextCursor: end < filtered.length ? '$end' : null,
    );
  }

  Future<DeliveryAcceptanceReceipt> _acceptDelivery(
    DeliveryAcceptanceCommand command,
  ) async {
    try {
      final delivery = await _dataSource.acceptDelivery(
        deliveryId: command.requestId,
        idempotencyKey: command.idempotencyKey,
      );
      final bundle = await _requiredBundle(command.requestId);
      final request = _request(bundle, command.riderId);
      return DeliveryAcceptanceReceipt(
        request: request,
        activeDelivery: ActiveDeliveryRecord(
          id: 'delivery-${delivery.deliveryId}',
          requestId: delivery.deliveryId,
          riderId: command.riderId,
          acceptedAt: delivery.acceptedAt ?? delivery.updatedAt,
          estimatedEarning: bundle.payment?.finalEarning ?? 0,
        ),
        riderAvailability: RiderAvailability.deliveryReserved,
      );
    } on DeliveryDataException catch (error) {
      developer.log(
        'Rider delivery acceptance failed: ${error.message}',
        name: 'agrisell.rider.acceptance',
        error: error.cause ?? error,
      );
      throw DeliveryAcceptanceException(_acceptanceFailure(error));
    }
  }

  DeliveryAcceptanceFailure _acceptanceFailure(DeliveryDataException error) {
    final message = error.message.toLowerCase();
    if (message.contains('active_delivery_limit_reached')) {
      return DeliveryAcceptanceFailure.activeDeliveryLimit;
    }
    if (message.contains('delivery_request_expired') ||
        message.contains('delivery request expired') ||
        message.contains('deadline_conflict')) {
      return DeliveryAcceptanceFailure.expired;
    }
    if (message.contains('delivery_request_missing') ||
        message.contains('delivery not found')) {
      return DeliveryAcceptanceFailure.requestNotFound;
    }
    if (message.contains('capacity_conflict')) {
      return DeliveryAcceptanceFailure.capacityMismatch;
    }
    if (message.contains('vehicle_type_conflict')) {
      return DeliveryAcceptanceFailure.vehicleMismatch;
    }
    if (message.contains('route_incompatible') ||
        message.contains('product_handling_conflict')) {
      return DeliveryAcceptanceFailure.batchIncompatible;
    }
    if (message.contains('cod_responsibility_unavailable')) {
      return DeliveryAcceptanceFailure.codUnavailable;
    }
    return switch (error.type) {
      DeliveryDataFailureType.conflict =>
        DeliveryAcceptanceFailure.alreadyAssigned,
      DeliveryDataFailureType.timeout =>
        DeliveryAcceptanceFailure.networkTimeout,
      DeliveryDataFailureType.offline =>
        DeliveryAcceptanceFailure.networkTimeout,
      DeliveryDataFailureType.authentication ||
      DeliveryDataFailureType.authorization =>
        DeliveryAcceptanceFailure.riderNotAllowed,
      DeliveryDataFailureType.validation =>
        DeliveryAcceptanceFailure.riderIneligible,
      _ => DeliveryAcceptanceFailure.serverError,
    };
  }

  Future<DeliveryRequest> _decline({
    required String requestId,
    required String riderId,
  }) async {
    final request = await _requestById(requestId, riderId);
    await _dataSource.declineDeliveryRequest(deliveryId: requestId);
    return request.declineFor(riderId);
  }

  Future<DeliveryRequest> _cancel({
    required String requestId,
    required String riderId,
    required String reason,
  }) async {
    final bundle = await _requiredBundle(requestId);
    await _dataSource.cancelDelivery(
      deliveryId: requestId,
      previousStatus: bundle.delivery.deliveryStatus,
      idempotencyKey: _key(),
      reason: reason,
    );
    return _request(await _requiredBundle(requestId), riderId);
  }

  Future<DeliveryRequest> _advance({
    required String requestId,
    required String riderId,
    required DeliveryStage nextStage,
    DeliveryProof? proof,
  }) async {
    if (proof != null) {
      final reference = proof.filePath ?? proof.secureReference;
      final remoteReference = await _remoteProofReference(
        reference: reference,
        deliveryId: requestId,
        stage: proof.proofStage,
        type: proof.type,
      );
      await _dataSource.saveDeliveryProof(
        proof.copyWith(filePath: remoteReference),
      );
      await _removeLocalProof(reference);
    }
    final bundle = await _requiredBundle(requestId);
    await _dataSource.updateDeliveryStatus(
      deliveryId: requestId,
      previousStatus: bundle.delivery.deliveryStatus,
      newStatus: nextStage.canonicalStatus,
      idempotencyKey: _key(),
    );
    return _request(await _requiredBundle(requestId), riderId);
  }

  Future<DeliveryBundle> _requiredBundle(String deliveryId) async {
    final value = await _dataSource.getDeliveryById(deliveryId);
    if (value == null) throw const DeliveryDomainException.notFound();
    return value;
  }

  Future<DeliveryRequest> _requestById(String id, String riderId) async =>
      _request(await _requiredBundle(id), riderId);

  String _key() => DateTime.now().microsecondsSinceEpoch.toString();
}
