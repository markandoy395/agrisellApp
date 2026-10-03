part of 'rider_delivery_repository.dart';

extension _InMemoryRiderDeliveryProofValidation
    on InMemoryRiderDeliveryRepository {
  void _validateDeliveryProofs(
    DeliveryCompletionCommand command,
    DeliveryCompletionConfiguration configuration,
  ) {
    final required = configuration.requiredMethods;
    if (command.proofReferences[DeliveryConfirmationMethod.handoverPhoto]
            ?.trim()
            .isEmpty ??
        true) {
      throw const DeliveryTransitionException(
        'Delivery evidence photo is required before completion.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    if (required.contains(DeliveryConfirmationMethod.confirmationCode)) {
      _validateDeliveryCode(command, configuration);
    }
    if (required.contains(DeliveryConfirmationMethod.qrCode)) {
      _validateDeliveryQr(command, configuration);
    }
    for (final method in required) {
      final valid = switch (method) {
        DeliveryConfirmationMethod.confirmationCode ||
        DeliveryConfirmationMethod.qrCode ||
        DeliveryConfirmationMethod.gpsLocation ||
        DeliveryConfirmationMethod.timestamp => true,
        DeliveryConfirmationMethod.recipientName =>
          command.recipientName?.trim().isNotEmpty ?? false,
        DeliveryConfirmationMethod.deliveryNotes =>
          command.deliveryNotes?.trim().isNotEmpty ?? false,
        _ => command.proofReferences[method]?.trim().isNotEmpty ?? false,
      };
      if (!valid) {
        throw DeliveryTransitionException(
          '${method.label} is required before completion.',
          code: DeliveryErrorCode.invalidProof,
        );
      }
    }
  }

  void _validateDeliveryCode(
    DeliveryCompletionCommand command,
    DeliveryCompletionConfiguration configuration,
  ) {
    if (_usedDeliveryCodes.contains(command.deliveryId)) {
      throw const DeliveryTransitionException(
        'This delivery confirmation code has already been used.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    final attempts = _deliveryCodeAttempts[command.deliveryId] ?? 0;
    if (attempts >= configuration.maxCodeAttempts) {
      throw const DeliveryTransitionException(
        'Too many invalid code attempts. Contact support.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    if (configuration.codeExpiresAt?.isBefore(_clock()) ?? false) {
      throw const DeliveryTransitionException(
        'The delivery confirmation code has expired.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    final value = command.confirmationCode?.trim();
    final expected = configuration.deliveryCodeHash;
    if (value == null || value.isEmpty || expected == null) {
      throw const DeliveryTransitionException(
        'The delivery confirmation code cannot be validated.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    if (DeliveryCompletionConfiguration.hashSecret(value) == expected) return;
    final next = attempts + 1;
    _deliveryCodeAttempts[command.deliveryId] = next;
    throw DeliveryTransitionException(
      next >= configuration.maxCodeAttempts
          ? 'Too many invalid code attempts. Contact support.'
          : 'The delivery confirmation code is incorrect.',
      code: DeliveryErrorCode.invalidProof,
    );
  }

  void _validateDeliveryQr(
    DeliveryCompletionCommand command,
    DeliveryCompletionConfiguration configuration,
  ) {
    if (_usedDeliveryQrPayloads.contains(command.deliveryId)) {
      throw const DeliveryTransitionException(
        'This delivery QR code has already been used.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    final payload = command.qrPayload?.trim();
    if (payload == null ||
        payload.isEmpty ||
        configuration.qrPayloadHash == null ||
        DeliveryCompletionConfiguration.hashSecret(payload) !=
            configuration.qrPayloadHash) {
      throw const DeliveryTransitionException(
        'The delivery QR code is invalid.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
  }

  List<DeliveryProof> _deliveryProofsFor(
    DeliveryCompletionCommand command,
    DeliveryCompletionConfiguration configuration,
    DateTime now,
  ) => [
    for (final method in {
      ...configuration.requiredMethods,
      DeliveryConfirmationMethod.handoverPhoto,
    })
      DeliveryProof(
        id: '${command.deliveryId}-${method.name}',
        type: _deliveryProofType(method),
        secureReference:
            command.proofReferences[method] ??
            'protected://delivery/${command.deliveryId}/${method.name}',
        capturedAt: method == DeliveryConfirmationMethod.handoverPhoto
            ? command.evidenceCapturedAt ?? now
            : now,
        latitude: method == DeliveryConfirmationMethod.handoverPhoto
            ? command.evidenceLocation?.latitude
            : null,
        longitude: method == DeliveryConfirmationMethod.handoverPhoto
            ? command.evidenceLocation?.longitude
            : null,
        confirmedAt: method == DeliveryConfirmationMethod.handoverPhoto
            ? command.evidenceCapturedAt ?? now
            : now,
      ),
  ];

  void _markDeliverySecretsUsed(
    DeliveryCompletionCommand command,
    DeliveryCompletionConfiguration configuration,
  ) {
    if (configuration.requiredMethods.contains(
      DeliveryConfirmationMethod.confirmationCode,
    )) {
      _usedDeliveryCodes.add(command.deliveryId);
    }
    if (configuration.requiredMethods.contains(
      DeliveryConfirmationMethod.qrCode,
    )) {
      _usedDeliveryQrPayloads.add(command.deliveryId);
    }
  }
}

DeliveryProofType _deliveryProofType(
  DeliveryConfirmationMethod method,
) => switch (method) {
  DeliveryConfirmationMethod.confirmationCode =>
    DeliveryProofType.deliveryOneTimeCode,
  DeliveryConfirmationMethod.qrCode => DeliveryProofType.deliveryQrCode,
  DeliveryConfirmationMethod.buyerConfirmation =>
    DeliveryProofType.buyerConfirmation,
  DeliveryConfirmationMethod.buyerSignature => DeliveryProofType.buyerSignature,
  DeliveryConfirmationMethod.handoverPhoto => DeliveryProofType.deliveryPhoto,
  DeliveryConfirmationMethod.recipientName => DeliveryProofType.recipientName,
  DeliveryConfirmationMethod.deliveryNotes => DeliveryProofType.deliveryNotes,
  DeliveryConfirmationMethod.gpsLocation =>
    DeliveryProofType.deliveryGpsLocation,
  DeliveryConfirmationMethod.timestamp => DeliveryProofType.deliveryTimestamp,
};
