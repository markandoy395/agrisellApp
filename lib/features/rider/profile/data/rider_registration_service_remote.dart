part of 'rider_registration_service.dart';

extension _RiderRegistrationServiceRemote on RiderRegistrationService {
  Future<RiderProfile> _registerRemote(
    RiderRegistration registration,
    Map<RiderDraftDocumentType, RiderDraftDocument> documents,
    RiderSignUpUploadProgress? onUploadProgress,
  ) async {
    final email = registration.email.trim().toLowerCase();
    try {
      var account = await _existingAuthenticatedRider(email);
      account ??= await AuthRegistrationService.instance.registerRider(
        SignUpAccountData(
          firstName: registration.firstName.trim(),
          middleName: registration.middleName.trim(),
          lastName: registration.lastName.trim(),
          email: email,
          password: registration.password,
          phoneNumber: registration.contactNumber,
          dateOfBirth: registration.dateOfBirth,
          gender: registration.gender,
        ),
        RiderRegistrationPayload.fromRegistration(registration),
      );
      final entities = await _repository.createRegistration(
        rider: _riderFromRegistration(registration, account.id),
        vehicle: _vehicleFromRegistration(registration, account.id),
        location: _locationFromRegistration(registration, account.id),
        registrationData: RiderRegistrationPayload.fromRegistration(
          registration,
        ),
      );
      _currentRider = entities.rider;
      _currentVehicle = entities.vehicle;
      _currentLocation = entities.location;
      await _uploadRegistrationFiles(
        registration,
        documents,
        entities,
        onUploadProgress,
      );
      final refreshedAccount = await AuthRegistrationService.instance
          .loadCurrentAccount();
      if (refreshedAccount != null) account = refreshedAccount;
      await AuthSessionService.instance.start(account, rememberMe: false);
      final profile = await _loadRemoteProfile(force: true);
      if (profile == null) {
        throw const RiderRegistrationException(
          'The Rider profile could not be loaded after submission.',
        );
      }
      return profile;
    } on RiderRegistrationException {
      rethrow;
    } on RiderRepositoryException catch (error) {
      throw RiderRegistrationException(error.message);
    } on AuthEmailConfirmationRequired {
      throw RiderEmailOtpRequired(email);
    } on AuthRegistrationException catch (error) {
      throw RiderRegistrationException(error.message);
    }
  }

  Future<RegisteredAccount?> _existingAuthenticatedRider(String email) async {
    final user = AgrisellSupabase.client.auth.currentUser;
    if (user == null || user.email?.toLowerCase() != email) return null;
    final account = await AuthRegistrationService.instance.loadCurrentAccount();
    return account?.assignedRole == AuthRole.rider ? account : null;
  }

  Future<RiderProfile?> _loadRemoteProfile({required bool force}) async {
    try {
      final rider = await _repository.getCurrentRider();
      if (rider == null) return null;
      final vehicles = await _repository.getRiderVehicles(rider.riderId);
      if (vehicles.isEmpty) {
        throw const RiderRegistrationException(
          'The Rider vehicle record is unavailable.',
        );
      }
      List<RiderDocument> documents;
      RiderLocation? location;
      try {
        documents = await _repository.getRiderDocuments(rider.riderId);
      } on RiderRepositoryException {
        documents = const [];
      }
      try {
        location = await _repository.getCurrentRiderLocation(rider.riderId);
      } on RiderRepositoryException {
        location = null;
      }
      _currentRider = rider;
      _currentVehicle = vehicles.first;
      _currentDocuments = documents;
      _currentLocation = location;
      String? photoUrl;
      if (rider.profilePhotoPath != null) {
        try {
          photoUrl = await _repository.createDocumentSignedUrl(
            rider.profilePhotoPath!,
          );
        } on RiderRepositoryException {
          photoUrl = null;
        }
      }
      final profile = riderProfileFromEntities(
        rider,
        vehicles.first,
        _currentDocuments,
        _currentLocation,
        photoUrl,
      );
      final index = _profiles.indexWhere((item) => item.email == profile.email);
      if (index < 0) {
        _profiles.add(profile);
      } else {
        _profiles[index] = profile;
      }
      _currentProfile = profile;
      _notifyChanged();
      return profile;
    } on RiderRegistrationException {
      rethrow;
    } on RiderRepositoryException catch (error) {
      throw RiderRegistrationException(error.message);
    }
  }

  Rider _riderFromRegistration(RiderRegistration value, String authId) => Rider(
    riderId: authId,
    logisticsCompanyId: value.logisticsCompanyId,
    licenseNumber: value.licenseNumber.trim(),
    fullName: value.fullName,
    vehicleType: value.vehicleType!.name,
    vehiclePlateNumber: value.vehiclePlateNumber.trim(),
    firstName: value.firstName.trim(),
    lastName: value.lastName.trim(),
    email: value.email.trim().toLowerCase(),
    contactNumber: value.contactNumber.trim(),
    gpsLatitude: value.gpsLatitude,
    gpsLongitude: value.gpsLongitude,
    locationLabel: value.locationLabel,
    addressLine: value.addressLine,
    barangay: value.barangay,
    cityMunicipality: value.cityMunicipality,
    province: value.province,
    postalCode: value.postalCode,
  );

  RiderVehicle _vehicleFromRegistration(
    RiderRegistration value,
    String riderId,
  ) => RiderVehicle(
    vehicleId: '',
    riderId: riderId,
    vehicleType: value.vehicleType!.name,
    vehicleModel: '',
    vehicleColor: '',
    plateNumber: value.vehiclePlateNumber.trim().isEmpty
        ? 'NO-PLATE-${riderId.replaceAll('-', '').substring(0, 10).toUpperCase()}'
        : value.vehiclePlateNumber.trim().toUpperCase(),
    capacityKg: 0,
  );

  RiderLocation? _locationFromRegistration(
    RiderRegistration value,
    String riderId,
  ) {
    final latitude = value.gpsLatitude;
    final longitude = value.gpsLongitude;
    if (latitude == null || longitude == null) return null;
    return RiderLocation(
      riderId: riderId,
      latitude: latitude,
      longitude: longitude,
      accuracyMeters: value.gpsAccuracyMeters ?? 0,
      timestamp: value.locationCapturedAt ?? DateTime.now(),
    );
  }
}
