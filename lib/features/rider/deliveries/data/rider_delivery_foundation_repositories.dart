import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_proof.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';
import 'package:agresell_app/features/rider/deliveries/domain/offline_delivery_action.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_state_snapshot.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';

abstract interface class RiderAvailabilityRepository {
  Future<RiderAvailability> loadAvailability(String riderId);

  Future<void> saveAvailability(String riderId, RiderAvailability availability);
}

abstract interface class DeliveryRequestRepository {
  Future<List<DeliveryRequest>> fetchRequests({
    required String riderId,
    RiderDeliverySearch? search,
  });
}

abstract interface class ActiveDeliveryRepository {
  Future<DeliveryRequest?> loadActiveDelivery(String riderId);

  Future<void> saveActiveDelivery(String riderId, DeliveryRequest delivery);

  Future<void> clearActiveDelivery(String riderId);
}

abstract interface class DeliveryStatusRepository {
  Future<DeliveryStatusEvent> recordStatusEvent(DeliveryStatusEvent event);

  Future<List<DeliveryStatusEvent>> loadStatusHistory(String deliveryId);
}

abstract interface class DeliveryProofRepository {
  Future<void> saveProof(String deliveryId, DeliveryProof proof);

  Future<List<DeliveryProof>> loadProofs(String deliveryId);
}

abstract interface class RiderLocationRepository {
  Future<void> saveLocation(String riderId, RiderLocation location);

  Future<RiderLocation?> loadLatestLocation(String riderId);
}

abstract interface class OfflineQueueRepository {
  Future<void> enqueue(OfflineDeliveryAction action);

  Future<List<OfflineDeliveryAction>> loadPending(String riderId);

  Future<List<OfflineDeliveryAction>> loadAll(String riderId);

  Future<void> replace(OfflineDeliveryAction action);

  Future<void> replaceAll(String riderId, List<OfflineDeliveryAction> actions);

  Future<void> remove(String actionId);
}

abstract interface class RiderDeliveryStateStore {
  Future<RiderDeliveryStateSnapshot?> load(String riderId);

  Future<void> save(String riderId, RiderDeliveryStateSnapshot snapshot);

  Future<void> clear(String riderId);
}
