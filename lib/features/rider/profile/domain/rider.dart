import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_json.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_status.dart';

export 'package:agresell_app/features/rider/profile/domain/rider_status.dart';

class Rider {
  const Rider({
    required this.riderId,
    required this.licenseNumber,
    required this.fullName,
    required this.vehicleType,
    required this.vehiclePlateNumber,
    required this.firstName,
    required this.lastName,
    required this.contactNumber,
    required this.email,
    this.logisticsCompanyId,
    this.availabilityStatus = RiderDatabaseAvailability.offline,
    this.rating = 0,
    this.gpsLatitude,
    this.gpsLongitude,
    this.locationLabel = '',
    this.addressLine = '',
    this.barangay = '',
    this.cityMunicipality = '',
    this.province = '',
    this.postalCode = '',
    this.totalDeliveries = 0,
    this.maximumActiveDeliveries = 1,
    this.capacityKg,
    this.maximumCapacityKg,
    this.employmentStatus = RiderEmploymentStatus.inactive,
    this.profilePhotoPath,
  });

  final String riderId;
  final String? logisticsCompanyId;
  final String licenseNumber;
  final String fullName;
  final String vehicleType;
  final String vehiclePlateNumber;
  final RiderDatabaseAvailability availabilityStatus;
  final double rating;
  final String firstName;
  final String lastName;
  final String contactNumber;
  final String email;
  final double? gpsLatitude;
  final double? gpsLongitude;
  final String locationLabel;
  final String addressLine;
  final String barangay;
  final String cityMunicipality;
  final String province;
  final String postalCode;
  final int totalDeliveries;
  final int maximumActiveDeliveries;
  final double? capacityKg;
  final double? maximumCapacityKg;
  final RiderEmploymentStatus employmentStatus;
  final String? profilePhotoPath;

  RiderVerificationStatus get verificationStatus => switch (employmentStatus) {
    RiderEmploymentStatus.active => RiderVerificationStatus.verified,
    RiderEmploymentStatus.suspended => RiderVerificationStatus.suspended,
    RiderEmploymentStatus.pending => RiderVerificationStatus.pending,
    RiderEmploymentStatus.inactive => RiderVerificationStatus.pending,
  };

  RiderDeliveryProgress get deliveryStatus =>
      availabilityStatus == RiderDatabaseAvailability.busy
      ? RiderDeliveryProgress.assigned
      : RiderDeliveryProgress.waiting;

  factory Rider.fromJson(Map<String, Object?> json) => parseRiderJson(json);

  Map<String, Object?> toJson() => serializeRiderJson(this);

  Rider copyWith({
    String? licenseNumber,
    String? fullName,
    String? vehicleType,
    String? vehiclePlateNumber,
    String? firstName,
    String? lastName,
    String? contactNumber,
    String? profilePhotoPath,
    double? gpsLatitude,
    double? gpsLongitude,
    String? locationLabel,
    String? addressLine,
    String? barangay,
    String? cityMunicipality,
    String? province,
    String? postalCode,
    RiderEmploymentStatus? employmentStatus,
    RiderDatabaseAvailability? availabilityStatus,
    int? maximumActiveDeliveries,
  }) => Rider(
    riderId: riderId,
    logisticsCompanyId: logisticsCompanyId,
    licenseNumber: licenseNumber ?? this.licenseNumber,
    fullName: fullName ?? this.fullName,
    vehicleType: vehicleType ?? this.vehicleType,
    vehiclePlateNumber: vehiclePlateNumber ?? this.vehiclePlateNumber,
    availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    rating: rating,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    contactNumber: contactNumber ?? this.contactNumber,
    email: email,
    gpsLatitude: gpsLatitude ?? this.gpsLatitude,
    gpsLongitude: gpsLongitude ?? this.gpsLongitude,
    locationLabel: locationLabel ?? this.locationLabel,
    addressLine: addressLine ?? this.addressLine,
    barangay: barangay ?? this.barangay,
    cityMunicipality: cityMunicipality ?? this.cityMunicipality,
    province: province ?? this.province,
    postalCode: postalCode ?? this.postalCode,
    totalDeliveries: totalDeliveries,
    maximumActiveDeliveries:
        maximumActiveDeliveries ?? this.maximumActiveDeliveries,
    capacityKg: capacityKg,
    maximumCapacityKg: maximumCapacityKg,
    employmentStatus: employmentStatus ?? this.employmentStatus,
    profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
  );

  @override
  bool operator ==(Object other) => other is Rider && other.riderId == riderId;
  @override
  int get hashCode => riderId.hashCode;
}
