enum RiderDocumentType {
  driversLicense('drivers_license', false),
  validId('valid_id', false),
  profileSelfie('profile_selfie', false),
  vehicleOr('vehicle_or', true),
  vehicleCr('vehicle_cr', true),
  vehiclePhoto('vehicle_photo', true);

  const RiderDocumentType(this.databaseValue, this.isVehicleDocument);
  final String databaseValue;
  final bool isVehicleDocument;

  static RiderDocumentType parse(Object? value) => values.firstWhere(
    (item) => item.databaseValue == value?.toString(),
    orElse: () => throw FormatException('Unsupported Rider document type.'),
  );
}

enum RiderDocumentVerificationStatus { pending, verified, rejected }

class RiderDocument {
  const RiderDocument({
    required this.documentId,
    required this.riderId,
    required this.documentType,
    required this.filePath,
    this.vehicleId,
    this.documentNumber,
    this.verificationStatus = RiderDocumentVerificationStatus.pending,
    this.rejectionReason,
    this.expiryDate,
    this.createdAt,
    this.updatedAt,
  });

  final String documentId;
  final String riderId;
  final String? vehicleId;
  final RiderDocumentType documentType;
  final String? documentNumber;
  final String filePath;
  final RiderDocumentVerificationStatus verificationStatus;
  final String? rejectionReason;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory RiderDocument.fromJson(Map<String, Object?> json) => RiderDocument(
    documentId: _text(json['document_id']),
    riderId: _text(json['rider_id']),
    vehicleId: _nullableText(json['vehicle_id']),
    documentType: RiderDocumentType.parse(json['document_type']),
    documentNumber: _nullableText(json['document_number']),
    filePath: _text(json['file_path'] ?? json['file_url']),
    verificationStatus: RiderDocumentVerificationStatus.values.firstWhere(
      (item) => item.name == json['verification_status'],
      orElse: () => RiderDocumentVerificationStatus.pending,
    ),
    rejectionReason: _nullableText(json['rejection_reason']),
    expiryDate: _date(json['expiry_date']),
    createdAt: _date(json['created_at']),
    updatedAt: _date(json['updated_at']),
  );

  Map<String, Object?> toJson() => {
    if (documentId.isNotEmpty) 'document_id': documentId,
    'rider_id': riderId,
    'vehicle_id': vehicleId,
    'document_type': documentType.databaseValue,
    'document_number': _blankToNull(documentNumber),
    'file_path': filePath,
    'verification_status': verificationStatus.name,
    'rejection_reason': _blankToNull(rejectionReason),
    'expiry_date': expiryDate?.toIso8601String().split('T').first,
  };

  RiderDocument copyWith({
    String? documentNumber,
    String? filePath,
    RiderDocumentVerificationStatus? verificationStatus,
    String? rejectionReason,
    DateTime? expiryDate,
  }) => RiderDocument(
    documentId: documentId,
    riderId: riderId,
    vehicleId: vehicleId,
    documentType: documentType,
    documentNumber: documentNumber ?? this.documentNumber,
    filePath: filePath ?? this.filePath,
    verificationStatus: verificationStatus ?? this.verificationStatus,
    rejectionReason: rejectionReason ?? this.rejectionReason,
    expiryDate: expiryDate ?? this.expiryDate,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      other is RiderDocument &&
      other.documentId == documentId &&
      other.updatedAt == updatedAt;

  @override
  int get hashCode => Object.hash(documentId, updatedAt);
}

String _text(Object? value) => value?.toString().trim() ?? '';
String? _nullableText(Object? value) => _blankToNull(value?.toString());
String? _blankToNull(String? value) => switch (value?.trim()) {
  final text? when text.isNotEmpty => text,
  _ => null,
};
DateTime? _date(Object? value) =>
    value is DateTime ? value : DateTime.tryParse(value?.toString() ?? '');
