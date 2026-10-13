part of 'supabase_rider_data_source.dart';

Map<String, Object?> _map(Object? value) => value is Map
    ? {for (final entry in value.entries) '${entry.key}': entry.value}
    : const {};

Map<String, Object?> _writableRider(Map<String, Object?> source) =>
    _selectKeys(source, const {
      'rider_id',
      'logistics_company_id',
      'license_number',
      'full_name',
      'vehicle_type',
      'vehicle_plate_number',
      'availability_status',
      'rating',
      'first_name',
      'last_name',
      'email',
      'contact_number',
      'profile_photo_url',
      'gps_lat',
      'gps_long',
      'location_label',
      'address_line',
      'barangay',
      'city_municipality',
      'province',
      'postal_code',
      'total_deliveries',
      'maximum_active_deliveries',
      'employment_status',
    });
Map<String, Object?> _registrationRider(Rider rider) =>
    _writableRider(rider.toJson())..remove('rider_id');

RiderVehicle _embeddedVehicle(Rider rider) => RiderVehicle(
  vehicleId: rider.riderId,
  riderId: rider.riderId,
  vehicleType: rider.vehicleType,
  vehicleModel: '',
  vehicleColor: '',
  plateNumber: rider.vehiclePlateNumber,
  capacityKg: rider.capacityKg ?? 0,
  maximumCapacityKg: rider.maximumCapacityKg,
);
Map<String, Object?> _selectKeys(
  Map<String, Object?> source,
  Set<String> keys,
) => {
  for (final key in keys)
    if (source.containsKey(key)) key: source[key],
};
