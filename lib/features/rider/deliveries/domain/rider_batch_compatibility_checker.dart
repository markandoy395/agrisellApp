import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_batch_delivery.dart';

abstract final class RiderBatchCompatibilityChecker {
  static RiderBatchRejection? check(
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

  static List<String> handlingWarnings(List<DeliveryRequest> deliveries) =>
      deliveries
          .expand((item) => item.handlingRequirements)
          .map((item) => item.type.label)
          .toSet()
          .toList(growable: false);
}
