import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/core/utils/password_policy.dart';

abstract final class RiderRegistrationValidator {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _mobile = RegExp(r'^(?:\+63|0)9\d{9}$');

  static String? validate(RiderRegistration item) {
    if (item.firstName.trim().isEmpty) return 'First name is required.';
    if (item.lastName.trim().isEmpty) return 'Last name is required.';
    if (item.gender.trim().isEmpty) return 'Select a gender.';
    if (!_mobile.hasMatch(item.contactNumber.replaceAll(RegExp(r'[ -]'), ''))) {
      return 'Enter a valid mobile number.';
    }
    if (!_email.hasMatch(item.email.trim())) {
      return 'Enter a valid email address.';
    }
    if (!_isAdult(item.dateOfBirth)) {
      return 'You must meet the minimum rider age requirement.';
    }
    if (item.gpsLatitude == null || item.gpsLongitude == null) {
      return 'Use your current location to continue.';
    }
    if (item.gpsLatitude! < -90 ||
        item.gpsLatitude! > 90 ||
        item.gpsLongitude! < -180 ||
        item.gpsLongitude! > 180) {
      return 'Use a valid current location.';
    }
    final vehicle = item.vehicleType;
    if (vehicle == null) return 'Select a vehicle type.';
    if (vehicle.requiresPlate && item.vehiclePlateNumber.trim().isEmpty) {
      return 'Enter your vehicle plate number.';
    }
    if (vehicle.requiresLicense && item.licenseNumber.trim().isEmpty) {
      return 'Enter your driver’s license number.';
    }
    if (!isStrongPassword(item.password)) return 'Password is too weak.';
    if (item.password != item.confirmPassword) return 'Passwords do not match.';
    if (!item.acceptsTerms || !item.acceptsPrivacy || !item.confirmsAccuracy) {
      return 'Accept the agreements and confirm your information.';
    }
    return null;
  }

  static bool isStrongPassword(String value) => PasswordPolicy.isStrong(value);

  static bool _isAdult(String value) {
    final date = DateTime.tryParse(value);
    if (date == null) return false;
    final now = DateTime.now();
    var age = now.year - date.year;
    if (DateTime(now.year, date.month, date.day).isAfter(now)) age--;
    return age >= 18;
  }
}
