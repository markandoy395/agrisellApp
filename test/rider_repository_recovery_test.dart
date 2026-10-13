import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import 'package:agresell_app/features/rider/profile/data/rider_remote_data_source.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository_exception.dart';
import 'package:agresell_app/features/rider/profile/data/rider_repository_impl.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';

void main() {
  test('failed document record update removes the new upload', () async {
    final remote = _RecoveryRemote()..failDocumentUpdate = true;
    final repository = RiderRepositoryImpl(remote: remote);
    final current = RiderDocument(
      documentId: 'document-1',
      riderId: 'rider-1',
      documentType: RiderDocumentType.validId,
      filePath: 'auth-1/personal/valid_id_old.jpg',
    );

    await expectLater(
      repository.replaceRiderDocument(
        current,
        RiderDocumentUpload(
          bytes: Uint8List.fromList([1]),
          extension: 'jpg',
          contentType: 'image/jpeg',
          documentType: RiderDocumentType.validId,
        ),
      ),
      throwsA(isA<RiderRepositoryException>()),
    );
    expect(remote.events, ['upload', 'record', 'delete']);
    expect(remote.deletedPaths.single, contains('valid_id_'));
  });

  test(
    'repository retrieves the current Rider and updates a vehicle',
    () async {
      final remote = _RecoveryRemote();
      final repository = RiderRepositoryImpl(remote: remote);

      final rider = await repository.getCurrentRider();
      await expectLater(
        repository.updateVehicle(_vehicle.copyWith(capacityKg: 31)),
        throwsA(isA<RiderRepositoryException>()),
      );
      expect(remote.events, isEmpty);
      final vehicle = await repository.updateVehicle(_vehicle);

      expect(rider?.riderId, 'rider-1');
      expect(vehicle.vehicleColor, 'Green');
      expect(remote.events, ['vehicle']);
    },
  );
}

const _vehicle = RiderVehicle(
  vehicleId: 'vehicle-1',
  riderId: 'rider-1',
  vehicleType: 'motorcycle',
  vehicleModel: 'TMX',
  vehicleColor: 'Green',
  plateNumber: 'ABC1234',
  capacityKg: 30,
);

class _RecoveryRemote extends Fake implements RiderRemoteDataSource {
  bool failDocumentUpdate = false;
  final List<String> events = [];
  final List<String> deletedPaths = [];

  @override
  String get currentAuthId => 'auth-1';

  @override
  Future<String> uploadObject({
    required String path,
    required Uint8List bytes,
    required String contentType,
  }) async {
    events.add('upload');
    return path;
  }

  @override
  Future<RiderDocument> updateDocument(
    String documentId,
    Map<String, Object?> values,
  ) async {
    events.add('record');
    if (failDocumentUpdate) throw Exception('database unavailable');
    throw UnimplementedError();
  }

  @override
  Future<void> deleteObject(String path) async {
    events.add('delete');
    deletedPaths.add(path);
  }

  @override
  Future<Rider?> getCurrentRider() async => Rider.fromJson(_riderJson);

  @override
  Future<RiderVehicle> updateVehicle(
    String vehicleId,
    Map<String, Object?> values,
  ) async {
    events.add('vehicle');
    return RiderVehicle.fromJson({
      ...values,
      'vehicle_id': vehicleId,
      'rider_id': 'rider-1',
    });
  }
}

const _riderJson = <String, Object?>{
  'rider_id': 'rider-1',
  'auth_id': 'auth-1',
  'first_name': 'Ana',
  'last_name': 'Reyes',
  'email': 'ana@example.com',
  'contact_number': '09171234567',
  'date_of_birth': '1995-04-12',
  'gender': 'Female',
  'region': 'Region X',
  'province': 'Misamis Oriental',
  'city_municipality': 'Cagayan de Oro',
  'barangay': 'Lapasan',
  'complete_address': 'Market Road',
  'service_radius_km': 15,
};
