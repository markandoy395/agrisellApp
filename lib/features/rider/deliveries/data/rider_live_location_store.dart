import 'package:agresell_app/features/rider/deliveries/data/rider_location_outbox.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';

abstract interface class RiderLiveLocationStore {
  Future<void> publish({
    required DeliveryRequest request,
    required DeliveryStatus status,
    required RiderLocationUpdate update,
  });

  Future<RiderLocationUpdate?> latest({
    required String deliveryId,
    required String participantId,
  });

  Future<void> stop({required String deliveryId, required String riderId});
}

class RiderLiveLocationAccessException implements Exception {
  const RiderLiveLocationAccessException(this.message);
  final String message;
}
