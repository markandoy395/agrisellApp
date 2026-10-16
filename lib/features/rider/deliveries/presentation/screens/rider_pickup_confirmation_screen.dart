import 'package:agresell_app/features/rider/presentation/widgets/rider_safe_scaffold.dart';
import '../styles/rider_pickup_design_styles.dart';
import '../styles/rider_delivery_reference_styles.dart';
import '../widgets/rider_detail_card.dart';
import '../widgets/rider_pickup_reference_cards.dart';
import '../widgets/rider_pickup_proof_tile.dart';
import '../widgets/rider_pickup_product_proof.dart';
import '../widgets/rider_pickup_feedback.dart';
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/data/pickup_proof_storage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status_update.dart';
import 'package:agresell_app/features/rider/deliveries/domain/pickup_confirmation.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_location_controller.dart';

import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_pickup_problem_dialog.dart';

part 'rider_pickup_confirmation_actions.dart';
part 'rider_pickup_location_refresh.dart';
part 'rider_pickup_confirmation_sections.dart';
part 'rider_pickup_methods_section.dart';
part 'rider_pickup_recovery.dart';
part 'rider_pickup_content.dart';
part 'rider_pickup_problem_actions.dart';
part 'rider_pickup_gps_section.dart';

class RiderPickupConfirmationScreen extends StatefulWidget {
  const RiderPickupConfirmationScreen({
    required this.request,
    required this.riderId,
    required this.controller,
    this.locationController,
    this.proofStorage,
    super.key,
  });

  final DeliveryRequest request;
  final String riderId;
  final RiderDeliveryController controller;
  final RiderLocationController? locationController;
  final PickupProofStorage? proofStorage;

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
  final _photoPaths = <PickupConfirmationMethod, String>{};
  final _checks = <String, bool>{};
  late final _storage = widget.proofStorage ?? PickupProofStorage();
  final _idempotencyKey = Random.secure().nextInt(1 << 32).toString();
  PickupConfiguration? _configuration;
  String? _error;
  List<PickupValidationIssue> _validationIssues = const [];
  var _submitting = false;
  var _refreshingLocation = false;

  var _obscureCode = true;
  var _capturing = false;
  var _reporting = false;
  var _problemSaved = false;
  bool get _busy => _submitting || _capturing || _reporting;

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

    widget.locationController?.removeListener(_locationChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildPickup(context);

  void _setConfiguration(PickupConfiguration value) {
    if (!mounted) return;
    setState(() => _configuration = value);
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

  void _setProof(
    PickupConfirmationMethod method,
    String value, {
    String? imagePath,
  }) {
    if (!mounted) return;
    setState(() {
      _proofs[method] = value;
      if (imagePath != null) _photoPaths[method] = imagePath;
    });
    _saveRecovery();
  }

  void _setSubmitting(bool value) {
    if (mounted) setState(() => _submitting = value);
  }

  void _setRefreshingLocation(bool value) {
    if (mounted) setState(() => _refreshingLocation = value);
  }

  void _locationChanged() {
    final location = widget.locationController?.location;
    widget.controller.updateCurrentRiderLocation(location);
    if (mounted) setState(() {});
  }

  void _toggleCodeVisibility() => setState(() => _obscureCode = !_obscureCode);
  void _removeProof(PickupConfirmationMethod method) {
    setState(() {
      _proofs.remove(method);
      _photoPaths.remove(method);
    });
    _saveRecovery();
  }

  void _setCapturing(bool value) {
    if (mounted) setState(() => _capturing = value);
  }

  void _setReporting(bool value) {
    if (mounted) setState(() => _reporting = value);
  }

  void _setProblemSaved(bool value) {
    if (mounted)
      setState(() {
        _problemSaved = value;
        if (value) {
          _error = null;
          _validationIssues = const [];
        }
      });
  }
}
