import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_event.dart';

class DeliveryStatusLocation {
  const DeliveryStatusLocation({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
    this.timestamp,
    this.altitudeMeters,
    this.speedMetersPerSecond = 0,
    this.headingDegrees = 0,
    this.isMocked = false,
    this.isApproximate = false,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
  final DateTime? timestamp;
  final double? altitudeMeters;
  final double speedMetersPerSecond;
  final double headingDegrees;
  final bool isMocked;
  final bool isApproximate;

  bool get isValid =>
      latitude.isFinite &&
      longitude.isFinite &&
      accuracyMeters.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180 &&
      accuracyMeters >= 0 &&
      !isMocked;

  bool isUsableForPickup({
    DateTime? now,
    Duration maxAge = const Duration(seconds: 45),
  }) {
    final capturedAt = timestamp;
    if (!isValid || isApproximate || capturedAt == null) return false;
    final age = (now ?? DateTime.now()).difference(capturedAt);
    return age >= const Duration(seconds: -10) && age <= maxAge;
  }
}

class DeliveryStatusUpdateCommand {
  const DeliveryStatusUpdateCommand({
    required this.deliveryId,
    required this.riderId,
    required this.previousStatus,
    required this.newStatus,
    required this.idempotencyKey,
    this.location,
    this.manualArrivalOverride = false,
    this.manualOverrideReason,
    this.manualOverrideNotes,
    this.note,
    this.reasonCode,
    this.proofReference,
    this.source = DeliveryEventSource.online,
  });

  final String deliveryId;
  final String riderId;
  final DeliveryStatus previousStatus;
  final DeliveryStatus newStatus;
  final String idempotencyKey;
  final DeliveryStatusLocation? location;
  final bool manualArrivalOverride;
  final String? manualOverrideReason;
  final String? manualOverrideNotes;
  final String? note;
  final String? reasonCode;
  final String? proofReference;
  final DeliveryEventSource source;

  bool get requiresArrivalLocation =>
      newStatus == DeliveryStatus.arrivedAtPickup ||
      newStatus == DeliveryStatus.arrivedAtDelivery;

  bool get hasValidArrivalEvidence =>
      (location?.isValid ?? false) &&
      location?.timestamp != null &&
      (!manualArrivalOverride ||
          (manualOverrideReason?.trim().isNotEmpty ?? false));
}

class DeliveryStatusSnapshot {
  const DeliveryStatusSnapshot({
    required this.request,
    required this.currentStatus,
    required this.events,
  });

  final DeliveryRequest request;
  final DeliveryStatus currentStatus;
  final List<DeliveryStatusEvent> events;
}
