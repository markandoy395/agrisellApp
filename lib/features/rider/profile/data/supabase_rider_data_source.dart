import 'dart:typed_data';
import 'package:agresell_app/core/services/query_owner.dart';
import 'package:agresell_app/core/services/profile_rpc.dart';
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
part 'supabase_rider_values.dart';

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
    final row = await _client.rpc<Object?>(
      'create_current_rider_registration',
      params: {'rider_payload': _registrationRider(rider)},
    );
    return Rider.fromJson(_map(row));
  }

  @override
  Future<Rider?> getCurrentRider() async {
    final riderId = (await QueryOwner(_client).identity())['rider_id'];
    if (riderId == null) return null;
    final row = await _client
        .from('riders')
        .select()
        .eq('rider_id', riderId)
        .maybeSingle();
    return row == null ? null : Rider.fromJson(_map(row));
  }

  @override
  Future<Rider> updateRider(String riderId, Map<String, Object?> values) async {
    await QueryOwner(_client).requireRiderId(riderId);
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
    await QueryOwner(_client).requireRiderId(vehicleId);
    final row = await invokeProfileRpc(
      _client,
      'update_current_rider_vehicle',
      {'vehicle_payload': values},
    );
    return _embeddedVehicle(Rider.fromJson(_map(row)));
  }

  Future<void> setCapacity(double capacityKg) async {
    await _client.rpc<Object?>(
      'set_current_rider_capacity',
      params: {'p_capacity_kg': capacityKg},
    );
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
    await QueryOwner(_client).requireRiderId(location.riderId);
    final row = await _client
        .from('rider_locations')
        .upsert(location.toDatabaseJson(), onConflict: 'rider_id')
        .select()
        .single();
    return RiderLocation.fromDatabaseJson(_map(row));
  }

  @override
  Future<RiderLocation?> getLocation(String riderId) async {
    await QueryOwner(_client).requireRiderId(riderId);
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
