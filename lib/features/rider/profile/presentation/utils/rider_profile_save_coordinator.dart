import 'package:agresell_app/features/rider/profile/domain/rider_address.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_profile.dart';

abstract final class RiderProfileSaveCoordinator {
  static bool validate({
    required RiderProfile profile,
    required String firstName,
    required String lastName,
    required String contact,
    required String license,
    required String plate,
    required String street,
    required String province,
    required String city,
    required String barangay,
  }) {
    final completeAddress = RiderAddress.isComplete(
      addressLine: street,
      barangay: barangay,
      cityMunicipality: city,
      province: province,
    );
    final requiredFields = [
      firstName,
      lastName,
      contact,
      if (profile.vehicleType.requiresLicense) license,
      if (profile.vehicleType.requiresPlate) plate,
    ];
    return !requiredFields.any((item) => item.trim().isEmpty) && completeAddress;
  }

  static RiderProfile buildUpdatedProfile({
    required RiderProfile original,
    required String firstName,
    required String lastName,
    required String contact,
    required String license,
    required String plate,
    required String street,
    required String province,
    required String city,
    required String barangay,
    required String postal,
    required double? latitude,
    required double? longitude,
  }) => original.copyWith(
    fullName: '${firstName.trim()} ${lastName.trim()}',
    contactNumber: contact.trim(),
    licenseNumber: original.vehicleType.requiresLicense
        ? license.trim().toUpperCase()
        : original.licenseNumber,
    vehiclePlateNumber: original.vehicleType.requiresPlate
        ? plate.trim().toUpperCase()
        : original.vehiclePlateNumber,
    addressLine: street.trim(),
    barangay: barangay.trim(),
    cityMunicipality: city.trim(),
    province: province.trim(),
    postalCode: postal.trim(),
    address: RiderAddress.format(
      addressLine: street,
      barangay: barangay,
      cityMunicipality: city,
      province: province,
      postalCode: postal,
    ),
    gpsLatitude: latitude,
    gpsLongitude: longitude,
  );
}
