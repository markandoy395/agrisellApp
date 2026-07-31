import 'dart:typed_data';

import 'package:agresell_app/features/rider/profile/data/rider_error_mapper.dart';
import 'package:agresell_app/features/rider/profile/data/rider_remote_data_source.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository_exception.dart';
import 'package:agresell_app/features/rider/profile/data/supabase_rider_data_source.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_entity_validator.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';

part 'rider_repository_impl_documents.dart';

class RiderRepositoryImpl
    with _RiderRepositoryDocumentOperations
    implements RiderRepository {
  RiderRepositoryImpl({RiderRemoteDataSource? remote})
    : _source = remote ?? SupabaseRiderDataSource();

  @override
  final RiderRemoteDataSource _source;

  @override
  Future<Rider> createRider(Rider rider) => guardRiderOperation(() {
    RiderEntityValidator.rider(rider);
    return _source.createRider(rider);
  });

  @override
  Future<Rider?> getCurrentRider() =>
      guardRiderOperation(_source.getCurrentRider);

  @override
  Future<Rider> updateRider(Rider rider) => guardRiderOperation(() {
    RiderEntityValidator.rider(rider);
    return _source.updateRider(rider.riderId, _riderUpdate(rider));
  });

  @override
  Future<Rider> updateRiderAvailability(
    String riderId,
    RiderDatabaseAvailability status,
  ) => guardRiderOperation(
    () => _source.updateRider(riderId, {'availability_status': status.name}),
  );

  @override
  Future<Rider> updateRiderDeliveryStatus(
    String riderId,
    RiderDeliveryProgress status,
  ) => guardRiderOperation(
    () => _source.updateRider(riderId, {
      'availability_status':
          status == RiderDeliveryProgress.waiting ||
              status == RiderDeliveryProgress.completed
          ? RiderDatabaseAvailability.online.name
          : RiderDatabaseAvailability.busy.name,
    }),
  );

  @override
  Future<Rider> updateRiderOperationalStatus(
    String riderId, {
    required RiderDatabaseAvailability availability,
    required RiderDeliveryProgress delivery,
  }) => guardRiderOperation(
    () => _source.updateRider(riderId, {
      'availability_status': availability.name,
    }),
  );

  @override
  Future<RiderVehicle> createVehicle(RiderVehicle vehicle) =>
      guardRiderOperation(() {
        RiderEntityValidator.vehicle(vehicle);
        return _source.createVehicle(vehicle);
      });

  @override
  Future<List<RiderVehicle>> getRiderVehicles(String riderId) =>
      guardRiderOperation(() => _source.getVehicles(riderId));

  @override
  Future<RiderVehicle> updateVehicle(RiderVehicle vehicle) =>
      guardRiderOperation(() {
        RiderEntityValidator.vehicle(vehicle);
        final values = vehicle.toJson()
          ..remove('vehicle_id')
          ..remove('rider_id')
          ..remove('verification_status');
        return _source.updateVehicle(vehicle.vehicleId, values);
      });

  @override
  Future<void> deleteVehicle(String vehicleId) =>
      guardRiderOperation(() => _source.deleteVehicle(vehicleId));

  @override
  Future<RiderLocation> upsertRiderLocation(RiderLocation location) =>
      guardRiderOperation(() {
        RiderEntityValidator.location(location);
        return _source.upsertLocation(location);
      });

  @override
  Future<RiderLocation?> getCurrentRiderLocation(String riderId) =>
      guardRiderOperation(() => _source.getLocation(riderId));

  @override
  Future<RiderRegistrationEntities> createRegistration({
    required Rider rider,
    required RiderVehicle vehicle,
    RiderLocation? location,
    Map<String, Object?> registrationData = const {},
  }) => guardRiderOperation(() {
    RiderEntityValidator.rider(rider);
    return _source.createRegistration(
      rider: rider,
      vehicle: vehicle,
      location: location,
      registrationData: registrationData,
    );
  });
}

Map<String, Object?> _riderUpdate(Rider rider) {
  final values = rider.toJson();
  const protected = {
    'rider_id',
    'logistics_company_id',
    'email',
    'availability_status',
    'employment_status',
    'rating',
    'total_deliveries',
  };
  for (final key in protected) {
    values.remove(key);
  }
  return values;
}
