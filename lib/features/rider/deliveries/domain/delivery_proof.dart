import 'delivery_json.dart';

enum DeliveryProofPurpose { pickup, completion }

enum DeliveryProofStage { pickup, delivery }

enum DeliveryProofType {
  pickupQrCode,
  pickupOneTimeCode,
  productPhoto,
  sellerConfirmation,
  riderSignature,
  deliveryQrCode,
  deliveryOneTimeCode,
  deliveryPhoto,
  buyerSignature,
  buyerConfirmation,
  recipientName,
  deliveryNotes,
  deliveryGpsLocation,
  deliveryTimestamp,
}

extension DeliveryProofTypeDetails on DeliveryProofType {
  DeliveryProofPurpose get purpose {
    return switch (this) {
      DeliveryProofType.pickupQrCode ||
      DeliveryProofType.pickupOneTimeCode ||
      DeliveryProofType.productPhoto ||
      DeliveryProofType.sellerConfirmation ||
      DeliveryProofType.riderSignature => DeliveryProofPurpose.pickup,
      DeliveryProofType.deliveryQrCode ||
      DeliveryProofType.deliveryOneTimeCode ||
      DeliveryProofType.deliveryPhoto ||
      DeliveryProofType.buyerSignature ||
      DeliveryProofType.buyerConfirmation ||
      DeliveryProofType.recipientName ||
      DeliveryProofType.deliveryNotes ||
      DeliveryProofType.deliveryGpsLocation ||
      DeliveryProofType.deliveryTimestamp => DeliveryProofPurpose.completion,
    };
  }

  String get databaseValue => switch (this) {
    DeliveryProofType.pickupQrCode ||
    DeliveryProofType.pickupOneTimeCode ||
    DeliveryProofType.deliveryQrCode ||
    DeliveryProofType.deliveryOneTimeCode => 'confirmation_code',
    DeliveryProofType.riderSignature ||
    DeliveryProofType.buyerSignature => 'signature',
    _ => 'photo',
  };

  static DeliveryProofType fromDatabase({
    required Object? type,
    required DeliveryProofStage stage,
  }) => switch (type) {
    'confirmation_code' =>
      stage == DeliveryProofStage.pickup
          ? DeliveryProofType.pickupOneTimeCode
          : DeliveryProofType.deliveryOneTimeCode,
    'signature' =>
      stage == DeliveryProofStage.pickup
          ? DeliveryProofType.riderSignature
          : DeliveryProofType.buyerSignature,
    _ =>
      stage == DeliveryProofStage.pickup
          ? DeliveryProofType.productPhoto
          : DeliveryProofType.deliveryPhoto,
  };
}

/// A reference to securely stored proof, never the raw OTP, QR payload, or image.
class DeliveryProof {
  const DeliveryProof({
    required this.id,
    required this.type,
    required this.secureReference,
    required this.capturedAt,
    this.deliveryId = '',
    this.stage,
    this.filePath,
    this.confirmationCodeHash,
    this.remarks,
    this.latitude,
    this.longitude,
    this.confirmedAt,
    this.createdAt,
    this.updatedAt,
  }) : assert(id != ''),
       assert(secureReference != '');

  factory DeliveryProof.fromJson(Map<String, Object?> json) {
    final stage = DeliveryProofStage.values.firstWhere(
      (item) => item.name == json['proof_stage'],
      orElse: () =>
          throw FormatException('Unknown proof stage: ${json['proof_stage']}'),
    );
    final createdAt =
        deliveryDateTime(json['created_at']) ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final filePath = json['file_path'] as String?;
    return DeliveryProof(
      id: deliveryString(json['proof_id']),
      deliveryId: deliveryString(json['delivery_id']),
      stage: stage,
      type: DeliveryProofTypeDetails.fromDatabase(
        type: json['proof_type'],
        stage: stage,
      ),
      secureReference:
          filePath ?? 'protected://confirmation/${json['proof_id']}',
      filePath: filePath,
      confirmationCodeHash: json['confirmation_code_hash'] as String?,
      remarks: json['remarks'] as String?,
      latitude: deliveryDouble(json['latitude']),
      longitude: deliveryDouble(json['longitude']),
      confirmedAt: deliveryDateTime(json['confirmed_at']),
      capturedAt: deliveryDateTime(json['confirmed_at']) ?? createdAt,
      createdAt: createdAt,
      updatedAt: deliveryDateTime(json['updated_at']) ?? createdAt,
    );
  }

  final String id;
  final String deliveryId;
  final DeliveryProofStage? stage;
  final DeliveryProofType type;
  final String secureReference;
  final String? filePath;
  final String? confirmationCodeHash;
  final String? remarks;
  final double? latitude;
  final double? longitude;
  final DateTime? confirmedAt;
  final DateTime capturedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DeliveryProofStage get proofStage =>
      stage ??
      (type.purpose == DeliveryProofPurpose.pickup
          ? DeliveryProofStage.pickup
          : DeliveryProofStage.delivery);

  bool satisfies(DeliveryProofPurpose requiredPurpose) {
    return type.purpose == requiredPurpose;
  }

  Map<String, Object?> toJson() => {
    if (id.isNotEmpty) 'proof_id': id,
    if (deliveryId.isNotEmpty) 'delivery_id': deliveryId,
    'proof_stage': proofStage.name,
    'proof_type': type.databaseValue,
    'file_path': filePath ?? secureReference,
    'confirmation_code_hash': confirmationCodeHash,
    'remarks': remarks,
    'latitude': latitude,
    'longitude': longitude,
    'confirmed_at': confirmedAt?.toUtc().toIso8601String(),
  };

  DeliveryProof copyWith({String? filePath, String? remarks}) => DeliveryProof(
    id: id,
    deliveryId: deliveryId,
    stage: stage,
    type: type,
    secureReference: filePath ?? secureReference,
    filePath: filePath ?? this.filePath,
    confirmationCodeHash: confirmationCodeHash,
    remarks: remarks ?? this.remarks,
    latitude: latitude,
    longitude: longitude,
    confirmedAt: confirmedAt,
    capturedAt: capturedAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  @override
  bool operator ==(Object other) => other is DeliveryProof && other.id == id;
  @override
  int get hashCode => id.hashCode;
}

class PickupProof extends DeliveryProof {
  const PickupProof({
    required super.id,
    required super.type,
    required super.secureReference,
    required super.capturedAt,
  }) : assert(
         type == DeliveryProofType.pickupQrCode ||
             type == DeliveryProofType.pickupOneTimeCode ||
             type == DeliveryProofType.productPhoto ||
             type == DeliveryProofType.sellerConfirmation ||
             type == DeliveryProofType.riderSignature,
       );
}
