import 'dart:typed_data';
import 'package:agresell_app/core/services/authenticated_storage_image.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:agresell_app/core/services/agrisell_supabase.dart';
import 'package:agresell_app/features/rider/profile/data/rider_remote_data_source.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';

part 'supabase_rider_document_data_source.dart';

class SupabaseRiderDataSource
    with _SupabaseRiderDocumentDataSourceMixin
    implements RiderRemoteDataSource {
  SupabaseRiderDataSource({SupabaseClient? client}) : _providedClient = client;

  static const bucket = 'rider-documents';
  final SupabaseClient? _providedClient;
  @override
  SupabaseClient get _client => _providedClient ?? AgrisellSupabase.client;

  @override
  String get currentAuthId {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthException('Authentication is required.');
    return id;
  }

  @override
  Future<Rider> createRider(Rider rider) async {
    final row = await _client
        .from('riders')
        .insert(_writableRider(rider.toJson()))
        .select()
        .single();
    return Rider.fromJson(_map(row));
  }

  @override
  Future<Rider?> getCurrentRider() async {
    final row = await _client.from('riders').select().maybeSingle();
    return row == null ? null : Rider.fromJson(_map(row));
  }

  @override
  Future<Rider> updateRider(String riderId, Map<String, Object?> values) async {
    final row = await _client
        .from('riders')
        .update(values)
        .eq('rider_id', riderId)
        .select()
        .single();
    return Rider.fromJson(_map(row));
  }

  @override
  Future<RiderVehicle> createVehicle(RiderVehicle vehicle) async {
    final rider = await updateRider(vehicle.riderId, {
      'vehicle_type': vehicle.vehicleType,
      'vehicle_plate_number': vehicle.plateNumber,
    });
    return _embeddedVehicle(rider);
  }

  @override
  Future<List<RiderVehicle>> getVehicles(String riderId) async {
    final rider = await getCurrentRider();
    return rider == null || rider.riderId != riderId
        ? const []
        : [_embeddedVehicle(rider)];
  }

  @override
  Future<RiderVehicle> updateVehicle(
    String vehicleId,
    Map<String, Object?> values,
  ) async {
    final rider = await updateRider(vehicleId, {
      if (values.containsKey('vehicle_type'))
        'vehicle_type': values['vehicle_type'],
      if (values.containsKey('plate_number'))
        'vehicle_plate_number': values['plate_number'],
    });
    return _embeddedVehicle(rider);
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    await updateRider(vehicleId, {
      'vehicle_type': '',
      'vehicle_plate_number': null,
    });
  }

  @override
  Future<RiderLocation> upsertLocation(RiderLocation location) async {
    final row = await _client
        .from('rider_locations')
        .upsert(location.toDatabaseJson(), onConflict: 'rider_id')
        .select()
        .single();
    return RiderLocation.fromDatabaseJson(_map(row));
  }

  @override
  Future<RiderLocation?> getLocation(String riderId) async {
    final row = await _client
        .from('rider_locations')
        .select()
        .eq('rider_id', riderId)
        .maybeSingle();
    return row == null ? null : RiderLocation.fromDatabaseJson(_map(row));
  }

  @override
  Future<RiderRegistrationEntities> createRegistration({
    required Rider rider,
    required RiderVehicle vehicle,
    RiderLocation? location,
    Map<String, Object?> registrationData = const {},
  }) async {
    final result = await _client.rpc<Object?>(
      'create_current_rider_registration',
      params: {
        'rider_payload': {..._registrationRider(rider), ...registrationData},
      },
    );
    final registered = Rider.fromJson(_map(result));
    return RiderRegistrationEntities(
      rider: registered,
      vehicle: _embeddedVehicle(registered),
      location: location,
    );
  }
}

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
  capacityKg: 0,
);
Map<String, Object?> _selectKeys(
  Map<String, Object?> source,
  Set<String> keys,
) => {
  for (final key in keys)
    if (source.containsKey(key)) key: source[key],
};
