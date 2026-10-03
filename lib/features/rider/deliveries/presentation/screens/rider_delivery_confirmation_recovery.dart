part of 'rider_delivery_confirmation_screen.dart';

extension _RiderDeliveryConfirmationRecovery
    on _RiderDeliveryConfirmationScreenState {
  String get _recoveryScope => 'deliveryConfirmation:${widget.request.id}';

  void _restoreRecovery() {
    final saved = widget.controller.recoveryDataFor(_recoveryScope);
    _notes.text = saved['deliveryNotes'] as String? ?? '';
    _buyerConfirmed = saved['buyerConfirmed'] as bool? ?? false;
    _signatureReference = saved['signatureReference'] as String?;
    _photoReference = saved['photoReference'] as String?;
    _photoCapturedAt = DateTime.tryParse(
      saved['photoCapturedAt'] as String? ?? '',
    )?.toLocal();
    final photoLatitude = saved['photoLatitude'] as num?;
    final photoLongitude = saved['photoLongitude'] as num?;
    final photoAccuracy = saved['photoAccuracyMeters'] as num?;
    if (photoLatitude != null &&
        photoLongitude != null &&
        photoAccuracy != null) {
      _photoLocation = DeliveryStatusLocation(
        latitude: photoLatitude.toDouble(),
        longitude: photoLongitude.toDouble(),
        accuracyMeters: photoAccuracy.toDouble(),
        timestamp: _photoCapturedAt,
      );
    }
    _cashAmount.text = saved['cashAmount'] as String? ?? '';
    _cashNotes.text = saved['cashNotes'] as String? ?? '';
    _cashConfirmed = saved['cashConfirmed'] as bool? ?? false;
    final issue = saved['cashIssue'] as String?;
    _cashIssue = issue == null
        ? null
        : CashCollectionIssue.values.byName(issue);
  }

  void _saveRecovery() => unawaited(
    widget.controller.saveRecoveryData(_recoveryScope, {
      'deliveryNotes': _notes.text,
      'buyerConfirmed': _buyerConfirmed,
      'signatureReference': _signatureReference,
      'photoReference': _photoReference,
      'photoCapturedAt': _photoCapturedAt?.toUtc().toIso8601String(),
      'photoLatitude': _photoLocation?.latitude,
      'photoLongitude': _photoLocation?.longitude,
      'photoAccuracyMeters': _photoLocation?.accuracyMeters,
      'cashAmount': _cashAmount.text,
      'cashNotes': _cashNotes.text,
      'cashConfirmed': _cashConfirmed,
      'cashIssue': _cashIssue?.name,
    }),
  );
}
