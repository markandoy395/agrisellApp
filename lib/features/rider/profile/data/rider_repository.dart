import 'dart:typed_data';

import 'package:agresell_app/features/rider/profile/domain/rider.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_document.dart';
import 'package:agresell_app/features/rider/profile/domain/rider_vehicle.dart';
import 'package:agresell_app/features/rider/deliveries/domain/rider_location.dart';

typedef RiderUploadProgress = void Function(double progress);

class RiderDocumentUpload {
  const RiderDocumentUpload({
    required this.bytes,
    required this.extension,
    required this.contentType,
    required this.documentType,
    this.vehicleId,
  });

  final Uint8List bytes;
  final String extension;
  final String contentType;
  final RiderDocumentType documentType;
  final String? vehicleId;
}

class RiderRegistrationEntities {
  const RiderRegistrationEntities({
    required this.rider,
    required this.vehicle,
    this.location,
  });

  final Rider rider;
  final RiderVehicle vehicle;
  final RiderLocation? location;
}

abstract interface class RiderRepository {
  Future<Rider> createRider(Rider rider);
  Future<Rider?> getCurrentRider();
  Future<Rider> updateRider(Rider rider);
  Future<Rider> updateRiderAvailability(
    String riderId,
    RiderDatabaseAvailability status,
  );
  Future<Rider> updateRiderDeliveryStatus(
    String riderId,
    RiderDeliveryProgress status,
  );
  Future<Rider> updateRiderOperationalStatus(
    String riderId, {
    required RiderDatabaseAvailability availability,
    required RiderDeliveryProgress delivery,
  });

  Future<RiderVehicle> createVehicle(RiderVehicle vehicle);
  Future<List<RiderVehicle>> getRiderVehicles(String riderId);
  Future<RiderVehicle> updateVehicle(RiderVehicle vehicle);
  Future<void> deleteVehicle(String vehicleId);

  Future<String> uploadRiderDocument(
    RiderDocumentUpload upload, {
    RiderUploadProgress? onProgress,
  });
  Future<RiderDocument> saveRiderDocumentRecord(RiderDocument document);
  Future<List<RiderDocument>> getRiderDocuments(String riderId);
  Future<RiderDocument> replaceRiderDocument(
    RiderDocument current,
    RiderDocumentUpload upload, {
    RiderUploadProgress? onProgress,
  });
  Future<void> deleteRiderDocument(RiderDocument document);
  Future<String> createDocumentSignedUrl(String path);
  Future<void> removeRiderFile(String path);
  Future<String> uploadProfilePhoto(
    Uint8List bytes, {
    required String extension,
    required String contentType,
    RiderUploadProgress? onProgress,
  });

  Future<RiderLocation> upsertRiderLocation(RiderLocation location);
  Future<RiderLocation?> getCurrentRiderLocation(String riderId);
  Future<RiderRegistrationEntities> createRegistration({
    required Rider rider,
    required RiderVehicle vehicle,
    RiderLocation? location,
    Map<String, Object?> registrationData = const {},
  });
}
