part of 'rider_registration_service.dart';

extension _RiderRegistrationServiceProfileUpdater on RiderRegistrationService {
  Future<RiderProfile> _saveCurrentProfile(RiderProfile profile) async {
    if (!AgrisellSupabase.isInitialized) return updateCurrentProfile(profile);
    final rider = _currentRider;
    final vehicle = _currentVehicle;
    if (rider == null || vehicle == null) {
      throw const RiderRegistrationException('Rider profile is unavailable.');
    }
    try {
      _currentRider = await _repository.updateRider(
        rider.copyWith(
          fullName: profile.fullName,
          firstName: profile.firstName,
          lastName: profile.lastName,
          contactNumber: profile.contactNumber,
          licenseNumber: profile.licenseNumber,
          locationLabel: profile.address,
          addressLine: profile.addressLine,
          barangay: profile.barangay,
          cityMunicipality: profile.cityMunicipality,
          province: profile.province,
          postalCode: profile.postalCode,
          gpsLatitude: profile.gpsLatitude,
          gpsLongitude: profile.gpsLongitude,
        ),
      );
      _currentVehicle = await _repository.updateVehicle(
        vehicle.copyWith(
          plateNumber: profile.vehicleType.requiresPlate
              ? profile.vehiclePlateNumber
              : vehicle.plateNumber,
        ),
      );
      final license = _currentDocuments
          .where(
            (item) => item.documentType == RiderDocumentType.driversLicense,
          )
          .firstOrNull;
      if (profile.vehicleType.requiresLicense &&
          license != null &&
          profile.licenseNumber != license.documentNumber) {
        await _repository.saveRiderDocumentRecord(
          license.copyWith(documentNumber: profile.licenseNumber),
        );
      }
      return (await _loadRemoteProfile(force: true))!;
    } on RiderRepositoryException catch (error) {
      throw RiderRegistrationException(error.message);
    }
  }
}
