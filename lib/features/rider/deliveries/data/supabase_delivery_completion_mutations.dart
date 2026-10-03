part of 'supabase_delivery_data_source.dart';

extension SupabaseDeliveryCompletionMutations on SupabaseDeliveryDataSource {
  Future<DeliveryStatusHistory> completePickupStatus({
    required String deliveryId,
    required DeliveryStatus previousStatus,
    required String idempotencyKey,
    required PickupCompletionCommand command,
  }) => _guard(() async {
    final checklist = command.checklist;
    final location = command.location;
    final value = await client.rpc(
      'complete_pickup',
      params: {
        'p_delivery_id': deliveryId,
        'p_previous_status': previousStatus.databaseValue,
        'p_idempotency_key': idempotencyKey,
        'p_latitude': location.latitude,
        'p_longitude': location.longitude,
        'p_accuracy_meters': location.accuracyMeters,
        'p_location_captured_at': location.timestamp?.toUtc().toIso8601String(),
        'p_is_mocked': location.isMocked,
        'p_is_approximate': location.isApproximate,
        'p_checklist': {
          'correct_product': checklist.correctProduct,
          'correct_quantity': checklist.correctQuantity,
          'correct_weight': checklist.correctWeight,
          'secure_packaging': checklist.securePackaging,
          'not_visibly_damaged': checklist.notVisiblyDamaged,
          'matches_request': checklist.matchesRequest,
          'fits_vehicle': checklist.fitsVehicle,
          'handling_instructions_received':
              checklist.handlingInstructionsReceived,
        },
        'p_quantity': checklist.confirmedQuantity,
        'p_weight_kg': checklist.confirmedWeightKg,
      },
    );
    final history = _map(value)['history'];
    if (history == null) {
      throw const DeliveryDataException(
        DeliveryDataFailureType.database,
        'The pickup status history was not returned.',
      );
    }
    return DeliveryStatusHistory.fromJson(_map(history));
  });

  Future<DeliveryStatusHistory> completeDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus previousStatus,
    required String idempotencyKey,
    required DeliveryStatusLocation location,
    CashCollectionSubmission? cashCollection,
    String? remarks,
  }) => _guard(() async {
    final value = await client.rpc(
      'complete_delivery',
      params: {
        'p_delivery_id': deliveryId,
        'p_previous_status': previousStatus.databaseValue,
        'p_idempotency_key': idempotencyKey,
        'p_remarks': remarks,
        'p_latitude': location.latitude,
        'p_longitude': location.longitude,
        'p_cash_amount': cashCollection?.amountReceived,
        'p_cash_confirmed': cashCollection?.collectionConfirmed ?? false,
        'p_cash_issue': cashCollection?.issue?.name,
        'p_cash_notes': cashCollection?.notes,
      },
    );
    final history = _map(value)['history'];
    if (history == null) {
      throw const DeliveryDataException(
        DeliveryDataFailureType.database,
        'Delivery completion history was not returned.',
      );
    }
    return DeliveryStatusHistory.fromJson(_map(history));
  });
}
