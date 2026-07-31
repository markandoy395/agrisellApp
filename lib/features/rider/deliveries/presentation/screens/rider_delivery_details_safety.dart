part of 'rider_delivery_details_screen.dart';

extension _RiderDeliveryDetailsSafety on _RiderDeliveryDetailsScreenState {
  Future<void> _openSafetyReport(DeliveryStatus stage) async {
    final location = widget.controller.currentRiderLocation;
    if (location == null) {
      _showMessage('A current location is required for a safety report.');
      return;
    }
    final draft = await showRiderSafetyReportDialog(
      context,
      onCapturePhoto: _captureReportPhoto,
    );
    if (draft == null || !mounted) return;
    _safetyReportController.setBackendReachable(
      widget.controller.isBackendReachable,
    );
    final timestamp = DateTime.now();
    final saved = await _safetyReportController.submit(
      RiderSafetyReport(
        id: 'safety-${_request.id}-${timestamp.microsecondsSinceEpoch}',
        deliveryId: _request.id,
        riderId: widget.riderId,
        stage: stage,
        location: location,
        createdAt: timestamp,
        category: draft.category,
        description: draft.description,
        attachments: draft.attachments,
        requestedActions: draft.actions,
      ),
    );
    if (!mounted) return;
    _showMessage(
      saved.status == RiderSafetyReportStatus.submitted
          ? 'Safety report sent to support.'
          : 'Safety report saved for support.',
    );
  }

  Future<void> _openProblemReport() async {
    final draft = await showRiderDeliveryProblemDialog(
      context,
      onCapturePhoto: _captureReportPhoto,
    );
    if (draft == null || !mounted) return;
    final result = await widget.controller.reportDeliveryProblem(
      deliveryId: _request.id,
      riderId: widget.riderId,
      kind: draft.kind,
      notes: draft.notes,
      photoReferences: draft.photoReferences,
    );
    if (!mounted) return;
    _showMessage(
      result.isSuccess
          ? widget.controller.isBackendReachable
                ? 'Problem report submitted.'
                : 'Problem report saved. Waiting to synchronize.'
          : result.message ?? 'Problem report could not be submitted.',
    );
  }

  Future<String?> _captureReportPhoto() async {
    try {
      return await _reportProofStorage.capturePhoto(deliveryId: _request.id);
    } on DeliveryProofStorageException catch (error) {
      if (mounted) _showMessage(error.message);
      return null;
    }
  }
}
