part of 'rider_pickup_confirmation_screen.dart';

extension _PickupRecovery on _RiderPickupConfirmationScreenState {
  String get _recoveryScope => 'pickupConfirmation:${widget.request.id}';

  void _restoreRecovery() {
    final saved = widget.controller.recoveryDataFor(_recoveryScope);
    _quantity.text = saved['quantity'] as String? ?? '';
    _weight.text = saved['weight'] as String? ?? '';
    _checks.addAll(Map<String, bool>.from(saved['checks'] as Map? ?? const {}));
    final proofs = Map<String, Object?>.from(
      saved['proofs'] as Map? ?? const <String, Object?>{},
    );
    for (final entry in proofs.entries) {
      _proofs[PickupConfirmationMethod.values.byName(entry.key)] =
          entry.value as String;
    }
  }

  void _saveRecovery() => unawaited(
    widget.controller.saveRecoveryData(_recoveryScope, {
      'quantity': _quantity.text,
      'weight': _weight.text,
      'checks': _checks,
      'proofs': _proofs.map((key, value) => MapEntry(key.name, value)),
    }),
  );
}
