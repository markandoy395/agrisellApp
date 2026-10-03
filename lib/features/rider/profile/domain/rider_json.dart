import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';

String riderText(Object? value) => value?.toString().trim() ?? '';
String? riderNullableText(Object? value) => riderBlankToNull(value?.toString());
String? riderBlankToNull(String? value) => switch (value?.trim()) {
  final text? when text.isNotEmpty => text,
  _ => null,
};
double riderNumber(Object? value) => riderNullableNumber(value) ?? 0;
double? riderNullableNumber(Object? value) =>
    value is num ? value.toDouble() : double.tryParse(value?.toString() ?? '');
int riderInteger(Object? value) =>
    value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;
int riderPositiveInteger(Object? value) {
  final parsed = riderInteger(value);
  return parsed > 0 ? parsed : 1;
}

Rider parseRiderJson(Map<String, Object?> json) => Rider(
  riderId: riderText(json['rider_id']),
  logisticsCompanyId: riderNullableText(json['logistics_company_id']),
  licenseNumber: riderText(json['license_number']),
  fullName: riderText(json['full_name']),
  vehicleType: riderText(json['vehicle_type']),
  vehiclePlateNumber: riderText(json['vehicle_plate_number']),
  availabilityStatus: RiderDatabaseAvailability.values.firstWhere(
    (item) => item.name == json['availability_status'],
    orElse: () => RiderDatabaseAvailability.offline,
  ),
  rating: riderNumber(json['rating']),
  firstName: riderText(json['first_name']),
  lastName: riderText(json['last_name']),
  contactNumber: riderText(json['contact_number']),
  email: riderText(json['email']),
  gpsLatitude: riderNullableNumber(json['gps_lat']),
  gpsLongitude: riderNullableNumber(json['gps_long']),
  locationLabel: riderText(json['location_label']),
  addressLine: riderText(json['address_line']),
  barangay: riderText(json['barangay']),
  cityMunicipality: riderText(json['city_municipality']),
  province: riderText(json['province']),
  postalCode: riderText(json['postal_code']),
  totalDeliveries: riderInteger(json['total_deliveries']),
  maximumActiveDeliveries: riderPositiveInteger(
    json['maximum_active_deliveries'],
  ),
  employmentStatus: RiderEmploymentStatus.values.firstWhere(
    (item) => item.name == json['employment_status'],
    orElse: () => RiderEmploymentStatus.inactive,
  ),
  profilePhotoPath: riderNullableText(json['profile_photo_url']),
);

Map<String, Object?> serializeRiderJson(Rider rider) => {
  if (rider.riderId.isNotEmpty) 'rider_id': rider.riderId,
  'logistics_company_id': rider.logisticsCompanyId,
  'license_number': riderBlankToNull(rider.licenseNumber)?.toUpperCase(),
  'full_name': rider.fullName.trim(),
  'vehicle_type': rider.vehicleType.trim(),
  'vehicle_plate_number':
      riderBlankToNull(rider.vehiclePlateNumber)?.toUpperCase(),
  'availability_status': rider.availabilityStatus.name,
  'rating': rider.rating,
  'first_name': rider.firstName.trim(),
  'last_name': rider.lastName.trim(),
  'contact_number': rider.contactNumber.trim(),
  'email': rider.email.trim().toLowerCase(),
  'gps_lat': rider.gpsLatitude,
  'gps_long': rider.gpsLongitude,
  'location_label': riderBlankToNull(rider.locationLabel),
  'address_line': riderBlankToNull(rider.addressLine),
  'barangay': riderBlankToNull(rider.barangay),
  'city_municipality': riderBlankToNull(rider.cityMunicipality),
  'province': riderBlankToNull(rider.province),
  'postal_code': riderBlankToNull(rider.postalCode),
  'total_deliveries': rider.totalDeliveries,
  'maximum_active_deliveries': rider.maximumActiveDeliveries,
  'employment_status': rider.employmentStatus == RiderEmploymentStatus.pending
      ? RiderEmploymentStatus.inactive.name
      : rider.employmentStatus.name,
  'profile_photo_url': riderBlankToNull(rider.profilePhotoPath),
};
