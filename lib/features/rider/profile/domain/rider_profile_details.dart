part of 'rider_profile.dart';

extension RiderProfileDetails on RiderProfile {
  String get gpsLabel {
    final latitude = gpsLatitude;
    final longitude = gpsLongitude;
    if (latitude == null || longitude == null) {
      return 'GPS location unavailable';
    }
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
  }

  String get addressLabel {
    final legacyAddress = WrittenAddress.valueOrNull(address);
    if (legacyAddress != null) return legacyAddress;
    final structuredAddress = RiderAddress.format(
      addressLine: addressLine,
      barangay: barangay,
      cityMunicipality: cityMunicipality,
      province: province,
      postalCode: postalCode,
    );
    return structuredAddress.isEmpty
        ? 'Address unavailable'
        : structuredAddress;
  }

  bool get hasRegisteredServiceCoordinates =>
      gpsLatitude != null &&
      gpsLongitude != null &&
      gpsLatitude!.isFinite &&
      gpsLongitude!.isFinite &&
      gpsLatitude! >= -90 &&
      gpsLatitude! <= 90 &&
      gpsLongitude! >= -180 &&
      gpsLongitude! <= 180;

  bool get hasRegisteredServiceArea => serviceArea.trim().isNotEmpty;

  bool get hasValidServiceRadius =>
      serviceRadiusKm != null &&
      serviceRadiusKm!.isFinite &&
      serviceRadiusKm! > 0;

  RiderProfile withVerificationStatus(RiderVerificationStatus status) =>
      copyWith(
        employmentStatus: switch (status) {
          RiderVerificationStatus.pending => RiderEmploymentStatus.pending,
          RiderVerificationStatus.verified => RiderEmploymentStatus.active,
          RiderVerificationStatus.rejected => RiderEmploymentStatus.inactive,
          RiderVerificationStatus.suspended => RiderEmploymentStatus.suspended,
        },
      );
}

_NameParts _splitName(String value) {
  final parts = value.trim().split(RegExp(r'\s+'));
  final firstName = parts.first;
  return _NameParts(parts.join(' '), firstName, parts.skip(1).join(' '));
}

String? _blankToNull(String value) {
  final cleanValue = value.trim();
  return cleanValue.isEmpty ? null : cleanValue;
}

class _NameParts {
  const _NameParts(this.fullName, this.firstName, this.lastName);
  final String fullName;
  final String firstName;
  final String lastName;
}
