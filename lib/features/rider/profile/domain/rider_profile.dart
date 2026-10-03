import 'package:agresell_app/core/utils/written_address.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_address.dart';

export 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
export 'package:agresell_app/features/rider/profile/domain/rider_registration.dart';

part 'rider_profile_details.dart';

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
    this.address = '',
    this.addressLine = '',
    this.barangay = '',
    this.cityMunicipality = '',
    this.province = '',
    this.postalCode = '',
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
      address: registration.locationLabel,
      addressLine: registration.addressLine,
      barangay: registration.barangay,
      cityMunicipality: registration.cityMunicipality,
      province: registration.province,
      postalCode: registration.postalCode,
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
  final String address;
  final String addressLine;
  final String barangay;
  final String cityMunicipality;
  final String province;
  final String postalCode;
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
    RiderEmploymentStatus.inactive => RiderVerificationStatus.pending,
    RiderEmploymentStatus.suspended => RiderVerificationStatus.suspended,
  };

  bool get canAcceptDeliveries =>
      employmentStatus == RiderEmploymentStatus.active;


  RiderProfile copyWith({
    String? fullName,
    String? contactNumber,
    String? logisticCompanyId,
    String? licenseNumber,
    String? vehiclePlateNumber,
    String? profilePhotoUrl,
    RiderAvailability? availabilityStatus,
    RiderEmploymentStatus? employmentStatus,
    String? address,
    String? addressLine,
    String? barangay,
    String? cityMunicipality,
    String? province,
    String? postalCode,
    double? gpsLatitude,
    double? gpsLongitude,
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
      gpsLatitude: gpsLatitude ?? this.gpsLatitude,
      gpsLongitude: gpsLongitude ?? this.gpsLongitude,
      address: address ?? this.address,
      addressLine: addressLine ?? this.addressLine,
      barangay: barangay ?? this.barangay,
      cityMunicipality: cityMunicipality ?? this.cityMunicipality,
      province: province ?? this.province,
      postalCode: postalCode ?? this.postalCode,
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

