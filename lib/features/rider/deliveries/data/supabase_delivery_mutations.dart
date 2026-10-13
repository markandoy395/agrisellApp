part of 'supabase_delivery_data_source.dart';

extension SupabaseDeliveryMutations on SupabaseDeliveryDataSource {
  Future<Delivery> createDelivery(
    Delivery delivery, {
    Iterable<DeliveryLocation> locations = const [],
    DeliveryRequirement? requirement,
    DeliveryPayment? payment,
  }) => _guard(() async {
    final value = await client
        .from('deliveries')
        .insert(delivery.toJson()..remove('delivery_id'))
        .select()
        .single();
    return Delivery.fromJson(value);
  });

  Future<Delivery> acceptDelivery({
    required String deliveryId,
    required String idempotencyKey,
  }) => _guard(() async {
    final value = await client.rpc(
      'accept_delivery',
      params: {
        'p_delivery_id': deliveryId,
        'p_idempotency_key': idempotencyKey,
      },
    );
    return Delivery.fromJson(_map(value));
  });

  Future<void> declineDeliveryRequest({required String deliveryId}) =>
      _guard(() async {
        await client.rpc<Object?>(
          'decline_delivery_request',
          params: {'p_delivery_id': deliveryId},
        );
      });

  Future<DeliveryStatusHistory> updateDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus previousStatus,
    required DeliveryStatus newStatus,
    required String idempotencyKey,
    String? remarks,
    double? latitude,
    double? longitude,
  }) => _guard(() async {
    final value = await client.rpc(
      'update_current_rider_delivery_status',
      params: {
        'p_delivery_id': deliveryId,
        'p_previous_status': previousStatus.databaseValue,
        'p_new_status': newStatus.databaseValue,
        'p_idempotency_key': idempotencyKey,
        'p_remarks': remarks,
        'p_latitude': latitude,
        'p_longitude': longitude,
      },
    );
    final history = _map(value)['history'];
    if (history == null) {
      throw const DeliveryDataException(
        DeliveryDataFailureType.database,
        'The delivery status history was not returned.',
      );
    }
    return DeliveryStatusHistory.fromJson(_map(history));
  });

  Future<DeliveryStatusHistory> appendDeliveryStatus({
    required String deliveryId,
    required DeliveryStatus previousStatus,
    required DeliveryStatus newStatus,
    required String idempotencyKey,
    String? remarks,
    double? latitude,
    double? longitude,
  }) => updateDeliveryStatus(
    deliveryId: deliveryId,
    previousStatus: previousStatus,
    newStatus: newStatus,
    idempotencyKey: idempotencyKey,
    remarks: remarks,
    latitude: latitude,
    longitude: longitude,
  );

  Future<DeliveryStatusHistory> cancelDelivery({
    required String deliveryId,
    required DeliveryStatus previousStatus,
    required String idempotencyKey,
    required String reason,
  }) => updateDeliveryStatus(
    deliveryId: deliveryId,
    previousStatus: previousStatus,
    newStatus: DeliveryStatus.cancelled,
    idempotencyKey: idempotencyKey,
    remarks: reason,
  );

  Future<DeliveryStatusHistory> failDelivery({
    required String deliveryId,
    required DeliveryStatus previousStatus,
    required String idempotencyKey,
    required String reason,
  }) => updateDeliveryStatus(
    deliveryId: deliveryId,
    previousStatus: previousStatus,
    newStatus: DeliveryStatus.failed,
    idempotencyKey: idempotencyKey,
    remarks: reason,
  );

  Future<List<DeliveryLocation>> saveDeliveryLocations(
    Iterable<DeliveryLocation> locations,
  ) => _guard(() async => locations.toList(growable: false));

  Future<DeliveryLocation> updateDeliveryLocation(DeliveryLocation location) =>
      _guard(() async => location);

  Future<DeliveryRequirement> saveDeliveryRequirements(
    DeliveryRequirement requirement,
  ) => _guard(() async => requirement);

  Future<DeliveryPayment> calculateDeliveryEarning(String deliveryId) =>
      _guard(() async {
        throw const DeliveryDataException(
          DeliveryDataFailureType.validation,
          'Delivery earnings are not part of the final ERD.',
        );
      });
}

Map<String, Object?> _map(Object? value) {
  if (value is Map<String, Object?>) return value;
  if (value is Map) {
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
  throw const DeliveryDataException(
    DeliveryDataFailureType.database,
    'The delivery service returned an invalid response.',
  );
}
