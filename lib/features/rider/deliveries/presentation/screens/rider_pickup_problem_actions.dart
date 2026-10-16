part of 'rider_pickup_confirmation_screen.dart';

extension _PickupProblemActions on _RiderPickupConfirmationScreenState {
  Future<void> _reportProblem() async {
    if (_busy) return;
    _setReporting(true);
    try {
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
      if (!mounted) return;
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
      if (report == null) {
        _setError('Pickup problem could not be saved.');
      } else {
        _setProblemSaved(true);
      }
    } finally {
      _setReporting(false);
    }
  }
}
