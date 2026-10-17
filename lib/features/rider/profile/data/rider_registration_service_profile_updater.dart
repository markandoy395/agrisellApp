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
          vehiclePlateNumber: profile.vehicleType.requiresPlate
              ? profile.vehiclePlateNumber
              : rider.vehiclePlateNumber,
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
      return (await _loadRemoteProfile(force: true))!;
    } on RiderRepositoryException catch (error) {
      throw RiderRegistrationException(error.message);
    }
  }
}
