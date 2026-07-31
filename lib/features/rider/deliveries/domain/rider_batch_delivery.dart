import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';

enum RiderBatchRejection {
  riderIneligible,
  activeDeliveryLimit,
  capacityUnknown,
  capacityExceeded,
  exclusiveTransport,
  productConflict,
  temperatureConflict,
  fragileProtectionRequired,
  routeIncompatible,
  deadlineConflict,
}

extension RiderBatchRejectionDetails on RiderBatchRejection {
  String get message => switch (this) {
    RiderBatchRejection.riderIneligible =>
      'This Rider is not eligible for another active delivery.',
    RiderBatchRejection.activeDeliveryLimit =>
      'The Rider has reached the active-delivery limit.',
    RiderBatchRejection.capacityUnknown =>
      'Vehicle capacity or product weight could not be verified.',
    RiderBatchRejection.capacityExceeded =>
      'The combined product weight exceeds vehicle capacity.',
    RiderBatchRejection.exclusiveTransport =>
      'One of these products requires exclusive transport.',
    RiderBatchRejection.productConflict =>
      'The products cannot be transported safely together.',
    RiderBatchRejection.temperatureConflict =>
      'The products require conflicting transport temperatures.',
    RiderBatchRejection.fragileProtectionRequired =>
      'The vehicle has no verified protection for a fragile batch.',
    RiderBatchRejection.routeIncompatible =>
      'The combined route would create an unreasonable delay.',
    RiderBatchRejection.deadlineConflict =>
      'The combined pickup or delivery deadlines cannot be met.',
  };
}

enum RiderBatchStopType { pickup, delivery }

class RiderBatchStop {
  const RiderBatchStop({
    required this.deliveryId,
    required this.type,
    required this.location,
    required this.deadline,
    required this.sequence,
    required this.estimatedArrival,
  });

  final String deliveryId;
  final RiderBatchStopType type;
  final DeliveryLocation location;
  final DateTime deadline;
  final int sequence;
  final DateTime estimatedArrival;
}

class RiderBatchPlan {
  RiderBatchPlan({
    required Iterable<DeliveryRequest> deliveries,
    required Iterable<RiderBatchStop> stops,
    required this.totalDistanceKm,
    required this.estimatedTravelMinutes,
    required this.combinedWeightKg,
    required this.vehicleCapacityKg,
    required Iterable<String> handlingWarnings,
  }) : deliveries = List.unmodifiable(deliveries),
       stops = List.unmodifiable(stops),
       handlingWarnings = List.unmodifiable(handlingWarnings);

  final List<DeliveryRequest> deliveries;
  final List<RiderBatchStop> stops;
  final double totalDistanceKm;
  final int estimatedTravelMinutes;
  final double combinedWeightKg;
  final double vehicleCapacityKg;
  final List<String> handlingWarnings;

  List<RiderBatchStop> get pickupSequence => stops
      .where((stop) => stop.type == RiderBatchStopType.pickup)
      .toList(growable: false);

  List<RiderBatchStop> get deliverySequence => stops
      .where((stop) => stop.type == RiderBatchStopType.delivery)
      .toList(growable: false);

  double get combinedEarning =>
      deliveries.fold(0, (total, delivery) => total + delivery.deliveryFee);

  double get remainingCapacityKg =>
      (vehicleCapacityKg - combinedWeightKg).clamp(0, vehicleCapacityKg);
}

class RiderBatchEvaluation {
  const RiderBatchEvaluation.accepted(this.plan) : rejection = null;
  const RiderBatchEvaluation.rejected(this.rejection) : plan = null;

  final RiderBatchPlan? plan;
  final RiderBatchRejection? rejection;
  bool get isEligible => plan != null;
  String? get message => rejection?.message;
}

class RiderBatchContext {
  const RiderBatchContext({
    required this.riderEligible,
    required this.maximumActiveDeliveries,
    required this.capacityKg,
    required this.now,
    this.currentLocation,
    this.handlingCapabilityKeys = const <String>{},
    this.trafficMultiplier = 1,
    this.maximumBatchDistanceKm = 100,
    this.maximumBatchMinutes = 360,
  });

  final bool riderEligible;
  final int maximumActiveDeliveries;
  final double? capacityKg;
  final DateTime now;
  final RiderDeliverySearch? currentLocation;
  final Set<String> handlingCapabilityKeys;
  final double trafficMultiplier;
  final double maximumBatchDistanceKm;
  final int maximumBatchMinutes;
}
