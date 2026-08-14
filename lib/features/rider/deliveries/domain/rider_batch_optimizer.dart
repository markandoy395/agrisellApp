import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_delivery.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_delivery_search.dart';

class RiderBatchOptimizer {
  const RiderBatchOptimizer();

  RiderBatchEvaluation evaluate({
    required Iterable<DeliveryRequest> activeDeliveries,
    required RiderBatchContext context,
    DeliveryRequest? candidate,
  }) {
    final active = activeDeliveries.where((item) => !item.stage.isTerminal);
    final deliveries = <DeliveryRequest>[...active, ?candidate];
    if (!context.riderEligible) {
      return const RiderBatchEvaluation.rejected(
        RiderBatchRejection.riderIneligible,
      );
    }
    if (deliveries.length > context.maximumActiveDeliveries ||
        (candidate != null &&
            active.length >= context.maximumActiveDeliveries)) {
      return const RiderBatchEvaluation.rejected(
        RiderBatchRejection.activeDeliveryLimit,
      );
    }
    final capacity = context.capacityKg;
    final weights = deliveries.map(_weightFor).toList();
    if (capacity == null || weights.any((weight) => weight == null)) {
      return const RiderBatchEvaluation.rejected(
        RiderBatchRejection.capacityUnknown,
      );
    }
    final combinedWeight = weights.whereType<double>().fold<double>(
      0,
      (a, b) => a + b,
    );
    if (combinedWeight > capacity) {
      return const RiderBatchEvaluation.rejected(
        RiderBatchRejection.capacityExceeded,
      );
    }
    final compatibility = _compatibilityFailure(deliveries, context);
    if (compatibility != null) {
      return RiderBatchEvaluation.rejected(compatibility);
    }
    return _buildPlan(deliveries, context, combinedWeight, capacity);
  }

  RiderBatchRejection? _compatibilityFailure(
    List<DeliveryRequest> deliveries,
    RiderBatchContext context,
  ) {
    final vehicleType = context.vehicleType;
    if (deliveries.any(
      (item) =>
          item.requiredVehicleTypes.isNotEmpty &&
          (vehicleType == null ||
              !item.requiredVehicleTypes.contains(vehicleType)),
    )) {
      return RiderBatchRejection.vehicleIncompatible;
    }
    if (deliveries.any(
      (item) => item.handlingRequirements.any(
        (rule) =>
            rule.type.needsProvenVehicleCapability &&
            !context.handlingCapabilityKeys.contains(rule.type.name),
      ),
    )) {
      return RiderBatchRejection.handlingCapabilityRequired;
    }
    if (deliveries.any(
      (item) =>
          item.cashOnDelivery != null &&
          item.cashOnDelivery!.riderCashResponsibility.trim().isEmpty,
    )) {
      return RiderBatchRejection.codResponsibilityUnavailable;
    }
    if (deliveries.length < 2) return null;
    if (deliveries.any((item) => item.requiresExclusiveTransport)) {
      return RiderBatchRejection.exclusiveTransport;
    }
    final groups = deliveries
        .map((item) => item.transportCompatibilityGroup.trim().toLowerCase())
        .where((group) => group.isNotEmpty)
        .toSet();
    if (groups.length > 1) return RiderBatchRejection.productConflict;
    final temperatures = deliveries
        .expand((item) => item.handlingRequirements)
        .where((item) => item.type == ProductHandlingType.temperatureSensitive)
        .map((item) => item.instructions.trim().toLowerCase())
        .where((value) => value.isNotEmpty)
        .toSet();
    if (temperatures.length > 1) return RiderBatchRejection.temperatureConflict;
    final hasFragile = deliveries.any(
      (item) => item.handlingRequirements.any(
        (rule) => rule.type == ProductHandlingType.fragile,
      ),
    );
    if (hasFragile &&
        !context.handlingCapabilityKeys.contains('fragileProtection')) {
      return RiderBatchRejection.fragileProtectionRequired;
    }
    return null;
  }

  RiderBatchEvaluation _buildPlan(
    List<DeliveryRequest> deliveries,
    RiderBatchContext context,
    double combinedWeight,
    double capacity,
  ) {
    if (deliveries.any(_missingRequiredCoordinates)) {
      return const RiderBatchEvaluation.rejected(
        RiderBatchRejection.routeIncompatible,
      );
    }
    final pickups =
        deliveries.where((item) => !item.stage.isDeliveryLeg).toList()
          ..sort((a, b) => a.pickupDeadline.compareTo(b.pickupDeadline));
    final dropoffs = [...deliveries]
      ..sort((a, b) => _deliveryDeadline(a).compareTo(_deliveryDeadline(b)));
    final ordered = <(DeliveryRequest, RiderBatchStopType)>[
      for (final request in pickups) (request, RiderBatchStopType.pickup),
      for (final request in dropoffs) (request, RiderBatchStopType.delivery),
    ];
    var cursor = context.currentLocation;
    var elapsedMinutes = 0;
    var totalDistance = 0.0;
    final stops = <RiderBatchStop>[];
    for (var index = 0; index < ordered.length; index++) {
      final entry = ordered[index];
      final location = entry.$2 == RiderBatchStopType.pickup
          ? entry.$1.pickupLocation
          : entry.$1.deliveryLocation;
      final distance = _distance(cursor, location);
      if (distance == null) {
        return const RiderBatchEvaluation.rejected(
          RiderBatchRejection.routeIncompatible,
        );
      }
      totalDistance += distance;
      if (totalDistance > context.maximumBatchDistanceKm) {
        return const RiderBatchEvaluation.rejected(
          RiderBatchRejection.routeIncompatible,
        );
      }
      elapsedMinutes +=
          ((distance / 25) * 60 * context.trafficMultiplier).ceil() + 5;
      final deadline = entry.$2 == RiderBatchStopType.pickup
          ? entry.$1.pickupDeadline
          : _deliveryDeadline(entry.$1);
      final arrival = context.now.add(Duration(minutes: elapsedMinutes));
      if (arrival.isAfter(deadline)) {
        return const RiderBatchEvaluation.rejected(
          RiderBatchRejection.deadlineConflict,
        );
      }
      stops.add(
        RiderBatchStop(
          deliveryId: entry.$1.id,
          type: entry.$2,
          location: location,
          deadline: deadline,
          sequence: index + 1,
          estimatedArrival: arrival,
        ),
      );
      cursor = RiderDeliverySearch(
        latitude: location.latitude!,
        longitude: location.longitude!,
      );
    }
    if (elapsedMinutes > context.maximumBatchMinutes) {
      return const RiderBatchEvaluation.rejected(
        RiderBatchRejection.routeIncompatible,
      );
    }
    return RiderBatchEvaluation.accepted(
      RiderBatchPlan(
        deliveries: deliveries,
        stops: stops,
        totalDistanceKm: totalDistance,
        estimatedTravelMinutes: elapsedMinutes,
        combinedWeightKg: combinedWeight,
        vehicleCapacityKg: capacity,
        handlingWarnings: _handlingWarnings(deliveries),
      ),
    );
  }
}

double? _weightFor(DeliveryRequest request) =>
    request.totalWeightKg ?? request.requiredCapacityKg;

bool _missingRequiredCoordinates(DeliveryRequest request) =>
    (!request.stage.isDeliveryLeg && !request.pickupLocation.hasCoordinates) ||
    !request.deliveryLocation.hasCoordinates ||
    request.deliveryDeadline == null;

DateTime _deliveryDeadline(DeliveryRequest request) =>
    request.deliveryDeadline ?? request.pickupDeadline;

double? _distance(RiderDeliverySearch? from, DeliveryLocation to) {
  if (!to.hasCoordinates) return null;
  if (from == null) return 0;
  return from.distanceTo(latitude: to.latitude!, longitude: to.longitude!);
}

List<String> _handlingWarnings(List<DeliveryRequest> deliveries) => deliveries
    .expand((item) => item.handlingRequirements)
    .map((item) => item.type.label)
    .toSet()
    .toList(growable: false);
