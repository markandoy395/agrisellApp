import 'package:agresell_app/features/rider/profile/data/rider_repository_exception.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_cargo_capacity_policy.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location_quality.dart';

abstract final class RiderEntityValidator {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _mobile = RegExp(r'^(?:\+63|0)9\d{9}$');
  static final _plate = RegExp(r'^[A-Z0-9 -]{3,20}$');

  static void rider(Rider value) {
    if (value.firstName.trim().isEmpty || value.lastName.trim().isEmpty) {
      _invalid('First and last names are required.');
    }
    if (!_email.hasMatch(value.email.trim())) {
      _invalid('Enter a valid email address.');
    }
    final mobile = value.contactNumber.replaceAll(RegExp(r'[ -]'), '');
    if (!_mobile.hasMatch(mobile)) {
      _invalid('Enter a valid mobile number.');
    }
    if (value.vehicleType.trim().isEmpty) {
      _invalid('Select a Rider vehicle type.');
    }
    final latitude = value.gpsLatitude;
    if (latitude != null &&
        (!latitude.isFinite || latitude < -90 || latitude > 90)) {
      _invalid('The Rider latitude is invalid.');
    }
    final longitude = value.gpsLongitude;
    if (longitude != null &&
        (!longitude.isFinite || longitude < -180 || longitude > 180)) {
      _invalid('The Rider longitude is invalid.');
    }
  }

  static void vehicle(RiderVehicle value) {
    if (value.riderId.isEmpty ||
        value.vehicleType.trim().isEmpty ||
        value.vehicleModel.trim().isEmpty ||
        value.vehicleColor.trim().isEmpty) {
      _invalid('Complete all required vehicle fields.');
    }
    if (value.plateNumber.trim().isEmpty ||
        !_plate.hasMatch(value.plateNumber.trim().toUpperCase())) {
      _invalid('Enter a valid vehicle plate number.');
    }
    final capacityError = RiderCargoCapacityPolicy.error(
      '${value.capacityKg}',
      value.vehicleType,
      serverMaximum: value.maximumCapacityKg,
    );
    if (capacityError != null) _invalid(capacityError);
  }

  static void document(RiderDocument value) {
    if (value.riderId.isEmpty || value.filePath.trim().isEmpty) {
      _invalid('The Rider document record is incomplete.');
    }
    if (value.documentType.isVehicleDocument != (value.vehicleId != null)) {
      _invalid('The document is associated with the wrong owner type.');
    }
    final expiry = value.expiryDate;
    if (expiry != null && expiry.isBefore(DateTime.now())) {
      _invalid('The document expiry date must be in the future.');
    }
  }

  static void location(RiderLocation value) {
    if (value.riderId?.isEmpty ?? true) {
      _invalid('A Rider is required for the location update.');
    }
    if (!value.hasValidCoordinates ||
        value.accuracyMeters < 0 ||
        !value.accuracyMeters.isFinite) {
      _invalid('The Rider location is invalid.');
    }
  }

  static Never _invalid(String message) => throw RiderRepositoryException(
    message,
    type: RiderFailureType.validation,
    isRecoverable: false,
  );
}
