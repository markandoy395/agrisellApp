import 'package:agresell_app/features/rider/deliveries/data/rider_delivery_repository.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_completion.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_payment.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';

import 'rider_completion_fixture.dart';
import 'rider_acceptance_fixture.dart';

InMemoryRiderDeliveryRepository codRepository({
  bool exceptionApproved = false,
  bool readyForAcceptance = false,
}) => InMemoryRiderDeliveryRepository(
  requests: [
    _codRequest(
      exceptionApproved: exceptionApproved,
      readyForAcceptance: readyForAcceptance,
    ),
  ],
  riderStates: [acceptanceRider()],
  deliveryConfigurations: {
    'delivery-1': const DeliveryCompletionConfiguration(
      requiredMethods: {
        DeliveryConfirmationMethod.buyerConfirmation,
        DeliveryConfirmationMethod.gpsLocation,
        DeliveryConfirmationMethod.timestamp,
      },
    ),
  },
);

DeliveryRequest _codRequest({
  required bool exceptionApproved,
  required bool readyForAcceptance,
}) => DeliveryRequest(
  id: 'delivery-1',
  orderNumber: 'AGR-COD-1',
  productName: 'Fresh produce',
  sellerName: 'Farm',
  buyerName: 'Buyer',
  pickupLocation: const DeliveryLocation(
    address: 'Pickup',
    latitude: 8.48,
    longitude: 124.65,
  ),
  deliveryLocation: const DeliveryLocation(
    address: 'Delivery',
    latitude: 8.49,
    longitude: 124.66,
  ),
  pickupDeadline: DateTime(2030),
  deliveryDeadline: DateTime(2030),
  distanceKm: 1,
  estimatedTravelMinutes: 5,
  pickupToDeliveryDistanceKm: 2,
  pickupToDeliveryMinutes: 10,
  serviceArea: 'Cagayan de Oro',
  totalWeightKg: 20,
  requiredCapacityKg: 20,
  deliveryFee: 119,
  feeBreakdown: const DeliveryFeeBreakdown(
    baseFee: 50,
    pickupDistanceFee: 10,
    deliveryDistanceFee: 20,
    productWeightFee: 5,
    vehicleAdjustment: 3,
    urgencyFee: 2,
    perishableProductFee: 4,
    waitingFee: 6,
    returnFee: 7,
    additionalStopFee: 1,
    incentive: 8,
    bonus: 9,
    deduction: 4,
    penalty: 2,
  ),
  paymentMethod: 'Cash on Delivery',
  cashOnDelivery: CashOnDeliveryRequirement(
    amountToCollect: 500,
    status: exceptionApproved
        ? CashCollectionStatus.exceptionApproved
        : CashCollectionStatus.pending,
    authorizedExceptionReference: exceptionApproved
        ? 'server://payment-exception/1'
        : null,
  ),
  stage: readyForAcceptance
      ? DeliveryStage.readyForPickup
      : DeliveryStage.accepted,
  assignedRiderId: readyForAcceptance ? null : 'rider-a',
);

DeliveryCompletionCommand codCommand({
  required double amount,
  String key = 'cod-completion',
  CashCollectionIssue? issue,
}) => DeliveryCompletionCommand(
  deliveryId: 'delivery-1',
  riderId: 'rider-a',
  idempotencyKey: key,
  finalLocation: completionLocation(),
  proofReferences: const {
    DeliveryConfirmationMethod.buyerConfirmation: 'protected://buyer',
    DeliveryConfirmationMethod.gpsLocation: 'protected://gps',
    DeliveryConfirmationMethod.timestamp: 'protected://time',
  },
  cashCollection: CashCollectionSubmission(
    amountReceived: amount,
    collectionConfirmed: issue == null,
    issue: issue,
  ),
);
