import 'dart:typed_data';

import 'package:agresell_app/features/rider/profile/data/rider_repository.dart';
import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';

abstract interface class RiderRemoteDataSource {
  Future<Rider> createRider(Rider rider);
  Future<Rider?> getCurrentRider();
  Future<Rider> updateRider(String riderId, Map<String, Object?> values);
  Future<RiderVehicle> createVehicle(RiderVehicle vehicle);
  Future<List<RiderVehicle>> getVehicles(String riderId);
  Future<RiderVehicle> updateVehicle(
    String vehicleId,
    Map<String, Object?> values,
  );
  Future<void> deleteVehicle(String vehicleId);
  Future<String> uploadObject({
    required String path,
    required Uint8List bytes,
    required String contentType,
  });
  Future<void> deleteObject(String path);
  Future<String> createSignedUrl(String path);
  Future<RiderDocument> createDocument(RiderDocument document);
  Future<List<RiderDocument>> getDocuments(String riderId);
  Future<RiderDocument> updateDocument(
    String documentId,
    Map<String, Object?> values,
  );
  Future<void> deleteDocument(String documentId);
  Future<RiderLocation> upsertLocation(RiderLocation location);
  Future<RiderLocation?> getLocation(String riderId);
  Future<RiderRegistrationEntities> createRegistration({
    required Rider rider,
    required RiderVehicle vehicle,
    RiderLocation? location,
    Map<String, Object?> registrationData = const {},
  });
  String get currentAuthId;
}
