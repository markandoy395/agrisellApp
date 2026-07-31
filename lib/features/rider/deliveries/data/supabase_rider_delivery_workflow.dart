part of 'rider_delivery_repository.dart';

extension _SupabaseRiderDeliveryWorkflow on SupabaseRiderDeliveryRepository {
  Future<List<DeliveryRequest>> _fetchRequests(String riderId) async {
    final bundles = <DeliveryBundle>[
      ...await _dataSource.getAvailableDeliveries(),
      ...await _dataSource.getAssignedDeliveries(),
    ];
    final unique = <String, DeliveryBundle>{
      for (final bundle in bundles) bundle.delivery.deliveryId: bundle,
    };
    return unique.values.map((item) => _request(item, riderId)).toList();
  }

  Future<RiderRequestPage> _fetchNearbyRequests(RiderRequestQuery query) async {
    final all = await _fetchRequests(query.matching.riderId);
    final search = query.searchText.trim().toLowerCase();
    final filtered = all.where((request) {
      if (!request.isAvailableTo(query.matching.riderId)) return false;
      if (riderRequestRejection(
            request,
            query.matching,
            requireCurrentGps: !query.matching.usesRegisteredLocationEstimate,
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
    if (offset >= filtered.length) return const RiderRequestPage(items: []);
    final end = (offset + query.pageSize).clamp(0, filtered.length);
    return RiderRequestPage(
      items: filtered.sublist(offset, end),
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
      throw DeliveryAcceptanceException(switch (error.type) {
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
      });
    }
  }

  Future<DeliveryRequest> _decline({
    required String requestId,
    required String riderId,
  }) async => (await _requestById(requestId, riderId)).declineFor(riderId);

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
