import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
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

  factory Rider.fromJson(Map<String, Object?> json) => Rider(
    riderId: _text(json['rider_id']),
    logisticsCompanyId: _nullableText(json['logistics_company_id']),
    licenseNumber: _text(json['license_number']),
    fullName: _text(json['full_name']),
    vehicleType: _text(json['vehicle_type']),
    vehiclePlateNumber: _text(json['vehicle_plate_number']),
    availabilityStatus: RiderDatabaseAvailability.values.firstWhere(
      (item) => item.name == json['availability_status'],
      orElse: () => RiderDatabaseAvailability.offline,
    ),
    rating: _number(json['rating']),
    firstName: _text(json['first_name']),
    lastName: _text(json['last_name']),
    contactNumber: _text(json['contact_number']),
    email: _text(json['email']),
    gpsLatitude: _nullableNumber(json['gps_lat']),
    gpsLongitude: _nullableNumber(json['gps_long']),
    locationLabel: _text(json['location_label']),
    addressLine: _text(json['address_line']),
    barangay: _text(json['barangay']),
    cityMunicipality: _text(json['city_municipality']),
    province: _text(json['province']),
    postalCode: _text(json['postal_code']),
    totalDeliveries: _integer(json['total_deliveries']),
    maximumActiveDeliveries: _positiveInteger(
      json['maximum_active_deliveries'],
    ),
    employmentStatus: RiderEmploymentStatus.values.firstWhere(
      (item) => item.name == json['employment_status'],
      orElse: () => RiderEmploymentStatus.inactive,
    ),
    profilePhotoPath: _nullableText(json['profile_photo_url']),
  );

  Map<String, Object?> toJson() => {
    if (riderId.isNotEmpty) 'rider_id': riderId,
    'logistics_company_id': logisticsCompanyId,
    'license_number': _blankToNull(licenseNumber)?.toUpperCase(),
    'full_name': fullName.trim(),
    'vehicle_type': vehicleType.trim(),
    'vehicle_plate_number': _blankToNull(vehiclePlateNumber)?.toUpperCase(),
    'availability_status': availabilityStatus.name,
    'rating': rating,
    'first_name': firstName.trim(),
    'last_name': lastName.trim(),
    'contact_number': contactNumber.trim(),
    'email': email.trim().toLowerCase(),
    'gps_lat': gpsLatitude,
    'gps_long': gpsLongitude,
    'location_label': _blankToNull(locationLabel),
    'address_line': _blankToNull(addressLine),
    'barangay': _blankToNull(barangay),
    'city_municipality': _blankToNull(cityMunicipality),
    'province': _blankToNull(province),
    'postal_code': _blankToNull(postalCode),
    'total_deliveries': totalDeliveries,
    'maximum_active_deliveries': maximumActiveDeliveries,
    'employment_status': employmentStatus == RiderEmploymentStatus.pending
        ? RiderEmploymentStatus.inactive.name
        : employmentStatus.name,
    'profile_photo_url': _blankToNull(profilePhotoPath),
  };

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
    employmentStatus: employmentStatus ?? this.employmentStatus,
    profilePhotoPath: profilePhotoPath ?? this.profilePhotoPath,
  );

  @override
  bool operator ==(Object other) => other is Rider && other.riderId == riderId;
  @override
  int get hashCode => riderId.hashCode;
}

String _text(Object? value) => value?.toString().trim() ?? '';
String? _nullableText(Object? value) => _blankToNull(value?.toString());
String? _blankToNull(String? value) => switch (value?.trim()) {
  final text? when text.isNotEmpty => text,
  _ => null,
};
double _number(Object? value) => _nullableNumber(value) ?? 0;
double? _nullableNumber(Object? value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
int _integer(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
int _positiveInteger(Object? value) {
  final parsed = _integer(value);
  return parsed > 0 ? parsed : 1;
}
