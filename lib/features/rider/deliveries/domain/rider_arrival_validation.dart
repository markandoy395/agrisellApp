import 'dart:math' as math;

import 'delivery_request.dart';
import 'delivery_status_update.dart';

class RiderArrivalValidation {
  const RiderArrivalValidation._(this.isValid, this.message);

  final bool isValid;
  final String? message;

  factory RiderArrivalValidation.valid() =>
      const RiderArrivalValidation._(true, null);

  factory RiderArrivalValidation.invalid(String message) =>
      RiderArrivalValidation._(false, message);
}

RiderArrivalValidation validateRiderArrival({
  required DeliveryStatusLocation location,
  required DeliveryLocation target,
  required double radiusMeters,
  required double maxAccuracyMeters,
  String? manualOverrideReason,
  String? manualOverrideNotes,
  DateTime? now,
  Duration maxLocationAge = const Duration(seconds: 45),
  Duration maxManualLocationAge = const Duration(minutes: 5),
}) {
  if (!location.isValid) {
    return RiderArrivalValidation.invalid('A valid location is required.');
  }
  final capturedAt = location.timestamp;
  if (capturedAt == null) {
    return RiderArrivalValidation.invalid('Location timestamp is required.');
  }
  final locationAge = (now ?? DateTime.now()).difference(capturedAt);
  if (locationAge < const Duration(seconds: -10)) {
    return RiderArrivalValidation.invalid('Location timestamp is invalid.');
  }
  final reason = manualOverrideReason?.trim();
  if (reason != null && reason.isNotEmpty) {
    const allowed = {
      'gps_signal_blocked',
      'location_inaccurate',
      'pickup_pin_incorrect',
      'delivery_pin_incorrect',
      'access_point_differs',
      'other',
    };
    if (!allowed.contains(reason)) {
      return RiderArrivalValidation.invalid(
        'Manual arrival reason is invalid.',
      );
    }
    if (locationAge > maxManualLocationAge) {
      return RiderArrivalValidation.invalid(
        'Manual arrival requires a recent location sample.',
      );
    }
    final targetDistance = target.hasCoordinates
        ? _distanceMeters(
            location.latitude,
            location.longitude,
            target.latitude!,
            target.longitude!,
          )
        : double.infinity;
    final normallyValid =
        locationAge <= maxLocationAge &&
        !location.isApproximate &&
        location.accuracyMeters <= maxAccuracyMeters &&
        target.hasCoordinates &&
        targetDistance <= radiusMeters;
    if (normallyValid) {
      return RiderArrivalValidation.invalid(
        'Manual override is not needed for this location.',
      );
    }
    final isGpsReason =
        reason == 'gps_signal_blocked' || reason == 'location_inaccurate';
    if (isGpsReason &&
        locationAge <= maxLocationAge &&
        !location.isApproximate &&
        location.accuracyMeters <= maxAccuracyMeters) {
      return RiderArrivalValidation.invalid(
        'The selected GPS reason does not match the location evidence.',
      );
    }
    if (reason == 'other' && (manualOverrideNotes?.trim().isEmpty ?? true)) {
      return RiderArrivalValidation.invalid(
        'Add notes for the manual arrival override.',
      );
    }
    return RiderArrivalValidation.valid();
  }
  if (locationAge > maxLocationAge) {
    return RiderArrivalValidation.invalid('Location is too old; refresh GPS.');
  }
  if (location.isApproximate) {
    return RiderArrivalValidation.invalid(
      'Precise location is required for arrival validation.',
    );
  }
  if (location.accuracyMeters > maxAccuracyMeters) {
    return RiderArrivalValidation.invalid(
      'GPS accuracy is too poor for arrival validation.',
    );
  }
  if (!target.hasCoordinates) {
    return RiderArrivalValidation.invalid(
      'Arrival coordinates are not configured for this location.',
    );
  }
  final distance = _distanceMeters(
    location.latitude,
    location.longitude,
    target.latitude!,
    target.longitude!,
  );
  return distance <= radiusMeters
      ? RiderArrivalValidation.valid()
      : RiderArrivalValidation.invalid(
          'Move within the configured arrival radius.',
        );
}

double _distanceMeters(
  double latitudeA,
  double longitudeA,
  double latitudeB,
  double longitudeB,
) {
  const earthRadius = 6371000.0;
  final latitude = (latitudeB - latitudeA) * math.pi / 180;
  final longitude = (longitudeB - longitudeA) * math.pi / 180;
  final first = latitudeA * math.pi / 180;
  final second = latitudeB * math.pi / 180;
  final value =
      math.sin(latitude / 2) * math.sin(latitude / 2) +
      math.cos(first) *
          math.cos(second) *
          math.sin(longitude / 2) *
          math.sin(longitude / 2);
  return earthRadius * 2 * math.atan2(math.sqrt(value), math.sqrt(1 - value));
}
