part of 'rider_delivery_confirmation_screen.dart';

extension _RiderDeliveryConfirmationActions
    on _RiderDeliveryConfirmationScreenState {
  Widget? get _cashCollectionSection => switch (widget.request.cashOnDelivery) {
    final cash? => RiderCashCollectionCard(
      requirement: cash,
      amountController: _cashAmount,
      notesController: _cashNotes,
      confirmed: _cashConfirmed,
      issue: _cashIssue,
      enabled: !_submitting,
      onConfirmed: _setCashConfirmed,
      onIssue: _setCashIssue,
    ),
    null => null,
  };

  Future<void> _load() async {
    _update(() {
      _configuration = null;
      _error = null;
    });
    try {
      final value = await widget.controller.fetchDeliveryConfiguration(
        deliveryId: widget.request.id,
        riderId: widget.riderId,
      );
      _update(() => _configuration = value);
    } on Exception {
      if (mounted) {
        _update(() => _error = 'Proof requirements could not be loaded.');
      }
    }
  }

  Future<void> _captureSignature() async {
    final reference = await showRiderSignaturePad(
      context,
      deliveryId: widget.request.id,
      storage: _storage,
    );
    if (reference != null && mounted) {
      _update(() => _signatureReference = reference);
      _saveRecovery();
    }
  }

  Future<void> _capturePhoto() async {
    try {
      final reference = await _storage.capturePhoto(
        deliveryId: widget.request.id,
      );
      if (reference != null && mounted) {
        _update(() => _photoReference = reference);
        _saveRecovery();
      }
    } on DeliveryProofStorageException catch (error) {
      if (mounted) _message(error.message);
    }
  }

  Future<void> _submit() async {
    final configuration = _configuration;
    final location = widget.controller.currentRiderLocation;
    if (configuration == null || location == null) {
      _message('A current precise GPS fix is required.');
      return;
    }
    _update(() => _submitting = true);
    try {
      final proofs = await _proofReferences(configuration);
      final result = await widget.controller.completeDelivery(
        command: DeliveryCompletionCommand(
          deliveryId: widget.request.id,
          riderId: widget.riderId,
          idempotencyKey: _idempotencyKey,
          finalLocation: location,
          proofReferences: proofs,
          confirmationCode: _code.text,
          qrPayload: _qr.text,
          recipientName: _recipient.text,
          deliveryNotes: _notes.text,
          cashCollection: _cashSubmission(),
        ),
      );
      if (!mounted) return;
      if (result.isSuccess) {
        await widget.controller.clearRecoveryData(_recoveryScope);
        if (!mounted) return;
        Navigator.of(context).pop(true);
        return;
      }
      _message(result.message ?? 'Delivery could not be completed.');
    } on DeliveryProofStorageException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      _update(() => _submitting = false);
    }
  }

  Future<Map<DeliveryConfirmationMethod, String>> _proofReferences(
    DeliveryCompletionConfiguration configuration,
  ) async {
    final references = <DeliveryConfirmationMethod, String>{
      DeliveryConfirmationMethod.buyerSignature: ?_signatureReference,
      DeliveryConfirmationMethod.handoverPhoto: ?_photoReference,
    };
    for (final method in configuration.requiredMethods) {
      final attested = switch (method) {
        DeliveryConfirmationMethod.buyerConfirmation => _buyerConfirmed,
        DeliveryConfirmationMethod.recipientName =>
          _recipient.text.trim().isNotEmpty,
        DeliveryConfirmationMethod.deliveryNotes =>
          _notes.text.trim().isNotEmpty,
        DeliveryConfirmationMethod.gpsLocation ||
        DeliveryConfirmationMethod.timestamp => true,
        _ => false,
      };
      if (attested) {
        references[method] = await _storage.saveAttestation(
          deliveryId: widget.request.id,
          method: method,
        );
      }
    }
    return references;
  }

  CashCollectionSubmission? _cashSubmission() {
    final requirement = widget.request.cashOnDelivery;
    if (requirement == null || requirement.hasAuthorizedException) return null;
    return CashCollectionSubmission(
      amountReceived: double.tryParse(_cashAmount.text.trim()) ?? 0,
      collectionConfirmed: _cashConfirmed,
      issue: _cashIssue,
      notes: _cashNotes.text,
    );
  }

  void _message(String value) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(value)));
  }
}
