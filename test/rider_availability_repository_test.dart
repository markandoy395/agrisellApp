import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/dashboard/data/supabase_rider_availability_repository.dart';
import 'package:agresell_app/features/rider/dashboard/domain/rider_availability.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';

void main() {
  test('saving online persists the database online status', () async {
    final repository = _FakeRiderRepository();
    final availability = SupabaseRiderAvailabilityRepository(
      repository: repository,
    );

    await availability.saveAvailability(
      'rider-1',
      RiderAvailability.onlineAvailable,
    );

    expect(repository.savedAvailability, RiderDatabaseAvailability.online);
  });

  test('saving online fails when the stored row remains offline', () async {
    final repository = _FakeRiderRepository(
      returnedAvailability: RiderDatabaseAvailability.offline,
    );
    final availability = SupabaseRiderAvailabilityRepository(
      repository: repository,
    );

    expect(
      () => availability.saveAvailability(
        'rider-1',
        RiderAvailability.onlineAvailable,
      ),
      throwsA(isA<StateError>()),
    );
  });
}

class _FakeRiderRepository extends Fake implements RiderRepository {
  _FakeRiderRepository({this.returnedAvailability});

  final RiderDatabaseAvailability? returnedAvailability;
  RiderDatabaseAvailability? savedAvailability;

  @override
  Future<Rider?> getCurrentRider() async => _rider();

  @override
  Future<Rider> updateRiderOperationalStatus(
    String riderId, {
    required RiderDatabaseAvailability availability,
    required RiderDeliveryProgress delivery,
  }) async {
    savedAvailability = availability;
    return _rider(availability: returnedAvailability ?? availability);
  }

  Rider _rider({
    RiderDatabaseAvailability availability = RiderDatabaseAvailability.offline,
  }) => Rider(
    riderId: 'rider-1',
    licenseNumber: 'N01-23-456789',
    fullName: 'Ana Rider',
    vehicleType: 'motorcycle',
    vehiclePlateNumber: 'ABC 1234',
    firstName: 'Ana',
    lastName: 'Rider',
    contactNumber: '09171234567',
    email: 'ana@example.com',
    availabilityStatus: availability,
    employmentStatus: RiderEmploymentStatus.active,
  );

  @override
  Future<Rider> createRider(Rider rider) => throw UnimplementedError();

  @override
  Future<Rider> updateRider(Rider rider) => throw UnimplementedError();

  @override
  Future<Rider> updateRiderAvailability(
    String riderId,
    RiderDatabaseAvailability status,
  ) => throw UnimplementedError();

  @override
  Future<Rider> updateRiderDeliveryStatus(
    String riderId,
    RiderDeliveryProgress status,
  ) => throw UnimplementedError();

  @override
  Future<RiderVehicle> createVehicle(RiderVehicle vehicle) =>
      throw UnimplementedError();

  @override
  Future<List<RiderVehicle>> getRiderVehicles(String riderId) =>
      throw UnimplementedError();

  @override
  Future<RiderVehicle> updateVehicle(RiderVehicle vehicle) =>
      throw UnimplementedError();

  @override
  Future<void> deleteVehicle(String vehicleId) => throw UnimplementedError();

  @override
  Future<String> uploadRiderDocument(
    RiderDocumentUpload upload, {
    RiderUploadProgress? onProgress,
  }) => throw UnimplementedError();

  @override
  Future<RiderDocument> saveRiderDocumentRecord(RiderDocument document) =>
      throw UnimplementedError();

  @override
  Future<List<RiderDocument>> getRiderDocuments(String riderId) =>
      throw UnimplementedError();

  @override
  Future<RiderDocument> replaceRiderDocument(
    RiderDocument current,
    RiderDocumentUpload upload, {
    RiderUploadProgress? onProgress,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteRiderDocument(RiderDocument document) =>
      throw UnimplementedError();

  @override
  Future<String> createDocumentSignedUrl(String path) =>
      throw UnimplementedError();

  @override
  Future<void> removeRiderFile(String path) => throw UnimplementedError();

  @override
  Future<String> uploadProfilePhoto(
    Uint8List bytes, {
    required String extension,
    required String contentType,
    RiderUploadProgress? onProgress,
  }) => throw UnimplementedError();

  @override
  Future<RiderLocation> upsertRiderLocation(RiderLocation location) =>
      throw UnimplementedError();

  @override
  Future<RiderLocation?> getCurrentRiderLocation(String riderId) =>
      throw UnimplementedError();

  @override
  Future<RiderRegistrationEntities> createRegistration({
    required Rider rider,
    required RiderVehicle vehicle,
    RiderLocation? location,
    Map<String, Object?> registrationData = const {},
  }) => throw UnimplementedError();
}
