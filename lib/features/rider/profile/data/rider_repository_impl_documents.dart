part of 'rider_repository_impl.dart';

mixin _RiderRepositoryDocumentOperations implements RiderRepository {
  RiderRemoteDataSource get _source;

  static const _maxBytes = 8 * 1024 * 1024;
  static const _extensions = {'jpg', 'jpeg', 'png', 'webp'};

  @override
  Future<String> uploadRiderDocument(
    RiderDocumentUpload upload, {
    RiderUploadProgress? onProgress,
  }) => guardRiderOperation(() async {
    _validateUpload(upload.bytes, upload.extension);
    if (upload.documentType.isVehicleDocument !=
        (upload.vehicleId?.isNotEmpty ?? false)) {
      throw const RiderRepositoryException(
        'The Rider document is associated with the wrong vehicle.',
        type: RiderFailureType.validation,
        isRecoverable: false,
      );
    }
    onProgress?.call(0.05);
    final path = _documentPath(upload);
    await _source.uploadObject(
      path: path,
      bytes: upload.bytes,
      contentType: upload.contentType,
    );
    onProgress?.call(1);
    return path;
  });

  @override
  Future<RiderDocument> saveRiderDocumentRecord(RiderDocument document) =>
      guardRiderOperation(() {
        RiderEntityValidator.document(document);
        if (document.documentId.isEmpty) {
          return _source.createDocument(document);
        }
        final values = document.toJson()
          ..remove('document_id')
          ..remove('rider_id')
          ..remove('vehicle_id')
          ..remove('document_type')
          ..remove('verification_status')
          ..remove('rejection_reason');
        return _source.updateDocument(document.documentId, values);
      });

  @override
  Future<List<RiderDocument>> getRiderDocuments(String riderId) =>
      guardRiderOperation(() => _source.getDocuments(riderId));

  @override
  Future<RiderDocument> replaceRiderDocument(
    RiderDocument current,
    RiderDocumentUpload upload, {
    RiderUploadProgress? onProgress,
  }) => guardRiderOperation(() async {
    final nextPath = await uploadRiderDocument(upload, onProgress: onProgress);
    RiderDocument updated;
    try {
      updated = await _source.updateDocument(current.documentId, {
        'file_path': nextPath,
      });
    } on Exception {
      await _source.deleteObject(nextPath);
      rethrow;
    }
    try {
      await _source.deleteObject(current.filePath);
    } on Exception {
      throw const RiderRepositoryException(
        'The document was replaced, but the old file still needs cleanup.',
        type: RiderFailureType.storage,
      );
    }
    return updated;
  });

  @override
  Future<void> deleteRiderDocument(
    RiderDocument document,
  ) => guardRiderOperation(() async {
    await _source.deleteDocument(document.documentId);
    try {
      await _source.deleteObject(document.filePath);
    } on Exception {
      throw const RiderRepositoryException(
        'The document record was removed, but file cleanup must be retried.',
        type: RiderFailureType.storage,
      );
    }
  });

  @override
  Future<String> createDocumentSignedUrl(String path) =>
      guardRiderOperation(() => _source.createSignedUrl(path));

  @override
  Future<void> removeRiderFile(String path) =>
      guardRiderOperation(() => _source.deleteObject(path));

  @override
  Future<String> uploadProfilePhoto(
    Uint8List bytes, {
    required String extension,
    required String contentType,
    RiderUploadProgress? onProgress,
  }) => guardRiderOperation(() async {
    _validateUpload(bytes, extension);
    onProgress?.call(0.05);
    final cleanExtension = extension.toLowerCase();
    final path =
        '${_source.currentAuthId}/profile/'
        'profile_photo_${DateTime.now().microsecondsSinceEpoch}.$cleanExtension';
    await _source.uploadObject(
      path: path,
      bytes: bytes,
      contentType: contentType,
    );
    onProgress?.call(1);
    return path;
  });

  String _documentPath(RiderDocumentUpload upload) {
    final authId = _source.currentAuthId;
    final type = upload.documentType.databaseValue;
    final stamp = DateTime.now().microsecondsSinceEpoch;
    final fileName = '${type}_$stamp.${upload.extension.toLowerCase()}';
    return upload.documentType.isVehicleDocument
        ? '$authId/vehicles/${upload.vehicleId}/$fileName'
        : '$authId/personal/$fileName';
  }

  void _validateUpload(Uint8List bytes, String extension) {
    if (bytes.isEmpty || bytes.length > _maxBytes) {
      throw const RiderRepositoryException(
        'Each Rider file must be a non-empty image under 8 MB.',
        type: RiderFailureType.validation,
        isRecoverable: false,
      );
    }
    if (!_extensions.contains(extension.toLowerCase())) {
      throw const RiderRepositoryException(
        'Use a JPG, PNG, or WEBP image.',
        type: RiderFailureType.validation,
        isRecoverable: false,
      );
    }
  }
}
