part of 'rider_pickup_confirmation_screen.dart';

extension _PickupConfirmationActions on _RiderPickupConfirmationScreenState {
  Future<void> _capture(PickupConfirmationMethod method) async {
    try {
      final reference = switch (method) {
        PickupConfirmationMethod.productPhoto ||
        PickupConfirmationMethod.packagePhoto => await _storage.capturePhoto(
          deliveryId: widget.request.id,
          method: method,
        ),
        _ => await _storage.saveAttestation(
          deliveryId: widget.request.id,
          method: method,
        ),
      };
      if (reference != null) _setProof(method, reference);
    } on PickupProofStorageException catch (error) {
      _setError(error.message);
    }
  }

  Future<void> _submit(PickupConfiguration config) async {
    final location = widget.controller.currentRiderLocation;
    if (location == null) {
      _setError('Current pickup location is required.');
      return;
    }
    _setSubmitting(true);
    _setError(null);
    final proofs = Map<PickupConfirmationMethod, String>.from(_proofs);
    for (final method in config.requiredMethods.where(
      (item) =>
          item == PickupConfirmationMethod.confirmationCode ||
          item == PickupConfirmationMethod.qrCode,
    )) {
      proofs[method] = await _storage.saveAttestation(
        deliveryId: widget.request.id,
        method: method,
      );
    }
    final result = await widget.controller.completePickup(
      PickupCompletionCommand(
        deliveryId: widget.request.id,
        riderId: widget.riderId,
        idempotencyKey: Random.secure().nextInt(1 << 32).toString(),
        location: location,
        checklist: _condition(),
        proofReferences: proofs,
        confirmationCode: _code.text,
        qrPayload: _qr.text,
      ),
    );
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

  Future<void> _reportProblem() async {
    final draft = await showRiderPickupProblemDialog(context);
    if (draft == null || !mounted) return;
    final location = widget.controller.currentRiderLocation;
    if (location == null) {
      _setError('A location is required to report this pickup problem.');
      return;
    }
    String? photo;
    try {
      photo = await _storage.capturePhoto(
        deliveryId: widget.request.id,
        method: PickupConfirmationMethod.productPhoto,
      );
    } on PickupProofStorageException catch (error) {
      _setError(error.message);
      return;
    }
    final report = await widget.controller.reportPickupProblem(
      PickupProblemReport(
        id: 'pickup-problem-${DateTime.now().microsecondsSinceEpoch}',
        deliveryId: widget.request.id,
        riderId: widget.riderId,
        kind: draft.kind,
        reportedAt: DateTime.now(),
        location: location,
        notes: draft.notes,
        photoReferences: photo == null ? const [] : [photo],
      ),
    );
    _setError(
      report == null
          ? 'Pickup problem could not be saved.'
          : 'Problem saved. Contact support before continuing pickup.',
    );
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
bool _requiresProof(PickupConfirmationMethod method) => !{
  PickupConfirmationMethod.confirmationCode,
  PickupConfirmationMethod.qrCode,
  PickupConfirmationMethod.quantityConfirmation,
  PickupConfirmationMethod.weightConfirmation,
}.contains(method);
String _methodLabel(PickupConfirmationMethod method) =>
    'Add ${method.name} proof';
String _quantityFrom(String value) =>
    RegExp(r'\d+').firstMatch(value)?.group(0) ?? '';
