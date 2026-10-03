import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_compatibility_checker.dart';
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
    final compatibility = RiderBatchCompatibilityChecker.check(
      deliveries,
      context,
    );
    if (compatibility != null) {
      return RiderBatchEvaluation.rejected(compatibility);
    }
    return _buildPlan(deliveries, context, combinedWeight, capacity);
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
        handlingWarnings: RiderBatchCompatibilityChecker.handlingWarnings(
          deliveries,
        ),
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
