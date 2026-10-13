part of 'rider_registration_service.dart';

extension RiderRegistrationServiceDocumentOperations
    on RiderRegistrationService {
  Future<void> saveCapacity(double capacityKg) async {
    try {
      await SupabaseRiderDataSource().setCapacity(capacityKg);
      await _loadRemoteProfile(force: true);
    } on PostgrestException catch (error) {
      throw RiderRegistrationException(error.message);
    } on AuthException {
      throw const RiderRegistrationException(
        'Sign in to save vehicle capacity.',
      );
    }
  }

  Future<void> _uploadRegistrationFiles(
    RiderRegistration registration,
    Map<RiderDraftDocumentType, RiderDraftDocument> documents,
    RiderRegistrationEntities entities,
    RiderSignUpUploadProgress? progress,
  ) async {
    final photo = documents[RiderDraftDocumentType.profilePhoto];
    if (photo != null && _currentRider?.profilePhotoPath == null) {
      final file = await _fileData(photo);
      final path = await _repository.uploadProfilePhoto(
        file.$1,
        extension: file.$2,
        contentType: file.$3,
        onProgress: (value) => progress?.call(
          RiderDraftDocumentType.profilePhoto,
          value >= 1 ? 0.9 : value,
        ),
      );
      try {
        _currentRider = await _repository.updateRider(
          entities.rider.copyWith(profilePhotoPath: path),
        );
      } on Exception {
        await _repository.removeRiderFile(path);
        rethrow;
      }
      progress?.call(RiderDraftDocumentType.profilePhoto, 1);
    }

    _currentDocuments = await _repository.getRiderDocuments(
      entities.rider.riderId,
    );
    for (final entry in _documentTypes.entries) {
      final draftDocument = documents[entry.key];
      if (draftDocument == null) continue;
      final file = await _fileData(draftDocument);
      final documentType = entry.value;
      final vehicleId = documentType.isVehicleDocument
          ? entities.vehicle.vehicleId
          : null;
      final upload = RiderDocumentUpload(
        bytes: file.$1,
        extension: file.$2,
        contentType: file.$3,
        documentType: documentType,
        vehicleId: vehicleId,
      );
      final current = _currentDocuments
          .where((item) => item.documentType == documentType)
          .firstOrNull;
      if (current != null &&
          draftDocument.status == RiderDocumentStatus.submitted) {
        continue;
      }
      if (current != null) {
        await _repository.replaceRiderDocument(
          current,
          upload,
          onProgress: (value) =>
              progress?.call(entry.key, value >= 1 ? 0.9 : value),
        );
        progress?.call(entry.key, 1);
        continue;
      }
      final path = await _repository.uploadRiderDocument(
        upload,
        onProgress: (value) =>
            progress?.call(entry.key, value >= 1 ? 0.9 : value),
      );
      try {
        await _repository.saveRiderDocumentRecord(
          RiderDocument(
            documentId: '',
            riderId: entities.rider.riderId,
            vehicleId: vehicleId,
            documentType: documentType,
            documentNumber: documentType == RiderDocumentType.driversLicense
                ? registration.licenseNumber.trim().toUpperCase()
                : null,
            filePath: path,
          ),
        );
      } on Exception {
        await _repository.removeRiderFile(path);
        rethrow;
      }
      progress?.call(entry.key, 1);
    }
    _currentDocuments = await _repository.getRiderDocuments(
      entities.rider.riderId,
    );
  }

  Future<RiderDocument> replaceDocument(
    RiderDocument document,
    RiderDraftDocument selected, {
    RiderUploadProgress? onProgress,
  }) async {
    try {
      final file = await _fileData(selected);
      final updated = await _repository.replaceRiderDocument(
        document,
        RiderDocumentUpload(
          bytes: file.$1,
          extension: file.$2,
          contentType: file.$3,
          documentType: document.documentType,
          vehicleId: document.vehicleId,
        ),
        onProgress: onProgress,
      );
      _currentDocuments = [
        for (final item in _currentDocuments)
          if (item.documentId == updated.documentId) updated else item,
      ];
      _notifyChanged();
      return updated;
    } on RiderRepositoryException catch (error) {
      throw RiderRegistrationException(error.message);
    }
  }

  Future<RiderVehicle> saveVehicle(RiderVehicle vehicle) async {
    try {
      _currentVehicle = await _repository.updateVehicle(vehicle);
      await _loadRemoteProfile(force: true);
      return _currentVehicle!;
    } on RiderRepositoryException catch (error) {
      throw RiderRegistrationException(error.message);
    }
  }

  Future<(Uint8List, String, String)> _fileData(
    RiderDraftDocument document,
  ) async {
    final bytes = await File(document.path).readAsBytes();
    final extension = document.fileName.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };
    return (bytes, extension, contentType);
  }

  Map<RiderDraftDocumentType, RiderDocumentType> get _documentTypes => const {
    RiderDraftDocumentType.driversLicense: RiderDocumentType.driversLicense,
    RiderDraftDocumentType.validId: RiderDocumentType.validId,
    RiderDraftDocumentType.vehicleOr: RiderDocumentType.vehicleOr,
    RiderDraftDocumentType.vehicleCr: RiderDocumentType.vehicleCr,
    RiderDraftDocumentType.vehiclePhoto: RiderDocumentType.vehiclePhoto,
  };
}
