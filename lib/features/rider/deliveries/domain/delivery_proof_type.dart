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
