part of 'rider_pickup_confirmation_screen.dart';

extension _PickupConfirmationActions on _RiderPickupConfirmationScreenState {
  Future<void> _capture(PickupConfirmationMethod method) async {
    if (_busy) return;
    _setCapturing(true);
    try {
      final reference = method.requiresImage
          ? await _storage.capturePhoto(
              deliveryId: widget.request.id,
              method: method,
            )
          : await _storage.saveAttestation(
              deliveryId: widget.request.id,
              method: method,
            );
      if (reference != null)
        _setProof(
          method,
          reference,
          imagePath: method.requiresImage
              ? _storage.lastCapturedImagePath
              : null,
        );
    } on PickupProofStorageException catch (error) {
      _setError(error.message);
    } finally {
      _setCapturing(false);
    }
  }

  Future<void> _submit(PickupConfiguration config) async {
    if (_busy) return;
    _setSubmitting(true);
    await _refreshPickupLocation(requestPermission: true);
    final locationState = widget.locationController?.state;
    final currentLocation =
        widget.locationController == null ||
            locationState == RiderLocationState.ready
        ? widget.controller.currentRiderLocation
        : null;
    final location =
        currentLocation ??
        const DeliveryStatusLocation(
          latitude: 0,
          longitude: 0,
          accuracyMeters: -1,
        );
    final proofs = Map<PickupConfirmationMethod, String>.from(_proofs);
    var command = PickupCompletionCommand(
      deliveryId: widget.request.id,
      riderId: widget.riderId,
      idempotencyKey: _idempotencyKey,
      location: location,
      checklist: _condition(),
      proofReferences: proofs,
      confirmationCode: _code.text,
      qrPayload: _qr.text,
    );
    final validation = validatePickupCompletion(command);
    if (!validation.isValid) {
      _setValidation(validation);
      _setSubmitting(false);
      return;
    }
    _setValidation(const PickupCompletionValidation([]));
    for (final method in config.requiredMethods.where(
      (item) =>
          item == PickupConfirmationMethod.confirmationCode ||
          item == PickupConfirmationMethod.qrCode,
    )) {
      try {
        proofs[method] = await _storage.saveAttestation(
          deliveryId: widget.request.id,
          method: method,
        );
      } on PickupProofStorageException catch (error) {
        _setError(error.message);
        _setSubmitting(false);
        return;
      }
    }
    command = PickupCompletionCommand(
      deliveryId: command.deliveryId,
      riderId: command.riderId,
      idempotencyKey: command.idempotencyKey,
      location: command.location,
      checklist: command.checklist,
      proofReferences: proofs,
      confirmationCode: command.confirmationCode,
      qrPayload: command.qrPayload,
    );
    final result = await widget.controller.completePickup(command);
    _setSubmitting(false);
    if (!mounted) return;
    if (result.isSuccess) {
      await widget.controller.clearRecoveryData(_recoveryScope);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } else {
      _setError(result.message);
    }
  }

  PickupConditionChecklist _condition() => PickupConditionChecklist(
    correctProduct: _checks[_checkLabels[0]] ?? false,
    correctQuantity: _checks[_checkLabels[1]] ?? false,
    correctWeight: _checks[_checkLabels[2]] ?? false,
    securePackaging: _checks[_checkLabels[3]] ?? false,
    notVisiblyDamaged: _checks[_checkLabels[4]] ?? false,
    matchesRequest: _checks[_checkLabels[5]] ?? false,
    fitsVehicle: _checks[_checkLabels[6]] ?? false,
    handlingInstructionsReceived: _checks[_checkLabels[7]] ?? false,
    confirmedQuantity: int.tryParse(_quantity.text) ?? 0,
    confirmedWeightKg: double.tryParse(_weight.text) ?? -1,
  );
}

const _checkLabels = [
  'Correct product',
  'Correct quantity',
  'Correct weight',
  'Packaging is secure',
  'Product is not visibly damaged',
  'Product matches the request',
  'Product fits the vehicle',
  'Handling instructions received',
];
String _quantityFrom(String value) =>
    RegExp(r'\d+').firstMatch(value)?.group(0) ?? '';
