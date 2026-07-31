part of 'rider_delivery_repository.dart';

extension _InMemoryRiderPickupValidation on InMemoryRiderDeliveryRepository {
  void _validateChecklist(
    PickupConditionChecklist checklist,
    DeliveryRequest request,
  ) {
    if (!checklist.passes) {
      throw const DeliveryTransitionException(
        'Resolve the product condition checklist before completing pickup.',
        code: DeliveryErrorCode.invalidProof,
      );
    }
    final expectedQuantity = int.tryParse(
      RegExp(r'\d+').firstMatch(request.quantityDescription)?.group(0) ?? '',
    );
    if (expectedQuantity != null &&
        checklist.confirmedQuantity != expectedQuantity) {
      throw const DeliveryTransitionException(
        'The confirmed quantity does not match the pickup request.',
      );
    }
    final expectedWeight = request.totalWeightKg;
    if (expectedWeight != null &&
        (checklist.confirmedWeightKg - expectedWeight).abs() > 0.01) {
      throw const DeliveryTransitionException(
        'The confirmed weight does not match the pickup request.',
      );
    }
  }

  void _validateProofs(
    PickupCompletionCommand command,
    PickupConfiguration config,
  ) {
    final methods = config.requiredMethods;
    if (methods.contains(PickupConfirmationMethod.qrCode)) {
      final payload = command.qrPayload?.trim();
      if (payload == null || payload.isEmpty) {
        throw const DeliveryTransitionException(
          'A pickup QR confirmation is required.',
          code: DeliveryErrorCode.invalidProof,
        );
      }
      if (_usedPickupQrPayloads.contains(command.deliveryId)) {
        throw const DeliveryTransitionException(
          'This pickup QR confirmation has already been used.',
        );
      }
      if (config.qrPayloadHash != null &&
          PickupConfiguration.hashQrPayload(payload) != config.qrPayloadHash) {
        throw const DeliveryTransitionException(
          'The pickup QR confirmation is invalid.',
          code: DeliveryErrorCode.invalidProof,
        );
      }
    }
    for (final method in methods) {
      if (_requiresProtectedReference(method) &&
          !_isProtected(command.proofReferences[method])) {
        throw DeliveryTransitionException(
          '${method.name} proof is required.',
          code: DeliveryErrorCode.invalidProof,
        );
      }
    }
    if (methods.contains(PickupConfirmationMethod.confirmationCode)) {
      _validateCode(command.confirmationCode, config, command.deliveryId);
    }
  }

  void _validateCode(
    String? code,
    PickupConfiguration config,
    String deliveryId,
  ) {
    if (_usedPickupCodes.contains(deliveryId)) {
      throw const DeliveryTransitionException(
        'This pickup confirmation code has already been used.',
      );
    }
    if (config.codeExpiresAt?.isBefore(_clock()) ?? false) {
      throw const DeliveryTransitionException(
        'This pickup confirmation code has expired.',
      );
    }
    final attempts = _pickupCodeAttempts[deliveryId] ?? 0;
    if (attempts >= config.maxCodeAttempts) {
      throw const DeliveryTransitionException(
        'Too many incorrect pickup-code attempts.',
      );
    }
    final valid =
        code != null &&
        config.pickupCodeHash != null &&
        PickupConfiguration.hashCodeValue(code) == config.pickupCodeHash;
    if (!valid) {
      _pickupCodeAttempts[deliveryId] = attempts + 1;
      throw const DeliveryTransitionException(
        'The pickup confirmation code is incorrect.',
      );
    }
  }

  List<PickupProof> _proofsFor(PickupCompletionCommand command) => command
      .proofReferences
      .entries
      .where((entry) => _isProtected(entry.value))
      .map(
        (entry) => PickupProof(
          id: 'pickup-${command.deliveryId}-${entry.key.name}',
          type: _proofTypeFor(entry.key),
          secureReference: entry.value,
          capturedAt: _clock(),
        ),
      )
      .toList(growable: false);

  bool _requiresProtectedReference(PickupConfirmationMethod method) =>
      switch (method) {
        PickupConfirmationMethod.quantityConfirmation ||
        PickupConfirmationMethod.weightConfirmation => false,
        _ => true,
      };

  bool _isProtected(String? value) =>
      value?.startsWith('protected://') ?? false;

  DeliveryProofType _proofTypeFor(PickupConfirmationMethod method) =>
      switch (method) {
        PickupConfirmationMethod.confirmationCode =>
          DeliveryProofType.pickupOneTimeCode,
        PickupConfirmationMethod.qrCode => DeliveryProofType.pickupQrCode,
        PickupConfirmationMethod.productPhoto ||
        PickupConfirmationMethod.packagePhoto => DeliveryProofType.productPhoto,
        PickupConfirmationMethod.farmerConfirmation =>
          DeliveryProofType.sellerConfirmation,
        PickupConfirmationMethod.farmerSignature =>
          DeliveryProofType.riderSignature,
        PickupConfirmationMethod.quantityConfirmation ||
        PickupConfirmationMethod.weightConfirmation =>
          DeliveryProofType.sellerConfirmation,
      };
}
