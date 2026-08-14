part of 'rider_delivery_repository.dart';

extension _SupabaseRiderDeliveryMapping on SupabaseRiderDeliveryRepository {
  DeliveryRequest _request(DeliveryBundle bundle, String riderId) {
    final delivery = bundle.delivery;
    final paymentMethod = bundle.raw['payment_method']?.toString() ?? '';
    final paymentStatus = bundle.raw['payment_status']?.toString() ?? '';
    final amountToCollect = _requestNumber(bundle.raw['amount_to_collect']);
    final assignmentRequestId = _requestText(
      bundle.raw['assignment_request_id'],
    );
    final assignmentStatusValue = _requestText(
      bundle.raw['assignment_request_status'],
    );
    final assignmentStatus = assignmentStatusValue == null
        ? null
        : RiderAssignmentRequestStatus.fromValue(assignmentStatusValue);
    final assignmentExpiresAt =
        _requestDate(bundle.raw['assignment_request_expires_at']) ??
        _requestDate(bundle.raw['expires_at']);
    final pickup =
        bundle.pickup ??
        const DeliveryLocation(address: 'Pickup location unavailable');
    final dropoff =
        bundle.dropoff ??
        const DeliveryLocation(address: 'Drop-off unavailable');
    final requirement = bundle.requirement;
    final dimensions =
        requirement?.packageLengthCm == null ||
            requirement?.packageWidthCm == null ||
            requirement?.packageHeightCm == null
        ? null
        : PackageDimensions(
            lengthCm: requirement!.packageLengthCm!,
            widthCm: requirement.packageWidthCm!,
            heightCm: requirement.packageHeightCm!,
          );
    return DeliveryRequest(
      id: delivery.deliveryId,
      orderNumber: 'Order #${delivery.orderId}',
      productName: _requestText(bundle.raw['goods_summary']) ?? 'Farm produce',
      sellerName: _requestText(bundle.raw['seller_name']) ?? 'Farmer',
      buyerName: _requestText(bundle.raw['buyer_name']) ?? 'Buyer',
      pickupLocation: pickup,
      deliveryLocation: dropoff,
      pickupDeadline:
          _requestDate(bundle.raw['requested_schedule']) ?? delivery.createdAt,
      quantityDescription: _requestText(bundle.raw['goods_summary']) ?? '',
      totalWeightKg:
          _requestNumber(bundle.raw['total_weight_kg']) ??
          delivery.totalWeightKg,
      packageDimensions: dimensions,
      distanceKm: delivery.distanceKm,
      estimatedTravelMinutes: delivery.estimatedTravelMinutes,
      deliveryFee:
          _requestNumber(bundle.raw['proposed_delivery_fee']) ??
          _requestNumber(bundle.raw['delivery_fee']) ??
          0,
      priority: delivery.priority,
      paymentMethod: paymentMethod,
      cashOnDelivery:
          RiderPaymentMethodDetails.fromBackendValue(paymentMethod) ==
                  RiderPaymentMethod.cashOnDelivery &&
              amountToCollect != null
          ? CashOnDeliveryRequirement(
              amountToCollect: amountToCollect,
              status: const {'verified', 'paid'}.contains(paymentStatus)
                  ? CashCollectionStatus.collected
                  : CashCollectionStatus.pending,
              riderCashResponsibility:
                  'Collect the exact amount and confirm it before handover.',
              paymentNotes: 'Cash on Delivery',
            )
          : null,
      pickupInstructions: '',
      deliveryInstructions: '',
      deliveryDeadline: delivery.deliveryDeadline,
      availableAt: delivery.availableAt,
      expiresAt: assignmentExpiresAt ?? delivery.expiresAt,
      serviceArea:
          _requestText(bundle.raw['service_area']) ?? delivery.serviceArea,
      requiredCapacityKg:
          requirement?.minimumCapacityKg ?? delivery.requiredCapacityKg,
      requiredVehicleTypes: _vehicles(requirement?.requiredVehicleType),
      handlingRequirements: _handling(requirement),
      cancellationConditions: requirement?.cancellationConditions ?? '',
      stage: legacyStageForDeliveryStatus(delivery.deliveryStatus),
      assignedRiderId: delivery.riderId == null ? null : riderId,
      assignmentRequestId: assignmentRequestId,
      assignmentRequestStatus: assignmentStatus,
      reservedRiderId: assignmentStatus == RiderAssignmentRequestStatus.pending
          ? riderId
          : null,
      reservedUntil: assignmentStatus == RiderAssignmentRequestStatus.pending
          ? assignmentExpiresAt
          : null,
      closedAt: delivery.closedAt,
      proofs: bundle.proofs,
    );
  }

  Set<RiderVehicleType> _vehicles(String? value) {
    if (value == null) return const {};
    final normalized = value.replaceAll('-', '').toLowerCase();
    return {
      RiderVehicleType.values.firstWhere(
        (item) => item.name.toLowerCase() == normalized,
        orElse: () => RiderVehicleType.other,
      ),
    };
  }

  List<ProductHandlingRequirement> _handling(
    DeliveryRequirement? requirement,
  ) => [
    if (requirement?.requiresCooling ?? false)
      const ProductHandlingRequirement(
        type: ProductHandlingType.temperatureSensitive,
      ),
    if (requirement?.requiresFragileHandling ?? false)
      const ProductHandlingRequirement(type: ProductHandlingType.fragile),
    if (requirement?.requiresWaterproofCover ?? false)
      const ProductHandlingRequirement(type: ProductHandlingType.keepDry),
    if (requirement?.requiresSpecialHandling ?? false)
      ProductHandlingRequirement(
        type: ProductHandlingType.handleCarefully,
        instructions: requirement?.handlingNotes ?? '',
      ),
  ];

  DeliveryStatusSnapshot _snapshot(DeliveryBundle bundle, String riderId) =>
      DeliveryStatusSnapshot(
        request: _request(bundle, riderId),
        currentStatus: bundle.delivery.deliveryStatus,
        events: bundle.history
            .map((item) => _event(item, riderId))
            .toList(growable: false),
      );

  DeliveryStatusEvent _event(DeliveryStatusHistory item, String riderId) =>
      DeliveryStatusEvent(
        eventId: item.statusHistoryId,
        deliveryId: item.deliveryId,
        previousStatus: item.previousStatus ?? item.newStatus,
        newStatus: item.newStatus,
        riderId: riderId,
        timestamp: item.changedAt,
        latitude: item.latitude,
        longitude: item.longitude,
        note: item.remarks,
        source: DeliveryEventSource.online,
        syncStatus: DeliveryEventSyncStatus.synchronized,
      );
}

double? _requestNumber(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '');
}

String? _requestText(Object? value) {
  final text = value?.toString().trim() ?? '';
  return text.isEmpty ? null : text;
}

DateTime? _requestDate(Object? value) =>
    DateTime.tryParse(value?.toString() ?? '')?.toLocal();
