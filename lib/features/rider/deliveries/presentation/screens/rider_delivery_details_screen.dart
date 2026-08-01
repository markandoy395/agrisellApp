import 'dart:async';

import 'package:flutter/material.dart';
import 'package:agresell_app/core/widgets/app_snack_bar.dart';
import 'package:agresell_app/core/theme/agrisell_colors.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_action_result.dart';
import 'package:agresell_app/features/rider/deliveries/data/delivery_proof_storage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_request.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_stage.dart';
import 'package:agresell_app/features/rider/deliveries/domain/delivery_status.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/controllers/rider_delivery_controller.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_acceptance_dialog.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_detail_utilities.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_action_panel.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_cancel_dialog.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_progress_timeline.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_quick_actions.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_problem_dialog.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_report_status_card.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_status_summary.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_waiting_summary.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_manual_arrival_dialog.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_pickup_confirmation_screen.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/screens/rider_delivery_confirmation_screen.dart';
import 'package:agresell_app/features/rider/presentation/widgets/rider_page_widgets.dart';
import 'package:agresell_app/features/rider/safety/presentation/widgets/rider_safety_report_dialog.dart';
import 'package:agresell_app/features/rider/safety/presentation/controllers/rider_safety_report_controller.dart';
import 'package:agresell_app/features/rider/safety/domain/rider_safety_report.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_delivery_request_overview.dart';
import 'package:agresell_app/features/rider/deliveries/presentation/widgets/rider_request_detail_sections.dart';

part 'rider_delivery_details_acceptance.dart';
part 'rider_delivery_details_status.dart';
part 'rider_delivery_details_content.dart';
part 'rider_delivery_details_safety.dart';

class RiderDeliveryDetailsScreen extends StatefulWidget {
  const RiderDeliveryDetailsScreen({
    required this.request,
    required this.controller,
    required this.riderId,
    super.key,
  });

  final DeliveryRequest request;
  final RiderDeliveryController controller;
  final String riderId;

  @override
  State<RiderDeliveryDetailsScreen> createState() =>
      _RiderDeliveryDetailsScreenState();
}

class _RiderDeliveryDetailsScreenState
    extends State<RiderDeliveryDetailsScreen> {
  late DeliveryRequest _request;
  var _isUpdating = false;
  var _acceptanceOpen = false;
  late final RiderSafetyReportController _safetyReportController;
  final DeliveryProofStorage _reportProofStorage = DeliveryProofStorage();

  @override
  void initState() {
    super.initState();
    _request = widget.request;
    _safetyReportController = RiderSafetyReportController(
      offlineQueue: widget.controller.offlineQueue,
    );
    unawaited(_safetyReportController.restore(widget.riderId));
  }

  @override
  void dispose() {
    _safetyReportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _buildDetails(context);

  Future<void> _advance(DeliveryStage nextStage) async {
    final purpose = nextStage.requiredProofPurpose;
    final proof = purpose == null
        ? null
        : await captureRiderDeliveryProof(context, purpose);
    if (!mounted || (nextStage.requiredProofPurpose != null && proof == null)) {
      return;
    }
    await _run(
      () => widget.controller.advance(
        requestId: _request.id,
        riderId: widget.riderId,
        nextStage: nextStage,
        proof: proof,
      ),
    );
  }

  Future<void> _decline() async {
    if (!await _confirm('Decline delivery', 'Decline this pickup request?')) {
      return;
    }
    await _run(
      () => widget.controller.decline(
        requestId: _request.id,
        riderId: widget.riderId,
      ),
    );
    if (mounted && _request.isDeclinedBy(widget.riderId)) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _cancel() async {
    final reason = await showRiderCancellationReasonDialog(context);
    if (reason == null || !mounted) return;
    await _run(
      () => widget.controller.cancel(
        requestId: _request.id,
        riderId: widget.riderId,
        reason: reason,
      ),
    );
  }

  Future<void> _run(Future<DeliveryActionResult> Function() action) async {
    setState(() => _isUpdating = true);
    final result = await action();
    if (!mounted) return;
    setState(() => _isUpdating = false);
    if (result.isSuccess) {
      setState(() => _request = result.request!);
    }
    _showMessage(
      result.isSuccess
          ? '${result.request!.stage.label} recorded.'
          : result.message ?? 'Delivery could not be updated.',
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showAppSnackBar(SnackBar(content: Text(message)));
  }

  void _applyAcceptanceState({required bool isOpen, DeliveryRequest? request}) {
    setState(() {
      _acceptanceOpen = isOpen;
      if (request != null) _request = request;
    });
  }

  void _replaceActiveRequest(DeliveryRequest request) {
    setState(() => _request = request);
  }

  void _setUpdating(bool value) {
    setState(() => _isUpdating = value);
  }
}
