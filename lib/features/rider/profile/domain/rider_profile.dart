import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

export 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
export 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

class RiderProfile {
  const RiderProfile({
    required this.id,
    required this.logisticCompanyId,
    required this.licenseNumber,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.vehicleType,
    required this.vehiclePlateNumber,
    required this.availabilityStatus,
    required this.rating,
    required this.contactNumber,
    required this.email,
    required this.gpsLatitude,
    required this.gpsLongitude,
    required this.totalDeliveries,
    required this.employmentStatus,
    required this.profilePhotoUrl,
    this.serviceArea = '',
    this.serviceRadiusKm,
    this.capacityKg,
    this.handlingCapabilityKeys = const <String>{},
    this.maximumActiveDeliveries = 1,
  });

  factory RiderProfile.fromRegistration(
    RiderRegistration registration, {
    required String id,
  }) {
    final vehicleType = registration.vehicleType;
    if (vehicleType == null) {
      throw StateError('A vehicle type is required for rider registration.');
    }
    return RiderProfile(
      id: id,
      logisticCompanyId: _blankToNull(registration.logisticsCompanyId ?? ''),
      licenseNumber: registration.licenseNumber.trim().toUpperCase(),
      fullName: registration.fullName,
      firstName: registration.firstName.trim(),
      lastName: registration.lastName.trim(),
      vehicleType: vehicleType,
      vehiclePlateNumber: registration.vehiclePlateNumber.trim().toUpperCase(),
      availabilityStatus: RiderAvailability.offline,
      rating: 0,
      contactNumber: registration.contactNumber.trim(),
      email: registration.email.trim().toLowerCase(),
      gpsLatitude: registration.gpsLatitude,
      gpsLongitude: registration.gpsLongitude,
      totalDeliveries: 0,
      employmentStatus: RiderEmploymentStatus.pending,
      profilePhotoUrl: _blankToNull(registration.profilePhotoPath ?? ''),
    );
  }

  final String id;
  final String? logisticCompanyId;
  final String licenseNumber;
  final String fullName;
  final String firstName;
  final String lastName;
  final RiderVehicleType vehicleType;
  final String vehiclePlateNumber;
  final RiderAvailability availabilityStatus;
  final double rating;
  final String contactNumber;
  final String email;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final int totalDeliveries;
  final RiderEmploymentStatus employmentStatus;
  final String? profilePhotoUrl;
  final String serviceArea;
  final double? serviceRadiusKm;
  final double? capacityKg;
  final Set<String> handlingCapabilityKeys;
  final int maximumActiveDeliveries;

  RiderVerificationStatus get verificationStatus => switch (employmentStatus) {
    RiderEmploymentStatus.pending => RiderVerificationStatus.pending,
    RiderEmploymentStatus.active => RiderVerificationStatus.verified,
    RiderEmploymentStatus.inactive => RiderVerificationStatus.rejected,
    RiderEmploymentStatus.suspended => RiderVerificationStatus.suspended,
  };

  bool get canAcceptDeliveries =>
      employmentStatus == RiderEmploymentStatus.active;

  String get gpsLabel {
    final latitude = gpsLatitude;
    final longitude = gpsLongitude;
    if (latitude == null || longitude == null) {
      return 'GPS location unavailable';
    }
    return '${latitude.toStringAsFixed(5)}, ${longitude.toStringAsFixed(5)}';
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

  RiderProfile copyWith({
    String? fullName,
    String? contactNumber,
    String? logisticCompanyId,
    String? licenseNumber,
    String? vehiclePlateNumber,
    String? profilePhotoUrl,
    RiderAvailability? availabilityStatus,
    RiderEmploymentStatus? employmentStatus,
  }) {
    final names = _splitName(fullName ?? this.fullName);
    return RiderProfile(
      id: id,
      logisticCompanyId: _blankToNull(
        logisticCompanyId ?? this.logisticCompanyId ?? '',
      ),
      licenseNumber: licenseNumber ?? this.licenseNumber,
      fullName: names.fullName,
      firstName: names.firstName,
      lastName: names.lastName,
      vehicleType: vehicleType,
      vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
      rating: rating,
      contactNumber: contactNumber ?? this.contactNumber,
      email: email,
      gpsLatitude: gpsLatitude,
      gpsLongitude: gpsLongitude,
      totalDeliveries: totalDeliveries,
      employmentStatus: employmentStatus ?? this.employmentStatus,
      profilePhotoUrl: _blankToNull(
        profilePhotoUrl ?? this.profilePhotoUrl ?? '',
      ),
      serviceArea: serviceArea,
      serviceRadiusKm: serviceRadiusKm,
      capacityKg: capacityKg,
      handlingCapabilityKeys: handlingCapabilityKeys,
      maximumActiveDeliveries: maximumActiveDeliveries,
    );
  }
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
