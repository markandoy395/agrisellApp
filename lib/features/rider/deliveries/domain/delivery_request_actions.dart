part of 'delivery_request.dart';

extension DeliveryRequestActions on DeliveryRequest {
  DeliveryRequest acceptFor(String riderId) {
    if (!isAvailableTo(riderId)) {
      throw const DeliveryTransitionException('This delivery is unavailable.');
    }
    return copyWith(stage: DeliveryStage.accepted, assignedRiderId: riderId);
  }

  DeliveryRequest declineFor(String riderId) {
    if (!isAvailableTo(riderId)) {
      throw const DeliveryTransitionException(
        'This delivery cannot be declined.',
      );
    }
    return copyWith(declinedRiderIds: <String>{...declinedRiderIds, riderId});
  }

  DeliveryRequest cancelFor(String riderId, String reason) {
    if (!isAssignedTo(riderId) || stage.isTerminal || reason.trim().isEmpty) {
      throw const DeliveryTransitionException(
        'A reason is required to cancel this active delivery.',
      );
    }
    final timestamp = DateTime.now();
    return copyWith(
      stage: DeliveryStage.cancelled,
      outcome: DeliveryOutcome(
        type: DeliveryOutcomeType.cancelled,
        reason: reason.trim(),
        recordedAt: timestamp,
      ),
      closedAt: timestamp,
    );
  }

  DeliveryRequest advanceTo(DeliveryStage nextStage, {DeliveryProof? proof}) {
    if (stage.next != nextStage) {
      throw const DeliveryTransitionException(
        'This delivery stage cannot advance.',
      );
    }
    final requiredProof = nextStage.requiredProofPurpose;
    if (requiredProof != null &&
        (proof == null || !proof.satisfies(requiredProof))) {
      throw const DeliveryTransitionException(
        'The required delivery proof is missing.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    return copyWith(
      stage: nextStage,
      proofs: proof == null ? proofs : <DeliveryProof>[...proofs, proof],
      closedAt: nextStage == DeliveryStage.completed
          ? DateTime.now()
          : closedAt,
    );
  }

  DeliveryRequest copyWith({
    DeliveryStage? stage,
    String? assignedRiderId,
    Iterable<DeliveryProof>? proofs,
    Iterable<String>? declinedRiderIds,
    DeliveryOutcome? outcome,
    DateTime? closedAt,
  }) => DeliveryRequest(
    id: id,
    orderNumber: orderNumber,
    productName: productName,
    sellerName: sellerName,
    buyerName: buyerName,
    pickupLocation: pickupLocation,
    deliveryLocation: deliveryLocation,
    pickupDeadline: pickupDeadline,
    productImageUrl: productImageUrl,
    quantityDescription: quantityDescription,
    productCategory: productCategory,
    productDescription: productDescription,
    totalWeightKg: totalWeightKg,
    packageDimensions: packageDimensions,
    distanceKm: distanceKm,
    estimatedTravelMinutes: estimatedTravelMinutes,
    pickupToDeliveryDistanceKm: pickupToDeliveryDistanceKm,
    pickupToDeliveryMinutes: pickupToDeliveryMinutes,
    deliveryFee: deliveryFee,
    feeBreakdown: feeBreakdown,
    priority: priority,
    paymentMethod: paymentMethod,
    cashOnDelivery: cashOnDelivery,
    pickupInstructions: pickupInstructions,
    deliveryInstructions: deliveryInstructions,
    deliveryDeadline: deliveryDeadline,
    availableAt: availableAt,
    expiresAt: expiresAt,
    serviceArea: serviceArea,
    requiredCapacityKg: requiredCapacityKg,
    requiredVehicleTypes: requiredVehicleTypes,
    handlingRequirements: handlingRequirements,
    cancellationConditions: cancellationConditions,
    transportCompatibilityGroup: transportCompatibilityGroup,
    requiresExclusiveTransport: requiresExclusiveTransport,
    route: route,
    stage: stage ?? this.stage,
    assignedRiderId: assignedRiderId ?? this.assignedRiderId,
    assignmentRequestId: assignmentRequestId,
    assignmentRequestStatus: assignmentRequestStatus,
    reservedRiderId: reservedRiderId,
    reservedUntil: reservedUntil,
    outcome: outcome ?? this.outcome,
    closedAt: closedAt ?? this.closedAt,
    proofs: proofs ?? this.proofs,
    declinedRiderIds: declinedRiderIds ?? this.declinedRiderIds,
  );
}
