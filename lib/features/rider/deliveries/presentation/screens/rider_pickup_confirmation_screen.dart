import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/data/pickup_proof_storage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request_metadata.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_pickup_problem_dialog.dart';

part 'rider_pickup_confirmation_actions.dart';
part 'rider_pickup_confirmation_sections.dart';

class RiderPickupConfirmationScreen extends StatefulWidget {
  const RiderPickupConfirmationScreen({
    required this.request,
    required this.riderId,
    required this.controller,
    this.locationController,
    super.key,
  });

  final DeliveryRequest request;
  final String riderId;
  final RiderDeliveryController controller;
  final RiderLocationController? locationController;

  @override
  State<RiderPickupConfirmationScreen> createState() =>
      _RiderPickupConfirmationScreenState();
}

class _RiderPickupConfirmationScreenState
    extends State<RiderPickupConfirmationScreen> {
  final _code = TextEditingController();
  final _qr = TextEditingController();
  final _quantity = TextEditingController();
  final _weight = TextEditingController();
  final _proofs = <PickupConfirmationMethod, String>{};
  final _checks = <String, bool>{};
  final _storage = PickupProofStorage();
  final _idempotencyKey = Random.secure().nextInt(1 << 32).toString();
  PickupConfiguration? _configuration;
  String? _error;
  List<PickupValidationIssue> _validationIssues = const [];
  var _submitting = false;
  var _refreshingLocation = false;
  Timer? _waitingTimer;
  var _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _restoreRecovery();
    widget.locationController?.addListener(_locationChanged);
    if (_quantity.text.isEmpty) {
      _quantity.text = _quantityFrom(widget.request.quantityDescription);
    }
    if (_weight.text.isEmpty) {
      _weight.text = widget.request.totalWeightKg?.toString() ?? '';
    }
    _quantity.addListener(_saveRecovery);
    _weight.addListener(_saveRecovery);
    widget.controller
        .pickupConfiguration(
          deliveryId: widget.request.id,
          riderId: widget.riderId,
        )
        .then((value) => _setConfiguration(value))
        .catchError((_) => _setError('Pickup setup could not load.'));
    unawaited(_refreshPickupLocation(requestPermission: false));
  }

  @override
  void dispose() {
    _code.dispose();
    _qr.dispose();
    _quantity.dispose();
    _weight.dispose();
    _waitingTimer?.cancel();
    widget.locationController?.removeListener(_locationChanged);
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    final config = _configuration;
    return Scaffold(
      backgroundColor: AgrisellColors.homeBackground,
      appBar: AppBar(title: const Text('Confirm pickup')),
      body: config == null
          ? Center(
              child: _error == null
                  ? const CircularProgressIndicator()
                  : Text(_error!),
            )
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                _summary(),
                const SizedBox(height: 12),
                _methods(config),
                const SizedBox(height: 12),
                _checklist(),
                const SizedBox(height: 12),
                _action(config),
              ],
            ),
    );
  }

  void _setConfiguration(PickupConfiguration value) {
    if (!mounted) return;
    setState(() => _configuration = value);
    if (widget.controller.pickupWaitingStartedAt != null) {
      _waitingTimer ??= Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _now = DateTime.now());
      });
    }
  }

  void _setError(String? value) {
    if (mounted) {
      setState(() {
        _error = value;
        if (value == null) _validationIssues = const [];
      });
    }
  }

  void _setValidation(PickupCompletionValidation validation) {
    if (!mounted) return;
    setState(() {
      _error = validation.isValid ? null : PickupCompletionValidation.heading;
      _validationIssues = validation.issues;
    });
  }

  void _setCheck(String label, bool value) {
    setState(() => _checks[label] = value);
    _saveRecovery();
  }

  void _setProof(PickupConfirmationMethod method, String value) {
    if (mounted) setState(() => _proofs[method] = value);
    _saveRecovery();
  }

  void _setSubmitting(bool value) {
    if (mounted) setState(() => _submitting = value);
  }

  void _locationChanged() {
    final location = widget.locationController?.location;
    widget.controller.updateCurrentRiderLocation(location);
    if (mounted) setState(() {});
  }

  Future<void> _refreshPickupLocation({required bool requestPermission}) async {
    final locationController = widget.locationController;
    if (locationController == null || _refreshingLocation) return;
    setState(() => _refreshingLocation = true);
    await locationController.refresh(requestPermission: requestPermission);
    _locationChanged();
    if (mounted) setState(() => _refreshingLocation = false);
  }
}
