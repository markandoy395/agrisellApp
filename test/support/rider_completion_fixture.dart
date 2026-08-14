import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';

DeliveryRequest completionRequest() => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'AGR-1',
  productName: 'Fresh vegetables',
  quantityDescription: '2 baskets',
  sellerName: 'Carmen Farm',
  buyerName: 'Buyer One',
  pickupLocation: const DeliveryLocation(
    address: 'Carmen Market',
    latitude: 8.48,
    longitude: 124.65,
  ),
  deliveryLocation: const DeliveryLocation(
    address: 'Buyer address',
    latitude: 8.49,
    longitude: 124.66,
  ),
  pickupDeadline: DateTime(2030),
  deliveryFee: 180,
  stage: DeliveryStage.accepted,
  assignedRiderId: 'rider-a',
);

DeliveryStatusLocation completionLocation({
  double latitude = 8.49,
  double longitude = 124.66,
  double accuracy = 5,
  DateTime? timestamp,
}) => DeliveryStatusLocation(
  latitude: latitude,
  longitude: longitude,
  accuracyMeters: accuracy,
  timestamp: timestamp ?? DateTime.now(),
);

InMemoryRiderDeliveryRepository completionRepository({
  Set<DeliveryConfirmationMethod> methods = const {
    DeliveryConfirmationMethod.confirmationCode,
    DeliveryConfirmationMethod.buyerConfirmation,
    DeliveryConfirmationMethod.handoverPhoto,
    DeliveryConfirmationMethod.gpsLocation,
    DeliveryConfirmationMethod.timestamp,
  },
  DateTime? expiresAt,
  int maxAttempts = 3,
}) => InMemoryRiderDeliveryRepository(
  requests: [completionRequest()],
  deliveryConfigurations: {
    'delivery-1': DeliveryCompletionConfiguration(
      requiredMethods: methods,
      deliveryCodeHash: DeliveryCompletionConfiguration.hashSecret('246810'),
      codeExpiresAt: expiresAt ?? DateTime(2031),
      maxCodeAttempts: maxAttempts,
    ),
  },
);

Future<void> reachDeliveryConfirmation(
  InMemoryRiderDeliveryRepository repository,
) async {
  var current = DeliveryStatus.accepted;
  for (final next in const [
    DeliveryStatus.goingToPickup,
    DeliveryStatus.arrivedAtPickup,
    DeliveryStatus.waitingForProduct,
    DeliveryStatus.pickupConfirmationRequired,
    DeliveryStatus.productPickedUp,
    DeliveryStatus.goingToBuyer,
    DeliveryStatus.arrivedAtDelivery,
    DeliveryStatus.waitingForBuyer,
    DeliveryStatus.deliveryConfirmationRequired,
  ]) {
    await repository.updateDeliveryStatus(
      DeliveryStatusUpdateCommand(
        deliveryId: 'delivery-1',
        riderId: 'rider-a',
        previousStatus: current,
        newStatus: next,
        idempotencyKey: next.name,
        location: next == DeliveryStatus.arrivedAtPickup
            ? completionLocation(latitude: 8.48, longitude: 124.65)
            : completionLocation(),
      ),
    );
    current = next;
  }
}

DeliveryCompletionCommand completionCommand({
  String code = '246810',
  String key = 'completion-1',
  Map<DeliveryConfirmationMethod, String>? proofs,
  DeliveryStatusLocation? location,
}) => DeliveryCompletionCommand(
  deliveryId: 'delivery-1',
  riderId: 'rider-a',
  idempotencyKey: key,
  finalLocation: location ?? completionLocation(),
  confirmationCode: code,
  proofReferences:
      proofs ??
      const {
        DeliveryConfirmationMethod.buyerConfirmation:
            'protected://delivery/delivery-1/buyer',
        DeliveryConfirmationMethod.handoverPhoto:
            'local-secure://delivery/delivery-1/handoverPhoto/evidence.jpg',
        DeliveryConfirmationMethod.gpsLocation:
            'protected://delivery/delivery-1/gps',
        DeliveryConfirmationMethod.timestamp:
            'protected://delivery/delivery-1/time',
      },
  evidenceCapturedAt: location?.timestamp ?? DateTime.now(),
  evidenceLocation: location ?? completionLocation(),
);

Future<void> reachGoingToBuyer(
  InMemoryRiderDeliveryRepository repository,
) async {
  var current = DeliveryStatus.accepted;
  for (final next in const [
    DeliveryStatus.goingToPickup,
    DeliveryStatus.arrivedAtPickup,
    DeliveryStatus.waitingForProduct,
    DeliveryStatus.pickupConfirmationRequired,
    DeliveryStatus.productPickedUp,
    DeliveryStatus.goingToBuyer,
  ]) {
    await repository.updateDeliveryStatus(
      DeliveryStatusUpdateCommand(
        deliveryId: 'delivery-1',
        riderId: 'rider-a',
        previousStatus: current,
        newStatus: next,
        idempotencyKey: next.name,
        location: next == DeliveryStatus.arrivedAtPickup
            ? completionLocation(latitude: 8.48, longitude: 124.65)
            : completionLocation(),
      ),
    );
    current = next;
  }
}

DeliveryStatusUpdateCommand buyerArrivalCommand({
  DeliveryStatusLocation? location,
  bool manual = false,
}) => DeliveryStatusUpdateCommand(
  deliveryId: 'delivery-1',
  riderId: 'rider-a',
  previousStatus: DeliveryStatus.goingToBuyer,
  newStatus: DeliveryStatus.arrivedAtDelivery,
  idempotencyKey: manual ? 'manual-arrival' : 'arrival',
  location: location ?? completionLocation(),
  manualArrivalOverride: manual,
  manualOverrideReason: manual ? 'location_inaccurate' : null,
);
